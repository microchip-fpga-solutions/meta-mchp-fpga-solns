#!/usr/bin/env python3
"""
Motor Control Listener - Listens for ACKs from motor board, writes state to /tmp/
"""
import socket

UDP_PORT = 5001
SPEED_FILE = "/tmp/motor.speed"
DIR_FILE = "/tmp/motor.direction"

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind(('0.0.0.0', UDP_PORT))

try:
    while True:
        data, addr = sock.recvfrom(256)
        msg = data.decode().strip()

        if msg.startswith("ACK:"):
            parts = msg.split(":")
            if len(parts) >= 3:
                speed = parts[1]
                direction = parts[2]

                with open(SPEED_FILE, 'w') as f:
                    f.write(speed)
                with open(DIR_FILE, 'w') as f:
                    f.write(direction)

                #print(f"  [{addr[0]}] ACK speed={speed} dir={direction}")
            else:
                print(f"  [{addr[0]}] Malformed ACK: {msg}")
        else:
            print(f"  [{addr[0]}] Unknown: {msg}")

except KeyboardInterrupt:
    print("\nACK listener stopped.")
finally:
    sock.close()
