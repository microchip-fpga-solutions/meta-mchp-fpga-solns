#!/bin/sh
Brightness=128
Contrast=128
Quality=50
Color_Balance_Red=128
Color_Balance_Green=128
Color_Balance_Blue=128
/usr/bin/v4l2-ctl -d /dev/video0 --set-ctrl=quality_factor=30 --set-ctrl=brightness=137 --set-ctrl=contrast=154 --set-ctrl=gain_red=122 --set-ctrl=gain_green=102 --set-ctrl=gain_blue=138
#v4l2-ctl --device /dev/video0 --set-fmt-video=width=1280,height=720
