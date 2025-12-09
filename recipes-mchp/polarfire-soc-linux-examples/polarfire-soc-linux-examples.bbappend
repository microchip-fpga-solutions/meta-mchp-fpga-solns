RDEPENDS:${PN}-v4l2 += "\
    media-ctl \
    fswebcam \
    v4l-utils \
    "

PACKAGES += " \
    ${PN}-v4l2 \
"

INSANE_SKIP:${PN}-v4l2 += "file-rdeps ldflags debug-files"

EXAMPLE_FILES:append = "\
    multimedia/v4l2 \
    "

FILES:${PN}-v4l2 = "/opt/microchip/multimedia/v4l2"

