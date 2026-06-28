FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

COMPATIBLE_MACHINE:append:mpfs-video-kit-all = "|mpfs-video-kit-all"
COMPATIBLE_MACHINE:append:mpfs-motor-control-kit = "|mpfs-motor-control-kit"
COMPATIBLE_MACHINE:append:mpfs-motor-control-kit-bldc = "|mpfs-motor-control-kit-bldc"
COMPATIBLE_MACHINE:append:mpfs-motor-control-kit-tsn = "|mpfs-motor-control-kit-tsn"

DT_FILES_PATH:mpfs-video-kit-all = "${WORKDIR}/git/mpfs_video"
DT_FILES_PATH:mpfs-motor-control-kit = "${WORKDIR}/git/mpfs_motor_control"
DT_FILES_PATH:mpfs-motor-control-kit-bldc = "${WORKDIR}/git/mpfs_motor_control"
DT_FILES_PATH:mpfs-motor-control-kit-tsn = "${WORKDIR}/git/mpfs_motor_control"

BRANCH = "next"
SRCREV = "c0a77d736c9ba0d77afca81209daddd567967fe8"
SRC_URI = "git://github.com/microchip-fpga-solutions/dt-overlay4polarfire.git;protocol=https;branch=${BRANCH}"


