#!/bin/bash
# stop_motor.sh
# Usage: ./stop_motor.sh [motor_board_ip]
PORT=5000
PID_FILE="/tmp/motor_loop.pid"
IP_FILE="/tmp/motor_loop.ip"

# Get IP: from argument, or from saved file, or default
if [ -n "$1" ]; then
    MOTOR_BOARD_IP="$1"
elif [ -f $IP_FILE ]; then
    MOTOR_BOARD_IP=$(cat $IP_FILE)
else
    MOTOR_BOARD_IP="192.168.13.1"
fi

# Kill background loop
if [ -f $PID_FILE ]; then
    kill $(cat $PID_FILE) 2>/dev/null
    rm -f $PID_FILE
fi

# Stop motor
echo "STOP" > /dev/udp/$MOTOR_BOARD_IP/$PORT

# Cleanup
rm -f $IP_FILE

echo "Motor stopped (IP: $MOTOR_BOARD_IP)"
