FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

COMPATIBLE_MACHINE:append:mpfs-video-kit-all = "|mpfs-video-kit-all"
COMPATIBLE_MACHINE:append:mpfs-motor-control-kit = "|mpfs-motor-control-kit"
COMPATIBLE_MACHINE:append:mpfs-motor-control-kit-bldc = "|mpfs-motor-control-kit-bldc"
COMPATIBLE_MACHINE:append:mpfs-motor-control-kit-tsn = "|mpfs-motor-control-kit-tsn"

DT_FILES_PATH:mpfs-video-kit-all = "${WORKDIR}/git/mpfs_video"
DT_FILES_PATH:mpfs-motor-control-kit = "${WORKDIR}/git/mpfs_motor_control"
DT_FILES_PATH:mpfs-motor-control-kit-bldc = "${WORKDIR}/git/mpfs_motor_control"
DT_FILES_PATH:mpfs-motor-control-kit-tsn = "${WORKDIR}/git/mpfs_motor_control"

DTPOLARFIRE_SRC_URI = " git://github.com/microchip-fpga-solutions/dt-overlay4polarfire.git;protocol=https;branch=linux4microchip-2026.04+fpga;destsuffix=git-dtpolarfire;name=dtpolarfire"
DTPOLARFIRE_SRCREV = "72d8c5ab177e68f7ec3e134392b4bcc2e44688ae"

SRCREV_FORMAT = "dtpolarfire"
SRCREV_dtpolarfire:mpfs-motor-control-kit-tsn = "${DTPOLARFIRE_SRCREV}"
SRCREV_dtpolarfire:mpfs-motor-control-kit-bldc = "${DTPOLARFIRE_SRCREV}"

SRC_URI:append:mpfs-motor-control-kit-tsn = "${DTPOLARFIRE_SRC_URI}"
SRC_URI:append:mpfs-motor-control-kit-bldc = "${DTPOLARFIRE_SRC_URI}"

do_copy_dtpolarfire_overlays() {
    # Copy extra overlays from dt-overlay4polarfire into the main source tree
    if [ -d "${WORKDIR}/git-dtpolarfire/mpfs_motor_control" ]; then
        mkdir -p ${S}/mpfs_motor_control
        cp -f ${WORKDIR}/git-dtpolarfire/mpfs_motor_control/* ${S}/mpfs_motor_control/
    fi
    if [ -d "${WORKDIR}/git-dtpolarfire/mpfs_video" ]; then
        mkdir -p ${S}/mpfs_video
        cp -f ${WORKDIR}/git-dtpolarfire/mpfs_video/* ${S}/mpfs_video/
    fi
}
addtask copy_dtpolarfire_overlays after do_unpack before do_compile
