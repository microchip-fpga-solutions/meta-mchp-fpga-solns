IMAGE_INSTALL:append = "\
    packagegroup-mchp-apps \
    packagegroup-mchp-security \
"

IMAGE_INSTALL:append:mpfs-video-kit-h264 = " \
    packagegroup-mchp-h264 \
"

IMAGE_INSTALL:append:mpfs-video-kit-h264-mm = " \
    packagegroup-mchp-h264 \
"

