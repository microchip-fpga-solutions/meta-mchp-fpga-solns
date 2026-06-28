#!/usr/bin/env python3
"""
uart_server.py - TSN UART Server
Uses libregaccess.so for hardware register access (volatile 32-bit transactions).

Usage:
    sudo python3 uart_server.py                                    (defaults)
    sudo python3 uart_server.py /dev/ttyS2 115200                  (custom UART)
    sudo python3 uart_server.py --motor-ip=192.168.13.20           (motor board IP)
    sudo python3 uart_server.py -h                                 (help)

Opcodes:
    0x20  Enable/Disable TSN         payload: 01=enable, 00=disable
    0x21  Start/Stop Traffic         payload: 01=start,  00=stop
    0x22  Start/Stop Motor           payload: 01=start,  00=stop
    0x23  Start/Stop Counter         payload: 01=start,  00=stop
    0x24  Enable/Disable FRER        payload: 01=enable, 00=disable
    0x25  PTP Read                   no payload
    0x26  Reset                      payload: 01=reset
    0x60  Start/Stop Graph           payload: 01=start,  00=stop

Frame format:
    [0xA5] [0x5A] [LEN] [OPCODE] [PAYLOAD...]
    LEN = 1 (opcode) + payload_length

Control file types:
    .cfg : Register address/value pairs, executed by Python directly
    .sh  : Shell script, executed via subprocess
"""

import os
import sys
import struct
import time
import select
import subprocess
import threading
import ctypes
from collections import defaultdict

# ============================================================================
# Configuration
# ============================================================================

UART_DEVICE = "/dev/ttyS1"
UART_BAUD = 115200

# ============================================================================
# Register bases (must match the windows in regaccess.c)
# ============================================================================
def load_bases(path):
    bases = {}
    with open(path) as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith('#'):
                key, val = line.split('=', 1)
                bases[key.strip()] = int(val.strip(), 0)
    return bases

BASES_ENV = os.path.join(os.path.dirname(os.path.abspath(__file__)), "bases.env")
_BASES = load_bases(BASES_ENV)

TSN_BASE     = _BASES['TSN_BASE']
TRAFFIC_BASE = _BASES['TRAFFIC_BASE']

# Symbolic name -> address (for cfg BASE directive)
BASE_NAMES = {
    'TSN':     TSN_BASE,
    'TRAFFIC': TRAFFIC_BASE,
}

# ============================================================================
# Stream Sources Configuration
# Each entry: (name, type, source, interval_ms, opcode, auto)
#
# Types: 'reg'  = hardware register address
#        'file' = read integer from file
#        'func' = call time.time()
#
# Rules:
#   - All entries with same opcode MUST have same interval_ms
#   - All entries with same opcode MUST have same auto value
#   - auto=True  : starts streaming immediately with server
#   - auto=False : starts only when GUI sends enable command
# ============================================================================

STREAM_SOURCES_COMMON = [
    # --- 0x62: PTP data, 200ms, auto-start ---
    ('MOTOR_SPEED', 'file', '/tmp/motor.speed',      200,  0x62, True),
    ('MOTOR_DIR',   'file', '/tmp/motor.direction',  200,  0x62, True),
    # --- 0x61: Motor status, 1000ms, auto-start ---
    ('TIME_OF_DAY', 'func', None,                    1000, 0x61, True),
    ('PTP_OFFSET',  'file', '/tmp/current_offset',   1000, 0x61, True),
]

GRAPH_SOURCES_DEFAULT = [
    ('Q1_PKT_SENT', 'reg',  0x648,                   1000, 0x60, False),
    ('Q2_PKT_SENT', 'reg',  0x650,                   1000, 0x60, False),
    ('Q1_PKT_DROP', 'reg',  0x608,                   1000, 0x60, False),
    ('Q2_PKT_DROP', 'reg',  0x610,                   1000, 0x60, False),
    ('TX_PORT0',    'reg',  0x720,                   1000, 0x60, False),
    ('TX_PORT1',    'reg',  0x728,                   1000, 0x60, False),
]

