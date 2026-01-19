FILESEXTRAPATHS:prepend:mpfs := "${THISDIR}/files:"

SRC_URI:append:mpfs-video-kit-all = "\
	file://0001-multimedia-auto-enhance-osd-relocate.patch \
"

DEPENDS:append:mpfs-video-kit-tsn = " cjson"

RDEPENDS:${PN}-v4l2 += "\
    media-ctl \
    fswebcam \
    v4l-utils \
    "

PACKAGES += " \
    ${PN}-v4l2 \
    ${PN}-auto-enhance-osd \
    ${PN}-tsn \
    ${PN}-japll-pi-controller \
    ${PN}-opcua  \
"

INSANE_SKIP:${PN}-v4l2 += "file-rdeps ldflags debug-files"
INSANE_SKIP:${PN}-auto-enhance-osd += "file-rdeps ldflags debug-files"
INSANE_SKIP:${PN}-japll-pi-controller += "file-rdeps ldflags debug-files"
INSANE_SKIP:${PN}-tsn += "file-rdeps ldflags debug-files"
INSANE_SKIP:${PN}-opcua  += "file-rdeps ldflags debug-files"

EXAMPLE_FILES:append = "\
    multimedia/v4l2 \
    multimedia/auto-enhance-osd \
    "

EXAMPLE_FILES:append:mpfs-video-kit-tsn = "\
    tsn \
    japll-pi-controller \
    opcua \
    "

do_install:append:mpfs-video-kit-tsn() {
    rm -rf ${D}/opt/microchip/opcua/icicle-kit
}

FILES:${PN}-v4l2 = "/opt/microchip/multimedia/v4l2"
FILES:${PN}-auto-enhance-osd = "/opt/microchip/multimedia/auto-enhance-osd"
FILES:${PN}-tsn = "/opt/microchip/tsn"
FILES:${PN}-japll-pi-controller = "/opt/microchip/japll-pi-controller"
FILES:${PN}-opcua  = "/opt/microchip/opcua"

