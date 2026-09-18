/srv/www/mjpeg/stop.sh > /srv/www/mjpeg/kill_messages

SERVER="192.168.1.1"
test $1 && SERVER=$1

v4l2-ctl -d /dev/v4l-subdev0 --set-ctrl=vertical_blanking=1170
v4l2-ctl -d /dev/v4l-subdev0 --set-ctrl=analogue_gain=80
v4l2-ctl -d /dev/video0 --set-ctrl=gain_automatic=1

ffmpeg -s 1920x1080 -i /dev/video0 -c:v copy -f rtp -sdp_file video.sdp "rtp://$SERVER:10000" </dev/null  >/srv/www/mjpeg/messages 2>/srv/www/mjpeg/error_log &

sleep 3

echo "a=rtpmap:26 JPEG/90000" >> /srv/www/mjpeg/video.sdp

