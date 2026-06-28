#!/bin/bash
MOTOR_SERVER="/srv/www/tsn/uart/motor_server.py"
PID_FILE="/tmp/motor_server.pid"

start() {
    stop_quiet
    python3 $MOTOR_SERVER > /dev/null 2>&1 &
    echo $! > "$PID_FILE"
    echo "Motor server started (PID: $!)"
}

stop_quiet() {
    if [ -f "$PID_FILE" ]; then
        kill $(cat "$PID_FILE") 2>/dev/null
        rm -f "$PID_FILE"
    fi
    pkill -f "motor_server.py" 2>/dev/null
}

stop() {
    stop_quiet
    echo "Motor server stopped."
}

status() {
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        echo "motor_server.py: RUNNING (PID: $(cat $PID_FILE))"
    else
        echo "motor_server.py: STOPPED"
    fi
}

case "$1" in
    start)   start ;;
    stop)    stop ;;
    restart) stop; sleep 1; start ;;
    status)  status ;;
    *)       echo "Usage: $0 {start|stop|restart|status}"; exit 1 ;;
esac
