#!/bin/bash
# board_setup.sh - Create/Delete VLAN interface + start services
#
# Usage:
#   ./board_setup.sh talker     (create VLAN, IP=192.168.13.10, start PTP + motor listener)
#   ./board_setup.sh listener   (create VLAN, IP=192.168.13.20, start japll-pi)
#   ./board_setup.sh 0          (delete VLAN, kill services)
#   ./board_setup.sh status     (show interface status)
#   ./board_setup.sh            (help)

IFACE="eth1"
VLAN_ID=2
PCP=2
VLAN_IFACE="${IFACE}.${VLAN_ID}"

case "$1" in
    talker)
        IP_ADDR="192.168.13.10/24"
        echo "Creating VLAN interface: $VLAN_IFACE (talker)"
        ip link add link $IFACE name $VLAN_IFACE type vlan id $VLAN_ID egress-qos-map 0:$PCP
        sleep 1
        ip link set dev $VLAN_IFACE up
        sleep 1
        ip addr add $IP_ADDR dev $VLAN_IFACE
        sleep 1
        ifconfig $VLAN_IFACE mtu 1400
        sleep 1
        echo "  Interface : $VLAN_IFACE"
        echo "  VLAN ID   : $VLAN_ID"
        echo "  PCP       : $PCP"
        echo "  IP        : $IP_ADDR"
        # Start PTP reader and motor params listener
        /srv/www/tsn/uart/ptp_reader.sh &
        echo "  ptp_reader.sh started (PID: $!)"
        python3 /srv/www/tsn/uart/get_motor_params.py &
        echo "  get_motor_params.py started (PID: $!)"
        echo "Done."
        ;;
    listener)
        IP_ADDR="192.168.13.20/24"
        echo "Creating VLAN interface: $VLAN_IFACE (listener)"
        ip link add link $IFACE name $VLAN_IFACE type vlan id $VLAN_ID egress-qos-map 0:$PCP
        sleep 1
        ip link set dev $VLAN_IFACE up
        sleep 1
        ip addr add $IP_ADDR dev $VLAN_IFACE
        sleep 1
        ifconfig $VLAN_IFACE mtu 1400
        sleep 1
        echo "  Interface : $VLAN_IFACE"
        echo "  VLAN ID   : $VLAN_ID"
        echo "  PCP       : $PCP"
        echo "  IP        : $IP_ADDR"
        # Start japll-pi and phc2sys
        cd /opt/microchip/japll-pi-controller/ && ./japll-pi > /dev/null 2>&1 &
        echo "  japll-pi started (PID: $!)"
        echo "Done."
        ;;
    0)
        echo "Deleting VLAN interface: $VLAN_IFACE"
        ip link set $VLAN_IFACE down 2>/dev/null
        ip link del $VLAN_IFACE 2>/dev/null
        # Kill services
        pkill -f "ptp_reader.sh" 2>/dev/null
        pkill -f "get_motor_params.py" 2>/dev/null
        pkill -f "japll-pi" 2>/dev/null
        echo "  Services killed"
        echo "Done."
        ;;
    status)
        if ip link show $VLAN_IFACE > /dev/null 2>&1; then
            echo "$VLAN_IFACE exists:"
            ip addr show $VLAN_IFACE
        else
            echo "$VLAN_IFACE does not exist"
        fi
        echo
        echo "Services:"
        pgrep -af ptp_reader || echo "  ptp_reader.sh: not running"
        pgrep -af get_motor_params || echo "  get_motor_params.py: not running"
        pgrep -af japll-pi || echo "  japll-pi: not running"
        ;;
    *)
        echo "Usage: $0 {talker|listener|0|status}"
        echo "  talker - Create VLAN ($VLAN_IFACE, IP=192.168.13.10/24) + PTP + motor listener"
        echo "  listener - Create VLAN ($VLAN_IFACE, IP=192.168.13.20/24) + japll-pi"
        echo "  0      - Delete VLAN + kill services"
        echo "  status - Show interface + service status"
        ;;
esac