GRAPH_SOURCES_FRER = [
    ('Q2_PKT_SENT', 'reg',  0x650,                   1000, 0x60, False),
    ('Q1_PKT_SENT', 'reg',  0x648,                   1000, 0x60, False),
    ('Q2_PKT_DROP', 'reg',  0x610,                   1000, 0x60, False),
    ('Q1_PKT_DROP', 'reg',  0x608,                   1000, 0x60, False),
    ('TX_PORT0',    'reg',  0x720,                   1000, 0x60, False),
    ('TX_PORT1',    'reg',  0x728,                   1000, 0x60, False),
]

STREAM_SOURCES = STREAM_SOURCES_COMMON + GRAPH_SOURCES_DEFAULT

SCRIPTS = {
    0x30: {
        1: """
        /srv/www/tsn/uart/stop_traffic.cfg,
        /srv/www/tsn/uart/mode0.cfg,
        /srv/www/tsn/uart/stop_motor.sh {motor_ip}
        """,
    },
    0x31: {
        1: """
        /srv/www/tsn/uart/stop_traffic.cfg,
        /srv/www/tsn/uart/stop_motor.sh {motor_ip},
        /srv/www/tsn/uart/mode1.cfg,
        /srv/www/tsn/uart/start_traffic.cfg
        """,
    },
    0x32: {
        1: """
        /srv/www/tsn/uart/stop_traffic.cfg,
        /srv/www/tsn/uart/mode2.cfg,
        /srv/www/tsn/uart/run_motor.sh {motor_ip}
        """,
    },
    0x33: {
        1: """
        /srv/www/tsn/uart/stop_traffic.cfg,
        /srv/www/tsn/uart/run_motor.sh {motor_ip},
        /srv/www/tsn/uart/mode3.cfg,
        /srv/www/tsn/uart/start_traffic.cfg
        """,
    },
    0x34: {
        1: """
        /srv/www/tsn/uart/stop_traffic.cfg,
        /srv/www/tsn/uart/stop_motor.sh {motor_ip},
        /srv/www/tsn/uart/update_basetime.sh mode4,
        /srv/www/tsn/uart/mode4.cfg,
        /srv/www/tsn/uart/run_motor.sh {motor_ip},
        /srv/www/tsn/uart/start_traffic.cfg
        """,
    },
    0x35: {
        1: """
        /srv/www/tsn/uart/stop_traffic.cfg,
        /srv/www/tsn/uart/stop_motor.sh {motor_ip},
        /srv/www/tsn/uart/update_basetime.sh mode5,
        /srv/www/tsn/uart/mode5.cfg,
        /srv/www/tsn/uart/run_motor.sh {motor_ip},
        /srv/www/tsn/uart/start_traffic.cfg
        """,
    },
}

# ============================================================================
# Protocol
# ============================================================================

SYNC_1 = 0xA5
SYNC_2 = 0x5A

OP_GRAPH  = 0x60
OP_STATUS = 0x61
OP_PTP    = 0x62

CONTROL_OPCODES = {0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35}

OPCODE_NAMES = {
    0x20: "TSN",
    0x21: "BE Traffic",
    0x22: "Motor",
    0x23: "Counter",
    0x24: "FRER",
    0x25: "PTP Read",
    0x26: "Reset",
    0x30: "No Mode",
    0x31: "Normal Traffic Mode",
    0x32: "Critical Traffic Mode",
    0x33: "Mixed Mode",
    0x34: "Mixed + TSN Mode",
    0x35: "Mixed + TSN + FRER Mode",
}

RESP_OK      = b'\x00'
RESP_ERR     = b'\x01'
RESP_UNKNOWN = b'\xFF'

# ============================================================================
# Globals
# ============================================================================

g_uart_fd   = -1
g_uart_lock = threading.Lock()
g_regs      = None
g_running   = True
g_streaming = False
g_motor_ip  = "192.168.13.1"
g_graph_sources = GRAPH_SOURCES_DEFAULT

# ============================================================================
# Banner and Help
# ============================================================================

