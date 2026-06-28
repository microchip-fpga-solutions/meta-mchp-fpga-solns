#!/usr/bin/env python3
"""
motor_server.py - Motor controller with UDP socket listener

Commands:
    START:<speed>:<direction>   Start with speed and direction
    STOP                        Stop motor
    SPEED:<rpm>:DIR:<0|1>       Set speed + direction combined
    SPEED:<rpm>                 Change speed only
    DIR:<0|1>                   Change direction only

Usage:
    python3 motor_server.py
    python3 motor_server.py --udp-port 5000 --ack-port 5001
"""

import argparse
import socket
import motor_lib_py as ml


def parse_args():
    parser = argparse.ArgumentParser(
        description="Motor controller UDP server"
    )

    parser.add_argument(
        "--udp-port",
        type=int,
        default=5000,
        help="UDP port to listen for motor commands, default: 5000"
    )

    parser.add_argument(
        "--ack-port",
        type=int,
        default=5001,
        help="UDP port on sender/Board 1 for ACKs, default: 5001"
    )

    return parser.parse_args()


args = parse_args()

UDP_PORT = args.udp_port
ACK_PORT = args.ack_port

# Initialize motor
bldc_motor = ml.Motor(ml.MotorType.BLDC)
bldc_motor.init()
bldc_motor.clear_fault()

motor_running = False
current_speed = 0
current_dir = 0

# UDP listener
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind(("0.0.0.0", UDP_PORT))

print(f"Motor server listening on UDP port {UDP_PORT}...")
print(f"ACKs will be sent to port {ACK_PORT}...")


def send_ack(addr):
    """Send ACK with current speed and direction back to sender."""
    ack_msg = f"ACK:{current_speed}:{current_dir}"
    sock.sendto(ack_msg.encode(), (addr[0], ACK_PORT))


try:
    while True:
        data, addr = sock.recvfrom(256)
        cmd = data.decode().strip()

        print(f"  [{addr[0]}] CMD: {cmd}")

        parts = cmd.split(":")

        if parts[0] == "START":
            bldc_motor.clear_fault()

            if len(parts) >= 3:
                current_dir = int(parts[2])
                bldc_motor.set_direction(current_dir)

            if len(parts) >= 2:
                current_speed = int(parts[1])
                bldc_motor.set_speed(current_speed)

            bldc_motor.start()
            motor_running = True

            send_ack(addr)

            print(f"  Motor started speed={current_speed} dir={current_dir}")

        elif parts[0] == "STOP":
            current_speed = 0

            bldc_motor.set_speed(0)
            bldc_motor.stop()
            motor_running = False

            send_ack(addr)

            print("  Motor stopped")

        elif parts[0] == "SPEED":
            current_speed = int(parts[1])
            bldc_motor.set_speed(current_speed)

            # Check if DIR is also in this packet: SPEED:500:DIR:1
            if len(parts) >= 4 and parts[2] == "DIR":
                current_dir = int(parts[3])
                bldc_motor.set_direction(current_dir)

            send_ack(addr)

            print(f"  Speed={current_speed} Dir={current_dir}")

        elif parts[0] == "DIR":
            current_dir = int(parts[1])
            bldc_motor.set_direction(current_dir)

            send_ack(addr)

            print(f"  Direction set to {current_dir}")

        else:
            print(f"  Unknown: {cmd}")

except KeyboardInterrupt:
    print("\nStopping...")

finally:
    bldc_motor.set_speed(0)
    bldc_motor.stop()
    sock.close()
    print("Motor stopped safely")
