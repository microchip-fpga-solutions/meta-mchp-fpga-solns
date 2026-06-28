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

IMAGE_INSTALL:append:mpfs-video-kit-tsn = " \
    packagegroup-mchp-tsn \
"

IMAGE_INSTALL:append:mpfs-video-kit-drm = " \
    packagegroup-mchp-graphics \
    packagegroup-mchp-drm \
    packagegroup-mchp-drm-gstreamer \
"

IMAGE_INSTALL:append:mpfs-motor-control-kit = " \
	polarfire-soc-linux-examples-dt-overlays \
	polarfire-soc-linux-examples-pdma \
"

IMAGE_INSTALL:append:mpfs-motor-control-kit-bldc = " \
    packagegroup-mchp-motor-control-bldc \
"

IMAGE_INSTALL:append:mpfs-motor-control-kit-tsn = " \
    packagegroup-mchp-motor-control-tsn \
"

