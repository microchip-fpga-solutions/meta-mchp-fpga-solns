#!/bin/bash

MOTOR_BOARD_IP="192.168.13.20"
PORT=5000
STEP=200
MAX_SPEED=1000
DELAY=0.2

PID_FILE="/tmp/motor_loop.pid"
IP_FILE="/tmp/motor_loop.ip"
LOG_FILE="/tmp/motor_loop.log"

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --ip <ip>             Motor board IP address, default: 192.168.13.20"
    echo "  --port <port>         UDP port, default: 5000"
    echo "  --step <step>         Speed increment step, default: 200"
    echo "  --max-speed <speed>   Maximum motor speed, default: 1000"
    echo "  --delay <seconds>     Delay between speed changes, default: 0.2"
    echo "  -h, --help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0"
    echo "  $0 --ip 192.168.13.20 --port 5000"
    echo "  $0 --ip 192.168.13.20 --port 6000 --step 100 --max-speed 1200 --delay 0.1"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --ip)
            MOTOR_BOARD_IP="$2"
            shift 2
            ;;
        --port)
            PORT="$2"
            shift 2
            ;;
        --step)
            STEP="$2"
            shift 2
            ;;
        --max-speed)
            MAX_SPEED="$2"
            shift 2
            ;;
        --delay)
            DELAY="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            # Backward compatibility:
            # Allow old style: ./run_motor.sh 192.168.13.20
            if [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                MOTOR_BOARD_IP="$1"
                shift
            else
                echo "Unknown argument: $1"
                usage
                exit 1
            fi
            ;;
    esac
done

if [ -f "$PID_FILE" ]; then
    kill "$(cat "$PID_FILE")" 2>/dev/null
    rm -f "$PID_FILE"
fi

echo "$MOTOR_BOARD_IP" > "$IP_FILE"

(
    while true; do
        # --- Clockwise (DIR 1) ---

        # START at speed 0, clockwise
        echo "START:0:1" > /dev/udp/$MOTOR_BOARD_IP/$PORT
        echo "START:0:1"

        # Ramp UP
        for SPEED in $(seq "$STEP" "$STEP" "$MAX_SPEED"); do
            echo "SPEED:${SPEED}:DIR:1" > /dev/udp/$MOTOR_BOARD_IP/$PORT
            echo "CW: SPEED:${SPEED}"
            sleep "$DELAY"
        done

        # START at max speed ramp down begins
        echo "START:${MAX_SPEED}:1" > /dev/udp/$MOTOR_BOARD_IP/$PORT
        echo "START:${MAX_SPEED}:1"

        # Ramp DOWN
        for SPEED in $(seq $((MAX_SPEED - STEP)) -$STEP $STEP); do
            echo "SPEED:${SPEED}:DIR:1" > /dev/udp/$MOTOR_BOARD_IP/$PORT
            echo "CW: SPEED:${SPEED}"
            sleep "$DELAY"
        done

        # --- Anticlockwise (DIR 0) ---

        # START at speed 0, anticlockwise
        echo "START:0:0" > /dev/udp/$MOTOR_BOARD_IP/$PORT
        echo "START:0:0"

        # Ramp UP
        for SPEED in $(seq "$STEP" "$STEP" "$MAX_SPEED"); do
            echo "SPEED:${SPEED}:DIR:0" > /dev/udp/$MOTOR_BOARD_IP/$PORT
            echo "ACW: SPEED:${SPEED}"
            sleep "$DELAY"
        done

        # START at max speed ramp down begins
        echo "START:${MAX_SPEED}:0" > /dev/udp/$MOTOR_BOARD_IP/$PORT
        echo "START:${MAX_SPEED}:0"

        # Ramp DOWN
        for SPEED in $(seq $((MAX_SPEED - STEP)) -$STEP $STEP); do
            echo "SPEED:${SPEED}:DIR:0" > /dev/udp/$MOTOR_BOARD_IP/$PORT
            echo "ACW: SPEED:${SPEED}"
            sleep "$DELAY"
        done
    done
) > "$LOG_FILE" 2>&1 &

echo $! > "$PID_FILE"

echo "Motor loop started:"
echo "  PID:        $(cat "$PID_FILE")"
echo "  IP:         $MOTOR_BOARD_IP"
echo "  Port:       $PORT"
echo "  Step:       $STEP"
echo "  Max Speed:  $MAX_SPEED"
echo "  Delay:      $DELAY"
echo "Logs: tail -F $LOG_FILE"
