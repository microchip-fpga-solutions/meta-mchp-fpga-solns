FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

KBRANCH = "linux-6.18-mchp+fpga"
SRCREV = "87ed9da80785bd912b0e765d02ba71f01d0489e3"
SRC_URI = "git://github.com/microchip-fpga-solutions/linux4polarfire.git;protocol=https;branch=${KBRANCH}"

SRC_URI:append:mpfs-video-kit-raw-bayer = " \
	file://mpfs-v4l2.cfg \
"

SRC_URI:append:mpfs-video-kit-h264 = " \
	file://mpfs-v4l2-h264.cfg \
"

SRC_URI:append:mpfs-video-kit-h264-mm = " \
	file://mpfs-v4l2-h264-mm.cfg \
"

SRC_URI:append:mpfs-video-kit-tsn = " \
	file://mpfs-tsn.cfg \
"

SRC_URI:append:mpfs-video-kit-drm = " \
	file://mpfs-v4l2-drm.cfg \
"

SRC_URI:append:mpfs-motor-control-kit = " \
    file://mpfs_genaric.cfg \
"