def print_banner():
    groups = defaultdict(list)
    for entry in STREAM_SOURCES:
        name, stype, source, interval_ms, opcode, auto = entry
        groups[(interval_ms, opcode, auto)].append(name)
    print()
    print("=" * 62)
    print("  TSN - UART Demo")
    print("=" * 62)
    print(f"  UART        : {UART_DEVICE} @ {UART_BAUD}")
    print(f"  Register I/O: libregaccess.so (volatile 32-bit)")
    print(f"  Motor IP    : {g_motor_ip}")
    print(f"  Responses   : 0x00=OK  0x01=ERR  0xFF=Unknown opcode")
    print(f"  Stream groups:")
    for (interval_ms, opcode, auto), names in sorted(groups.items()):
        mode = "auto" if auto else "on-command"
        print(f"    0x{opcode:02X} every {interval_ms}ms ({mode}): {names}")
    print("=" * 62)


def print_help():
    print_banner()
    print()
    print(f"  {'Opcode':<8} {'Command':<22} {'Payload':<18} {'Response'}")
    print(f"  {'------':<8} {'-------':<22} {'-------':<18} {'--------'}")
    print(f"  0x20     TSN On/Off            01=on  00=off       [00] | [01]")
    print(f"  0x21     Traffic Start/Stop    01=start 00=stop    [00] | [01]")
    print(f"  0x22     Motor Start/Stop      01=start 00=stop    [00] | [01]")
    print(f"  0x23     Counter Start/Stop    01=start 00=stop    [00] | [01]")
    print(f"  0x24     FRER Enable/Disable   01=on  00=off       [00] | [01]")
    print(f"  0x25     PTP Read              (none)              [00] | [01]")
    print(f"  0x26     Reset                 01=reset            [00] | [01]")
    print(f"  0x60     Graph Start/Stop      01=start 00=stop    [00] | [01]")
    print(f"  0x61     Motor Status          auto   [speed][dir]")
    print(f"  0x62     PTP Data              auto   [time][offset]")
    print()
    print("  Usage:")
    print("    sudo python3 uart_server.py                                (defaults)")
    print("    sudo python3 uart_server.py /dev/ttyS2 115200              (custom UART)")
    print("    sudo python3 uart_server.py --motor-ip=192.168.13.1        (motor board IP)")
    print("    sudo python3 uart_server.py -h                             (this help)")
    print()

# ============================================================================
# Register access via libregaccess.so
# ============================================================================

class Registers:
    def __init__(self):
        script_dir = os.path.dirname(os.path.abspath(__file__))
        lib_path = os.path.join(script_dir, "libregaccess.so")
        if not os.path.exists(lib_path):
            raise RuntimeError(
                f"libregaccess.so not found at: {lib_path}\n"
                f"  Compile with:\n"
                f"  gcc -shared -fPIC -O2 -o libregaccess.so regaccess.c"
            )
        try:
            self._lib = ctypes.CDLL(lib_path)
        except Exception as e:
            raise RuntimeError(f"Failed to load libregaccess.so: {e}")
        self._lib.regaccess_init.restype = ctypes.c_int
        self._lib.regaccess_close.restype = None
        self._lib.regaccess_read.argtypes = [
            ctypes.c_uint64, ctypes.POINTER(ctypes.c_uint32)
        ]
        self._lib.regaccess_read.restype = ctypes.c_int
        self._lib.regaccess_write.argtypes = [
            ctypes.c_uint64, ctypes.c_uint32, ctypes.POINTER(ctypes.c_uint32)
        ]
        self._lib.regaccess_write.restype = ctypes.c_int
        if self._lib.regaccess_init() != 0:
            raise RuntimeError("regaccess_init() failed. Run as root (sudo).")
        print(f"[REG] libregaccess.so loaded OK")

    def read(self, addr):
        out = ctypes.c_uint32(0)
        rc = self._lib.regaccess_read(
            ctypes.c_uint64(addr), ctypes.byref(out)
        )
        if rc == 0:
            return True, out.value
        else:
            print(f"  [REG] Read failed: 0x{addr:08X}")
            return False, 0

    def write(self, addr, value):
        out = ctypes.c_uint32(0)
        rc = self._lib.regaccess_write(
            ctypes.c_uint64(addr), ctypes.c_uint32(value), ctypes.byref(out)
        )
        if rc == 0:
            return True, out.value
        else:
            print(f"  [REG] Write failed: 0x{addr:08X} = 0x{value:08X}")
            return False, 0

    def close(self):
        self._lib.regaccess_close()

# ============================================================================
# UART
# ============================================================================

