SUMMARY = "Package group for TSN software and libraries."

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PROVIDES = "${PACKAGES}"
PACKAGES = " \
    packagegroup-mchp-tsn \
"

RDEPENDS:packagegroup-mchp-tsn = "\
    ffmpeg \
    apache2 \
    php \
    php-cli \
    php-fpm \
    php-cgi \
    php-modphp \
    sudo \
    v4l2-start-service \
    videokit-webdemo \
    python3-asyncua \
    openssl \
    openssl-engines \
    linux-firmware-microchip \
    linuxptp \
    vim \
    packagegroup-core-buildessential \
    cjson \
    cjson-dev \
"
