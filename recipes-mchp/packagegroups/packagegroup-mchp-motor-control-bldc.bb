SUMMARY = "Package group for Motor Control BLDC."

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PROVIDES = "${PACKAGES}"
PACKAGES = " \
    packagegroup-mchp-motor-control-bldc \
"

RDEPENDS:packagegroup-mchp-motor-control-bldc = "\
    mchp-fpga-solns-linux-apps-motor-control-bldc \
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
    ros-core \
"
