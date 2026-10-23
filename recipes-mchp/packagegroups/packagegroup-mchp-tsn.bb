SUMMARY = "Package group for TSN software and libraries."

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PROVIDES = "${PACKAGES}"
PACKAGES = " \
    packagegroup-mchp-tsn \
"

RDEPENDS:packagegroup-mchp-tsn = "\
    apache2 \
    php \
    php-cli \
    php-fpm \
    php-cgi \
    php-modphp \
    sudo \
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