def uart_open(device, baudrate):
    import termios
    baud_map = {
        9600: termios.B9600,
        19200: termios.B19200,
        38400: termios.B38400,
        57600: termios.B57600,
        115200: termios.B115200,
        230400: termios.B230400,
        460800: termios.B460800,
        921600: termios.B921600,
    }
    fd = os.open(device, os.O_RDWR | os.O_NOCTTY | os.O_SYNC)
    attrs = termios.tcgetattr(fd)
    speed = baud_map.get(baudrate, termios.B115200)
    attrs[4] = speed
    attrs[5] = speed
    attrs[2] &= ~termios.CSIZE
    attrs[2] |= termios.CS8
    attrs[2] |= (termios.CLOCAL | termios.CREAD)
    attrs[2] &= ~(
        termios.PARENB | termios.PARODD |
        termios.CSTOPB | termios.CRTSCTS
    )
    attrs[0] &= ~(
        termios.IXON | termios.IXOFF | termios.IXANY |
        termios.IGNBRK | termios.BRKINT | termios.PARMRK |
        termios.ISTRIP | termios.INLCR | termios.IGNCR |
        termios.ICRNL
    )
    attrs[3] = 0
    attrs[1] = 0
    attrs[6][termios.VMIN] = 0
    attrs[6][termios.VTIME] = 0
    termios.tcsetattr(fd, termios.TCSANOW, attrs)
    termios.tcflush(fd, termios.TCIOFLUSH)
    return fd

# ============================================================================
# Frame helpers
# ============================================================================

def build_frame(opcode, payload=b''):
    length = 1 + len(payload)
    return bytes([SYNC_1, SYNC_2, length, opcode]) + payload


def send_frame(opcode, payload=b''):
    import termios
    frm = build_frame(opcode, payload)
    hex_str = " ".join(f"{b:02X}" for b in frm)
    print(f"  [TX] {hex_str}")
    with g_uart_lock:
        try:
            os.write(g_uart_fd, frm)
            termios.tcdrain(g_uart_fd)
        except OSError as e:
            print(f"  [TX] ERROR: {e}")

# ============================================================================
# Frame parser
# ============================================================================

class FrameParser:
    def __init__(self):
        self.state = 0
        self.expected = 0
        self.buf = bytearray()

    def feed(self, b):
        if self.state == 0:
            if b == SYNC_1:
                self.state = 1
        elif self.state == 1:
            self.state = 2 if b == SYNC_2 else 0
        elif self.state == 2:
            self.expected = b
            self.buf = bytearray()
            self.state = 3 if b > 0 else 0
        elif self.state == 3:
            self.buf.append(b)
            if len(self.buf) >= self.expected:
                opcode = self.buf[0]
                payload = bytes(self.buf[1:])
                self.state = 0
                return (opcode, payload)
        return None

# ============================================================================
# Script runner (for .sh files)
# ============================================================================

def run_script(cmd_str):
    print(f"  [SCRIPT] Running: {cmd_str}")
    try:
        r = subprocess.run(
            cmd_str, shell=True,
            capture_output=True, text=True, timeout=30
        )
        ok = r.returncode == 0
        out = r.stdout.strip() or r.stderr.strip()
        print(f"  [SCRIPT] {'OK' if ok else 'FAIL'}: {out[:80]}")
        return ok, out
    except Exception as e:
        print(f"  [SCRIPT] ERROR: {e}")
        return False, str(e)

