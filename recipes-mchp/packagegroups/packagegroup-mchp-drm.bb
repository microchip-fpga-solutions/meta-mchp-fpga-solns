SUMMARY = "Package group for h264 software and libraries."

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PROVIDES = "${PACKAGES}"
PACKAGES = " \
    packagegroup-mchp-drm \
    packagegroup-mchp-drm-gstreamer \
"

RDEPENDS:packagegroup-mchp-drm = "\
    libdrm \
    libdrm-tests \
    libegt \
    egt-samples egt-benchmark \
    v4l-utils \
    fswebcam \
    media-ctl \
"

RDEPENDS:packagegroup-mchp-drm-gstreamer = "\
    gstreamer1.0 \
    ${@bb.utils.contains("LICENSE_FLAGS_ACCEPTED", "commercial", "gstreamer1.0-libav", "", d)} \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    ${@bb.utils.contains("LICENSE_FLAGS_ACCEPTED", "commercial", "gstreamer1.0-plugins-ugly", "", d)} \
"

