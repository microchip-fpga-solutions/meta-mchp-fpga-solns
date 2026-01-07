FILESEXTRAPATHS:prepend:mpfs := "${THISDIR}/files:"

SRC_URI:append:mpfs-video-kit-all = "\
	file://0001-multimedia-auto-enhance-osd-relocate.patch \
"

RDEPENDS:${PN}-v4l2 += "\
    media-ctl \
    fswebcam \
    v4l-utils \
    "

PACKAGES += " \
    ${PN}-v4l2 \
    ${PN}-auto-enhance-osd \
"

INSANE_SKIP:${PN}-v4l2 += "file-rdeps ldflags debug-files"
INSANE_SKIP:${PN}-auto-enhance-osd += "file-rdeps ldflags debug-files"

EXAMPLE_FILES:append = "\
    multimedia/v4l2 \
    multimedia/auto-enhance-osd \
    "

FILES:${PN}-v4l2 = "/opt/microchip/multimedia/v4l2"
FILES:${PN}-auto-enhance-osd = "/opt/microchip/multimedia/auto-enhance-osd"

