echo "Please copy the video.sdp file from Server to the Client"
ffplay -protocol_whitelist file,rtp,udp -fflags nobuffer -probesize 32 -analyzeduration 0 -sync ext -i video.sdp
