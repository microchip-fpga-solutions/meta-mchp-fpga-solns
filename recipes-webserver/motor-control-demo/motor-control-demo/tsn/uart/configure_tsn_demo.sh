#!/usr/bin/env bash
set -e

# configure_tsn_demo.sh
#
# Usage:
#   ./configure_tsn_demo.sh talker
#   ./configure_tsn_demo.sh listener
#   ./configure_tsn_demo.sh stop
#   ./configure_tsn_demo.sh status
#
# Talker flow:
#   /opt/microchip/tsn/tsninit.sh mc
#   ./board_setup.sh talker
#   ./tsn_talker_service.sh start 192.168.13.20
#   phc2sys starts in background
#
# Listener flow:
#   /opt/microchip/tsn/tsninit.sh mc
#   ./board_setup.sh listener
#   ./tsn_listener_service.sh start
#   phc2sys starts in background

TSN_INIT="/opt/microchip/tsn/tsninit.sh"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

BOARD_SETUP="${SCRIPT_DIR}/board_setup.sh"
TALKER_SERVICE="${SCRIPT_DIR}/tsn_talker_service.sh"
LISTENER_SERVICE="${SCRIPT_DIR}/tsn_listener_service.sh"

# If your file is actually misspelled as tsn_listenrer_service.sh,
# use that automatically.
if [ ! -f "$LISTENER_SERVICE" ] && [ -f "${SCRIPT_DIR}/tsn_listenrer_service.sh" ]; then
    LISTENER_SERVICE="${SCRIPT_DIR}/tsn_listenrer_service.sh"
fi

DEFAULT_LISTENER_IP="192.168.13.20"

PHC2SYS_LOG="/tmp/phc2sys.log"
PHC2SYS_IFACE="eth1"

check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "Error: Please run as root or using sudo."
        echo "Example:"
        echo "  sudo $0 talker"
        exit 1
    fi
}

check_file() {
    if [ ! -f "$1" ]; then
        echo "Error: Required file not found: $1"
        exit 1
    fi
}

check_executable() {
    check_file "$1"

    if [ ! -x "$1" ]; then
        echo "Making executable: $1"
        chmod +x "$1"
    fi
}

check_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Error: Required command not found: $1"
        exit 1
    fi
}

wait_for_interface() {
    local iface="$1"
    local timeout="${2:-20}"
    local count=0

    echo "Waiting for interface $iface..."

    while [ "$count" -lt "$timeout" ]; do
        if ip link show "$iface" >/dev/null 2>&1; then
            echo "Interface $iface is available."
            return 0
        fi

        sleep 1
        count=$((count + 1))
    done

    echo "Warning: Interface $iface not found after ${timeout}s."
    echo "Continuing anyway..."
}

run_tsn_init() {
    echo
    echo "=========================================="
    echo "Step 1: Running TSN initialization"
    echo "=========================================="

    check_executable "$TSN_INIT"

    "$TSN_INIT" mc

    wait_for_interface "$PHC2SYS_IFACE" 20
}

run_board_setup() {
    local mode="$1"

    echo
    echo "=========================================="
    echo "Step 2: Running board setup: $mode"
    echo "=========================================="

    check_executable "$BOARD_SETUP"

    cd "$SCRIPT_DIR"
    "$BOARD_SETUP" "$mode"
}

start_talker_service() {
    local listener_ip="${1:-$DEFAULT_LISTENER_IP}"

    echo
    echo "=========================================="
    echo "Step 3: Starting TSN talker service"
    echo "=========================================="

    check_executable "$TALKER_SERVICE"

    cd "$SCRIPT_DIR"
    "$TALKER_SERVICE" start "$listener_ip"
}

start_listener_service() {
    echo
    echo "=========================================="
    echo "Step 3: Starting TSN listener service"
    echo "=========================================="

    check_executable "$LISTENER_SERVICE"

    cd "$SCRIPT_DIR"
    "$LISTENER_SERVICE" start
}

