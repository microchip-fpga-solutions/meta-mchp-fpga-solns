#!/bin/bash
# uart_service.sh - Start/Stop uart_server

PID_FILE="/tmp/uart_server.pid"
LOG_FILE="/tmp/uart_server.log"
LOG_MAX_KB=512
DEFAULT_MOTOR_IP="192.168.13.20"

rotate_log() {
    if [ -f "$LOG_FILE" ]; then
        SIZE_KB=$(du -k "$LOG_FILE" 2>/dev/null | cut -f1)
        if [ "${SIZE_KB:-0}" -gt "$LOG_MAX_KB" ]; then
            mv "$LOG_FILE" "${LOG_FILE}.old"
            echo "[LOG] Rotated at ${SIZE_KB}KB" > "$LOG_FILE"
        fi
    fi
}

case "$1" in
    start)
        MOTOR_IP="${2:-$DEFAULT_MOTOR_IP}"
        if [ -f "$PID_FILE" ]; then
            kill "$(cat "$PID_FILE")" 2>/dev/null
            rm -f "$PID_FILE"
        fi
        rm -f "$LOG_FILE"
        nohup python3 -u ./uart_server.py \
            --motor-ip="$MOTOR_IP" \
            > "$LOG_FILE" 2>&1 &
        echo $! > "$PID_FILE"
        echo "Started (PID: $(cat "$PID_FILE"))"
        echo "  Motor IP: $MOTOR_IP"
        echo "  Log max : ${LOG_MAX_KB}KB"
        ;;
    stop)
        if [ -f "$PID_FILE" ]; then
            kill "$(cat "$PID_FILE")" 2>/dev/null
            rm -f "$PID_FILE"
            echo "Stopped"
        else
            echo "Not running"
        fi
        ;;
    status)
        if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
            SIZE=$(du -h "$LOG_FILE" 2>/dev/null | cut -f1)
            echo "Running (PID: $(cat "$PID_FILE")) Log: $SIZE"
        else
            echo "Not running"
            rm -f "$PID_FILE"
        fi
        ;;
    log)
        tail -f "$LOG_FILE"
        ;;
    rotate)
        rotate_log
        ;;
    *)
        echo "Usage: $0 {start [motor-ip]|stop|status|log|rotate}"
        echo
        echo "Examples:"
        echo "  $0 start"
        echo "  $0 start 192.168.13.20"
        echo "  $0 log"
        echo "  $0 rotate"
        ;;
esac
