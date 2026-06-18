FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

COMPATIBLE_MACHINE:append:mpfs-video-kit-all = "|mpfs-video-kit-all"
COMPATIBLE_MACHINE:append:mpfs-motor-control-kit = "|mpfs-motor-control-kit"

DT_FILES_PATH:mpfs-video-kit-all = "${WORKDIR}/git/mpfs_video"
DT_FILES_PATH:mpfs-motor-control-kit = "${WORKDIR}/git/mpfs_motor_control"

BRANCH = "next"
SRCREV = "b76aeb115e731f39403f645d9fa6419bd6b353b2"
SRC_URI = "git://github.com/microchip-fpga-solutions/dt-overlay4polarfire.git;protocol=https;branch=${BRANCH}"

SRC_URI:append:mpfs-motor-control-kit = "  \
	file://0001-mpfs_motor_control-test-overlay.patch \
	"

