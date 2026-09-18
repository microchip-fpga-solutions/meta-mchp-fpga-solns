SUMMARY = "Package group for mjpeg software and libraries."

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PROVIDES = "${PACKAGES}"
PACKAGES = " \
    packagegroup-mchp-mjpeg \
    packagegroup-mchp-mjpeg-gstreamer \
"

RDEPENDS:packagegroup-mchp-multimedia = "\
    ${@bb.utils.contains("LICENSE_FLAGS_ACCEPTED", "commercial", "ffmpeg", "", d)} \
"

RDEPENDS:packagegroup-mchp-mjpeg = "\
    ffmpeg \
    apache2 \
    php \
    php-cli \
    php-fpm \
    php-cgi \
    php-modphp \
    sudo \
    v4l2-start-service \
    v4l-utils \
    videokit-webdemo \
    fswebcam \
    x264 \
    python3-asyncua \
    openssl \
    openssl-engines \
"

RDEPENDS:packagegroup-mchp-mjpeg-gstreamer = "\
    gstreamer1.0 \
    ${@bb.utils.contains("LICENSE_FLAGS_ACCEPTED", "commercial", "gstreamer1.0-libav", "", d)} \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    ${@bb.utils.contains("LICENSE_FLAGS_ACCEPTED", "commercial", "gstreamer1.0-plugins-ugly", "", d)} \
"

