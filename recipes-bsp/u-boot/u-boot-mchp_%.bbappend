FILESEXTRAPATHS:prepend:mpfs := "${THISDIR}/files:"

SRC_URI:append:mpfs-video-kit-all = "${UBOOT_FILES}"
SRC_URI:append:mpfs-motor-control-kit = "${UBOOT_FILES}"

