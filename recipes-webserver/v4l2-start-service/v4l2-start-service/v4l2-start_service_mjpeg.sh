#!/bin/bash
v4l2-ctl --device /dev/video0 --set-fmt-video=width=1920,height=1080,pixelformat=MJPG
/usr/bin/v4l2-ctl -d /dev/video0  --all | grep "Pixel Format" | awk '{print $4}' > /srv/www/board
/usr/bin/v4l2-ctl -d /dev/video0 --set-ctrl=brightness=137 --set-ctrl=contrast=154 --set-ctrl=gain_red=122 --set-ctrl=gain_green=102 --set-ctrl=gain_blue=138
sleep 1

