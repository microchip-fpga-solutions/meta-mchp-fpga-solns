SUMMARY = "Package group for h264 software and libraries."

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PROVIDES = "${PACKAGES}"
PACKAGES = " \
    packagegroup-mchp-h264 \
"

RDEPENDS:packagegroup-mchp-multimedia = "\
    ${@bb.utils.contains("LICENSE_FLAGS_ACCEPTED", "commercial", "ffmpeg", "", d)} \
"

RDEPENDS:packagegroup-mchp-h264 = "\
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
