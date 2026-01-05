FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append:mpfs-video-kit-raw-bayer = " \
	file://mpfs-v4l2.cfg \
"

SRC_URI:append:mpfs-video-kit-h264 = " \
	file://mpfs-v4l2-h264.cfg \
"

SRC_URI:append:mpfs-video-kit-h264-mm = " \
	file://mpfs-v4l2-h264-mm.cfg \
"

