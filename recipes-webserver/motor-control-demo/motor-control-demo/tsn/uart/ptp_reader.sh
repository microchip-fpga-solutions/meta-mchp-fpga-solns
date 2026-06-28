#!/bin/sh
# ptp_reader.sh - Extract PTP offset, no log file
PID_FILE="/tmp/ptp_reader.pid"
OUT_FILE="/tmp/current_offset"

case "$1" in
    stop)
        if [ -f "$PID_FILE" ]; then
            kill $(cat "$PID_FILE") 2>/dev/null
            rm -f "$PID_FILE"
            echo "Stopped"
        fi
        exit 0
        ;;
esac

if [ -f "$PID_FILE" ]; then
    kill $(cat "$PID_FILE") 2>/dev/null
fi

echo "0" > "$OUT_FILE"
echo $$ > "$PID_FILE"

LAST_UPDATE=0

cd /opt/microchip/japll-pi-controller/ && ./japll-pi 2>&1 | while read -r line; do
    NOW=$(date +%s)
    [ "$NOW" = "$LAST_UPDATE" ] && continue
    val=$(echo "$line" | awk '{
        for (i=1; i<=NF; i++) {
            if ($i == "offset") { print $(i+1); exit }
        }
    }')
    case "$val" in
        ''|*[!0-9-]*) continue ;;
    esac
    echo "$val" > "$OUT_FILE"
    LAST_UPDATE=$NOW
done