# ============================================================================
# CFG file executor (for .cfg files) - offset-based with BASE directive
# ============================================================================
def execute_register_file(filepath):
    print(f"  [CFG] Loading: {filepath}")
    if not os.path.exists(filepath):
        print(f"  [ERR] File not found: {filepath}")
        return False, "File not found"

    count  = 0
    errors = 0
    base   = None            # set by a "BASE 0x...." directive

    try:
        with open(filepath, 'r') as f:
            for line_num, line in enumerate(f, 1):
                # strip inline comments + whitespace
                line = line.split('#', 1)[0].strip()
                if not line:
                    continue

                parts = line.split()

                # ---- BASE directive ----
                if parts[0].upper() == 'BASE':
                    if len(parts) < 2:
                        print(f"  [CFG] WARN line {line_num}: BASE missing value")
                        errors += 1
                        continue
                    try:
                        token = parts[1]
                        if token.upper() in BASE_NAMES:
                            base = BASE_NAMES[token.upper()]
                        else:
                            base = int(token, 0)
                        print(f"  [CFG] BASE = 0x{base:08X}")
                    except ValueError:
                        print(f"  [CFG] WARN line {line_num}: bad BASE {parts[1]!r}")
                        errors += 1
                    continue

                # ---- delay directive ----
                if parts[0].lower() == 'delay':
                    if len(parts) >= 2:
                        ms = int(parts[1])
                        print(f"  [CFG] delay {ms}ms")
                        time.sleep(ms / 1000.0)
                    continue

                # ---- offset value line ----
                if len(parts) < 2:
                    print(f"  [CFG] WARN line {line_num}: "
                          f"expected 'offset value', got: {line}")
                    continue

                if base is None:
                    print(f"  [CFG] WARN line {line_num}: "
                          f"no BASE set before offsets")
                    errors += 1
                    continue

                try:
                    offset = int(parts[0], 16)
                    val    = int(parts[1], 16)
                except ValueError as e:
                    print(f"  [CFG] WARN line {line_num}: parse error: {e}")
                    errors += 1
                    continue

                addr = base + offset                 # full physical address
                ok, rb = g_regs.write(addr, val)
                if ok:
                    count += 1
                else:
                    print(f"  [CFG] FAIL: 0x{addr:08X} "
                          f"(off 0x{offset:03X}) = 0x{val:08X}")
                    errors += 1

    except Exception as e:
        print(f"  [CFG] ERROR reading file: {e}")
        return False, str(e)

    if errors > 0:
        msg = f"{count} written, {errors} failed"
        print(f"  [CFG] DONE with errors: {msg}")
        return False, msg
    else:
        msg = f"{count} registers written"
        print(f"  [CFG] OK: {msg}")
        return True, msg

# ============================================================================
# Unified dispatch: .cfg or .sh
# ============================================================================

def execute_script_or_cfg(cmd_str):
    all_ok = True
    last_msg = ""
    parts = [p.strip() for p in cmd_str.split(',')]
    for part in parts:
        filepath = part.split()[0]
        if filepath.endswith('.cfg'):
            ok, msg = execute_register_file(filepath)
        else:
            ok, msg = run_script(part)
        if not ok:
            all_ok = False
        last_msg = msg
    return all_ok, last_msg

# ============================================================================
# Send quite frame to reduce logs
# ============================================================================
def send_frame_quiet(opcode, payload=b''):
    """Send frame without console output."""
    import termios
    frm = build_frame(opcode, payload)
    with g_uart_lock:
        try:
            os.write(g_uart_fd, frm)
            termios.tcdrain(g_uart_fd)
        except OSError as e:
            print(f"  [TX] ERROR: {e}")

# ============================================================================
# Stream source reader
# ============================================================================
def read_source(entry):
    """Read one stream source. Returns (name, value, ok)."""
    name, stype, source, interval_ms, opcode, auto = entry
    try:
        if stype == 'reg':
            addr = TSN_BASE + source          # source is now an OFFSET
            ok, val = g_regs.read(addr)
            return name, val if ok else 0xFFFFFFFF, ok
        elif stype == 'file':
            with open(source, 'r') as f:
                return name, int(f.read().strip()), True
        elif stype == 'func':
            return name, int(time.time()), True
    except:
        return name, 0, False

# ============================================================================
# Command handler
# ============================================================================

