FILESEXTRAPATHS:prepend:mpfs := "${THISDIR}/files:"

SRC_URI:append:mpfs-video-kit-all = "${UBOOT_FILES}"
SRC_URI:append:mpfs-motor-control-kit = "${UBOOT_FILES}"
SRC_URI:append:mpfs-motor-control-kit-bldc = "${UBOOT_FILES}"

SRCREV = "440cc42c3426dd06e25b9077f780f0b30661cca4"

