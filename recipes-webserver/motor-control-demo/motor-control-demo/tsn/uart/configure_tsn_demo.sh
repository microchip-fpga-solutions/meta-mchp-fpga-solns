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
#
# Listener flow:
#   /opt/microchip/tsn/tsninit.sh mc
#   ./board_setup.sh listener
#   ./tsn_listener_service.sh start

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

    wait_for_interface eth1 20
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

    echo "Stopped TSN demo services and VLAN configuration."
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

        echo
        echo "=========================================="
        echo "Talker configuration complete"
        echo "=========================================="
        echo "Listener IP: $LISTENER_IP"
        ;;

    listener)
        check_root

        run_tsn_init
        run_board_setup listener
        start_listener_service

        echo
        echo "=========================================="
        echo "Listener configuration complete"
        echo "=========================================="
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
