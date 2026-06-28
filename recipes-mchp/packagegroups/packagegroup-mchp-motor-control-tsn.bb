SUMMARY = "Package group for Motor Control Kit with TSN."
DESCRIPTION = "Combines motor control BLDC, TSN networking, and JAPLL PI controller applications."

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PROVIDES = "${PACKAGES}"
PACKAGES = " \
    packagegroup-mchp-motor-control-tsn \
"

RDEPENDS:packagegroup-mchp-motor-control-tsn = "\
    mchp-fpga-solns-linux-apps-motor-control-bldc \
    mchp-fpga-solns-linux-apps-tsn \
    mchp-fpga-solns-linux-apps-japll-pi-controller \
    polarfire-soc-linux-examples-dt-overlays \
    libiio \
    python3-bokeh \
    python3 \
    python3-pip \
    libgpiod \
    libgpiod-tools \
    i2c-tools \
    can-utils \
    devmem2 \
    dtc \
    htop \
    nano \
    linuxptp \
    ffmpeg \
    apache2 \
    php \
    php-cli \
    php-fpm \
    php-cgi \
    sudo \
    v4l2-start-service \
    python3-asyncua \
    openssl \
    openssl-engines \
    linux-firmware-microchip \
    vim \
    packagegroup-core-buildessential \
    cjson \
    cjson-dev \
"