start_phc2sys() {
    echo
    echo "=========================================="
    echo "Step 4: Starting phc2sys"
    echo "=========================================="

    check_command phc2sys

    if ! ip link show "$PHC2SYS_IFACE" >/dev/null 2>&1; then
        echo "Warning: Interface $PHC2SYS_IFACE not found."
        echo "phc2sys may fail if $PHC2SYS_IFACE is not available."
    fi

    echo "Stopping any existing phc2sys instance..."
    pkill phc2sys 2>/dev/null || true

    echo "Starting phc2sys on interface $PHC2SYS_IFACE..."
    echo "Log file: $PHC2SYS_LOG"

    phc2sys -s "$PHC2SYS_IFACE" -c CLOCK_REALTIME -m --transportSpecific 1 -O 0 -w > "$PHC2SYS_LOG" 2>&1 &

    sleep 1

    if pgrep -x phc2sys >/dev/null 2>&1; then
        echo "phc2sys started successfully."
        pgrep -a phc2sys || true
    else
        echo "Warning: phc2sys does not appear to be running."
        echo "Check log:"
        echo "  cat $PHC2SYS_LOG"
    fi
}

stop_all() {
    echo
    echo "=========================================="
    echo "Stopping TSN demo"
    echo "=========================================="

    if [ -f "$TALKER_SERVICE" ]; then
        cd "$SCRIPT_DIR"
        "$TALKER_SERVICE" stop 2>/dev/null || true
    fi

    if [ -f "$LISTENER_SERVICE" ]; then
        cd "$SCRIPT_DIR"
        "$LISTENER_SERVICE" stop 2>/dev/null || true
    fi

    if [ -f "$BOARD_SETUP" ]; then
        cd "$SCRIPT_DIR"
        "$BOARD_SETUP" 0 2>/dev/null || true
    fi

    echo "Stopping phc2sys..."
    pkill phc2sys 2>/dev/null || true

    echo "Stopped TSN demo services, VLAN configuration, and phc2sys."
}

show_status() {
    echo
    echo "=========================================="
    echo "TSN demo status"
    echo "=========================================="

    if [ -f "$BOARD_SETUP" ]; then
        cd "$SCRIPT_DIR"
        "$BOARD_SETUP" status
    fi

    echo

    if [ -f "$TALKER_SERVICE" ]; then
        echo "Talker service:"
        cd "$SCRIPT_DIR"
        "$TALKER_SERVICE" status || true
    fi

    echo

    if [ -f "$LISTENER_SERVICE" ]; then
        echo "Listener service:"
        cd "$SCRIPT_DIR"
        "$LISTENER_SERVICE" status || true
    fi

    echo
    echo "phc2sys status:"

    if pgrep -x phc2sys >/dev/null 2>&1; then
        echo "phc2sys is running:"
        pgrep -a phc2sys || true
    else
        echo "phc2sys is not running."
    fi

    echo

    if [ -f "$PHC2SYS_LOG" ]; then
        echo "Last 10 lines of $PHC2SYS_LOG:"
        tail -n 10 "$PHC2SYS_LOG" || true
    else
        echo "phc2sys log not found: $PHC2SYS_LOG"
    fi
}

usage() {
    echo "Usage:"
    echo "  $0 talker [listener-ip]"
    echo "  $0 listener"
    echo "  $0 stop"
    echo "  $0 status"
    echo
    echo "Examples:"
    echo "  sudo $0 talker"
    echo "  sudo $0 talker 192.168.13.20"
    echo "  sudo $0 listener"
    echo "  sudo $0 stop"
    echo "  sudo $0 status"
}

case "$1" in
    talker)
        check_root

        LISTENER_IP="${2:-$DEFAULT_LISTENER_IP}"

        run_tsn_init
        run_board_setup talker
        start_talker_service "$LISTENER_IP"
        start_phc2sys

        echo
        echo "=========================================="
        echo "Talker configuration complete"
        echo "=========================================="
        echo "Listener IP: $LISTENER_IP"
        echo "phc2sys log: $PHC2SYS_LOG"
        ;;

    listener)
        check_root

        run_tsn_init
        run_board_setup listener
        start_listener_service
        start_phc2sys

        echo
        echo "=========================================="
        echo "Listener configuration complete"
        echo "=========================================="
        echo "phc2sys log: $PHC2SYS_LOG"
        ;;

    stop)
        check_root
        stop_all
        ;;

    status)
        show_status
        ;;

    *)
        usage
        exit 1
        ;;
esac
