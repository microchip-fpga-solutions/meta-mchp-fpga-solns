FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

COMPATIBLE_MACHINE:append:mpfs-video-kit-all = "|mpfs-video-kit-all"
COMPATIBLE_MACHINE:append:mpfs-motor-control-kit = "|mpfs-motor-control-kit"
COMPATIBLE_MACHINE:append:mpfs-motor-control-kit-bldc = "|mpfs-motor-control-kit-bldc"

DT_FILES_PATH:mpfs-video-kit-all = "${WORKDIR}/git/mpfs_video"
DT_FILES_PATH:mpfs-motor-control-kit = "${WORKDIR}/git/mpfs_motor_control"
DT_FILES_PATH:mpfs-motor-control-kit-bldc = "${WORKDIR}/git/mpfs_motor_control"

BRANCH = "next"
SRCREV = "e85fec7e3d03be8a034dbba602f39a8169132c7a"
SRC_URI = "git://github.com/microchip-fpga-solutions/dt-overlay4polarfire.git;protocol=https;branch=${BRANCH}"