def handle_command(opcode, payload):
    global g_streaming
    raw = bytes([SYNC_1, SYNC_2, 1 + len(payload), opcode]) + payload
    hex_str = " ".join(f"{b:02X}" for b in raw)
    print(f"\n{'=' * 62}")
    print(f"  [RX] {hex_str}")
    print(f"  [RX] MAGIC=0xA55A  LEN={1 + len(payload)}  "
          f"OpCode=0x{opcode:02X}  "
          f"Data={payload.hex() if payload else '(none)'}")

    # 0x60: Graph Start/Stop
    if opcode == OP_GRAPH:
        if not payload:
            print(f"  [ERR] Graph: missing payload (01=start, 00=stop)")
            send_frame(OP_GRAPH, RESP_ERR)
            return
        action = payload[0]
        if action == 0x01:
            g_streaming = True
            graph_entries = [
                e for e in STREAM_SOURCES if e[4] == OP_GRAPH
            ]
            interval = graph_entries[0][3] if graph_entries else 1000
            print(f"  [CMD] START GRAPH  "
                  f"({len(graph_entries)} sources, "
                  f"{interval}ms interval)")
            send_frame(OP_GRAPH, RESP_OK)
        elif action == 0x00:
            g_streaming = False
            print(f"  [CMD] STOP GRAPH")
            send_frame(OP_GRAPH, RESP_OK)
        else:
            print(f"  [ERR] Graph: unknown action 0x{action:02X}")
            send_frame(OP_GRAPH, RESP_ERR)

    # 0x20-0x26: Control Commands
    elif opcode in CONTROL_OPCODES:
        name = OPCODE_NAMES.get(opcode, f"Control 0x{opcode:02X}")
        if opcode == 0x25:
            action = None
            action_str = "read"
        elif payload:
            action = payload[0]
            action_str = "ENABLE/START" if action == 1 else "DISABLE/STOP"
        else:
            print(f"  [ERR] {name}: missing payload (01=on, 00=off)")
            send_frame(opcode, RESP_ERR)
            return
        print(f"  [CMD] {name} -> {action_str}")
        # Switch graph sources based on mode
        if opcode in range(0x30, 0x36):
            global g_graph_sources
            if opcode == 0x35:
                g_graph_sources = GRAPH_SOURCES_FRER
            else:
                g_graph_sources = GRAPH_SOURCES_DEFAULT
            print(f"  [MODE] Graph sources: {'FRER' if opcode == 0x35 else 'DEFAULT'}")

        script_map = SCRIPTS.get(opcode, {})
        script_cmd = script_map.get(action) or script_map.get(None)
        if not script_cmd:
            print(f"  [ERR] No script mapped for "
                  f"opcode=0x{opcode:02X} action={action}")
            send_frame(opcode, RESP_ERR)
            return
        script_cmd = script_cmd.replace('{motor_ip}', g_motor_ip)
        parts = [p.strip() for p in script_cmd.split(',')]
        for part in parts:
            filepath = part.split()[0]
            if not os.path.exists(filepath):
                print(f"  [ERR] File not found: {filepath}")
                send_frame(opcode, RESP_ERR)
                return
        ok, _ = execute_script_or_cfg(script_cmd)
        print(f"  [{'OK' if ok else 'ERR'}] {name}")
        send_frame(opcode, RESP_OK if ok else RESP_ERR)

    # Unknown opcode
    else:
        print(f"  [ERR] Unknown opcode 0x{opcode:02X}")
        send_frame(opcode, RESP_UNKNOWN)

# ============================================================================
# Unified streaming thread
# ============================================================================

def stream_thread_func():
    """Single thread handles all stream groups based on STREAM_SOURCES."""
    global g_running

    # Auto-group by (interval_ms, opcode, auto)
    groups = defaultdict(list)
    for entry in STREAM_SOURCES:
        name, stype, source, interval_ms, opcode, auto = entry
        groups[(interval_ms, opcode, auto)].append(entry)

    # Print groups
    for (interval_ms, opcode, auto), entries in sorted(groups.items()):
        names = [e[0] for e in entries]
        mode = "auto" if auto else "on-command"
        print(f"[STREAM] 0x{opcode:02X} every {interval_ms}ms "
              f"({mode}): {names}")

    # Track last-send time per group
    timers = defaultdict(float)
    tick = 0.05  # 50ms loop resolution

    while g_running:
        now = time.time()

        # Rebuild active sources (graph may switch per mode)
        active_sources = STREAM_SOURCES_COMMON + g_graph_sources
        groups = defaultdict(list)
        for entry in active_sources:
            name, stype, source, interval_ms, opcode, auto = entry
            groups[(interval_ms, opcode, auto)].append(entry)

        for (interval_ms, opcode, auto), entries in groups.items():
            interval_s = interval_ms / 1000.0

            if now - timers[(interval_ms, opcode, auto)] < interval_s:
                continue

            timers[(interval_ms, opcode, auto)] = now

            # Skip non-auto groups unless streaming is enabled
            if not auto and not g_streaming:
                continue

            # Read all sources in this group
            payload = bytearray()
            values = []
            for entry in entries:
                name, val, ok = read_source(entry)
                payload.extend(struct.pack('>I', val & 0xFFFFFFFF))
                values.append((name, val, ok))

            # Console output for graph (won't flood at 1s interval)
            if opcode == OP_GRAPH:
                ts = time.strftime("%H:%M:%S")
                print(f"\n  [STREAM] {ts}  0x{opcode:02X}  "
                      f"({len(entries)} sources)")
                print(f"  {'Name':<16}  {'Hex':>10}  "
                      f"{'Dec':>12}  {'Status'}")
                print(f"  {'-'*16}  {'-'*10}  "
                      f"{'-'*12}  {'-'*6}")
                for name, val, ok in values:
                    status = "OK " if ok else "ERR"
                    print(f"  {name:<16}  "
                          f"0x{val & 0xFFFFFFFF:08X}  "
                          f"{val:>12}  {status}")
                send_frame(opcode, bytes(payload))
            else:
                send_frame_quiet(opcode, bytes(payload))

        time.sleep(tick)

# ============================================================================
# Main
# ============================================================================

def main():
    global g_uart_fd, g_regs, g_running, g_motor_ip

    # Help
    if "-h" in sys.argv or "--help" in sys.argv:
        print_help()
        return 0

    # Parse --motor-ip=XXX
    for arg in sys.argv[1:]:
        if arg.startswith('--motor-ip='):
            g_motor_ip = arg.split('=')[1]
            sys.argv.remove(arg)
            break

    # Positional args
    uart_dev = sys.argv[1] if len(sys.argv) > 1 else UART_DEVICE
    uart_baud = int(sys.argv[2]) if len(sys.argv) > 2 else UART_BAUD

    # Startup banner
    print_banner()
    print()

    # Hardware init
    try:
        g_regs = Registers()
    except RuntimeError as e:
        print(f"\n[FATAL] {e}")
        return 1
    print()

    # Quick register self-test
    print("--- Hardware register test ---")
    reg_entries = [e for e in STREAM_SOURCES if e[1] == 'reg']
    for entry in reg_entries[:2]:
        name, stype, offset, interval_ms, opcode, auto = entry
        addr = TSN_BASE + offset               # add base
        ok, val = g_regs.read(addr)
        status = "OK " if ok else "ERR"
        print(f"  [{status}] {name:<16}  "
              f"0x{addr:08X} = 0x{val:08X} ({val})")
    print()

    # Open UART
    try:
        g_uart_fd = uart_open(uart_dev, uart_baud)
        print(f"[UART] Opened: {uart_dev} @ {uart_baud}")
    except Exception as e:
        print(f"[ERROR] UART open failed: {e}")
        g_regs.close()
        return 1

    # Send banner over UART
    import termios
    banner = b"\r\n[TSN UART Server Ready]\r\n"
    os.write(g_uart_fd, banner)
    termios.tcdrain(g_uart_fd)
    print(f"[UART] Banner sent to remote side")

    # Start unified streaming thread
    stream_t = threading.Thread(target=stream_thread_func, daemon=True)
    stream_t.start()

    # Ready
    print()
    print("=" * 62)
    print("  READY - Waiting for commands")
    print("  Send A5 5A 02 60 01 to start graph streaming")
    print("  Send A5 5A 02 60 00 to stop  graph streaming")
    print("  Status (0x61) auto-streaming every 200ms")
    print("  PTP    (0x62) auto-streaming every 1000ms")
    print("  Ctrl+C to exit")
    print("=" * 62)
    print()

    # Main receive loop
    parser = FrameParser()
    try:
        while g_running:
            try:
                readable, _, _ = select.select(
                    [g_uart_fd], [], [], 1.0
                )
            except (OSError, ValueError):
                break
            if not readable:
                continue
            try:
                data = os.read(g_uart_fd, 256)
            except OSError:
                continue
            for b in data:
                result = parser.feed(b)
                if result:
                    handle_command(*result)
    except KeyboardInterrupt:
        print("\n\n[EXIT] Ctrl+C received")

    # Cleanup
    g_running = False
    g_streaming = False
    stream_t.join(timeout=2)
    os.close(g_uart_fd)
    g_regs.close()
    print("[OK] Done.")
    return 0


if __name__ == '__main__':
    sys.exit(main())
