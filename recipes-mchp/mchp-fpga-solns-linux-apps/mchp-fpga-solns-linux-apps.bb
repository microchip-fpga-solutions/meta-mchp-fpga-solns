SUMMARY = "Polarfire SoC Solutions Linux example applications"
DESCRIPTION = "Linux Example applications, includes the following: \
    - multimedia tsn japll-pi-controller opcua."

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${WORKDIR}/git/LICENSE;md5=06ec214e9fafe6d4515883d77674a453"

inherit python3-dir systemd

DEPENDS:append:mpfs-video-kit-tsn = " cjson"
DEPENDS:append:mpfs-video-kit-drm = " libdrm"


# Motor control BLDC dependencies for pybind11 build
DEPENDS:append:mpfs-motor-control-kit-bldc = " cmake-native python3-pybind11-native python3-native python3-pybind11"

RDEPENDS:${PN}-raw-bayer-capture += "\
    media-ctl \
    fswebcam \
    v4l-utils \
    "

RDEPENDS:${PN}-motor-control-bldc += "\
    python3 \
    python3-bokeh \
    "

# Systemd service for motor control module loading
SYSTEMD_PACKAGES:mpfs-motor-control-kit-bldc = "${PN}-motor-control-bldc"
SYSTEMD_SERVICE:${PN}-motor-control-bldc = "motor-modules.service"
SYSTEMD_AUTO_ENABLE:${PN}-motor-control-bldc = "enable"



PV = "1.0+git${SRCPV}"

SRCREV = "74cb47f7cbed40364f6a8e2f0281cb819bc6fd09"
SRC_URI = "git://github.com/microchip-fpga-solutions/mchp-fpga-solns-linux-apps.git;protocol=https;nobranch=1"

S = "${WORKDIR}/git"

PACKAGES = " \
    ${PN}-tsn \
    ${PN}-raw-bayer-capture \
    ${PN}-auto-gain-osd-h264 \
    ${PN}-japll-pi-controller \
    ${PN}-opcua \
    ${PN}-gst-cam-display \
    ${PN}-cam2display-zerocopy \
    ${PN}-rgb-jpeg-capture \
    ${PN}-drm-display-tests \
    ${PN}-motor-control-bldc \
"

SECURITY_CFLAGS = ""

# Apply INSANE_SKIP flags to all packages listed (alphabetical order)
INSANE_SKIP:${PN}-tsn += "file-rdeps ldflags debug-files"
INSANE_SKIP:${PN}-raw-bayer-capture += "file-rdeps ldflags debug-files"
INSANE_SKIP:${PN}-auto-gain-osd-h264 += "file-rdeps ldflags debug-files"
INSANE_SKIP:${PN}-japll-pi-controller += "file-rdeps ldflags debug-files"
INSANE_SKIP:${PN}-opcua  += "file-rdeps ldflags debug-files"
INSANE_SKIP:${PN}-gst-cam-display += "file-rdeps ldflags debug-files"
INSANE_SKIP:${PN}-cam2display-zerocopy += "file-rdeps ldflags debug-files"
INSANE_SKIP:${PN}-rgb-jpeg-capture += "file-rdeps ldflags debug-files"
INSANE_SKIP:${PN}-drm-display-tests += "file-rdeps ldflags debug-files"
INSANE_SKIP:${PN}-motor-control-bldc += "file-rdeps ldflags debug-files dev-so staticdev buildpaths"

EXAMPLE_FILES:append:mpfs-video-kit-raw-bayer = "\
    multimedia/raw-bayer-capture \
    "

EXAMPLE_FILES:append:mpfs-video-kit-h264-mm = "\
    multimedia/auto-gain-osd-h264 \
    "

EXAMPLE_FILES:append:mpfs-video-kit-drm = "\
    multimedia/gst-cam-display \
    multimedia/cam2display-zerocopy \
    multimedia/rgb-jpeg-capture \
    multimedia/drm-display-tests \
    "

EXAMPLE_FILES:append:mpfs-video-kit-tsn = "\
    tsn \
    japll-pi-controller \
    opcua \
    "

# Motor control BLDC - separate build using cmake
EXAMPLE_FILES:append:mpfs-motor-control-kit-bldc = "\
    motor-control-bldc \
    "



do_compile() {
  for i in ${EXAMPLE_FILES}; do
    if [ -f ${S}/$i/Makefile ]; then
      oe_runmake -C ${S}/$i
    fi
  done
}



# Compile motor control C++ library with pybind11
do_compile:append:mpfs-motor-control-kit-bldc() {
    if [ -d ${S}/motor-control-bldc/lib ]; then
        mkdir -p ${S}/motor-control-bldc/lib/build
        cd ${S}/motor-control-bldc/lib/build

        # Extract just the compiler binary (CC/CXX include --sysroot which cmake can't parse)
        REAL_CC=$(echo ${CC} | awk '{print $1}')
        REAL_CXX=$(echo ${CXX} | awk '{print $1}')

        # Find Python version in sysroot (e.g., python3.12 -> 312)
        PYTHON_VER=$(ls ${STAGING_INCDIR} | grep -E '^python3\.[0-9]+$' | head -1)
        PYTHON_VER_NUM=$(echo $PYTHON_VER | sed 's/python//' | tr -d '.')

        cmake .. \
            -DCMAKE_CXX_COMPILER="$REAL_CXX" \
            -DCMAKE_C_COMPILER="$REAL_CC" \
            -DCMAKE_CXX_FLAGS="${CXXFLAGS} -fPIC" \
            -DCMAKE_C_FLAGS="${CFLAGS} -fPIC" \
            -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
            -DCMAKE_SYSROOT="${STAGING_DIR_TARGET}" \
            -DCMAKE_INSTALL_PREFIX=${prefix} \
            -DPYTHON_INCLUDE_DIRS="${STAGING_INCDIR}/$PYTHON_VER" \
            -DPYTHON_LIBRARIES="${STAGING_LIBDIR}/lib${PYTHON_VER}.so" \
            -DPYTHON_EXECUTABLE="${STAGING_BINDIR_NATIVE}/python3-native/python3" \
            -DPYTHON_MODULE_EXTENSION=".cpython-${PYTHON_VER_NUM}-riscv64-linux-gnu.so" \
            -Dpybind11_DIR="${STAGING_LIBDIR}/cmake/pybind11" \
            -Wno-dev
        oe_runmake
    fi
}



do_install() {
    if [ -n "${EXAMPLE_FILES}" ]; then
        install -d ${D}/opt/microchip
        chmod a+x ${D}/opt/microchip

        for i in ${EXAMPLE_FILES}; do
            install -d ${D}/opt/microchip/$(dirname $i)/$(basename $i)
            cp -rfd ${S}/$i ${D}/opt/microchip/$(dirname $i)
        done
    fi
}

do_install:append:mpfs-video-kit-tsn() {
    rm -rf ${D}/opt/microchip/opcua/icicle-kit
}

# Install motor control BLDC files
do_install:append:mpfs-motor-control-kit-bldc() {
    # Install Python applications to /opt/microchip/motor-control-bldc
    install -d ${D}/opt/microchip/motor-control-bldc/app
    install -m 0755 ${S}/motor-control-bldc/app/gui.py ${D}/opt/microchip/motor-control-bldc/app/
    install -m 0755 ${S}/motor-control-bldc/app/sub.py ${D}/opt/microchip/motor-control-bldc/app/
    install -m 0755 ${S}/motor-control-bldc/app/motor_control_startup.sh ${D}/opt/microchip/motor-control-bldc/app/

    # Install Python module (.so file) to Python site-packages
    install -d ${D}${PYTHON_SITEPACKAGES_DIR}
    install -m 0755 ${S}/motor-control-bldc/lib/build/motor_lib_py*.so ${D}${PYTHON_SITEPACKAGES_DIR}/

    # Install header files for C++ API access
    install -d ${D}${includedir}/motor-control
    install -m 0644 ${S}/motor-control-bldc/lib/motor.h ${D}${includedir}/motor-control/
    install -m 0644 ${S}/motor-control-bldc/lib/motorclass_def.h ${D}${includedir}/motor-control/

    # Install module loader script
    install -d ${D}/opt/microchip/motor-control-bldc/scripts
    install -m 0755 ${S}/motor-control-bldc/scripts/load-motor-modules.sh ${D}/opt/microchip/motor-control-bldc/scripts/

    # Install systemd service
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/motor-control-bldc/scripts/motor-modules.service ${D}${systemd_system_unitdir}/

    # Remove cmake build artifacts that got copied by base do_install
    rm -rf ${D}/opt/microchip/motor-control-bldc/lib/build
}

FILES:${PN}-raw-bayer-capture = "/opt/microchip/multimedia/raw-bayer-capture"
FILES:${PN}-auto-gain-osd-h264 = "/opt/microchip/multimedia/auto-gain-osd-h264"
FILES:${PN}-gst-cam-display = "/opt/microchip/multimedia/gst-cam-display"
FILES:${PN}-cam2display-zerocopy = "/opt/microchip/multimedia/cam2display-zerocopy"
FILES:${PN}-rgb-jpeg-capture = "/opt/microchip/multimedia/rgb-jpeg-capture"
FILES:${PN}-drm-display-tests = "/opt/microchip/multimedia/drm-display-tests"
FILES:${PN}-tsn = "/opt/microchip/tsn"
FILES:${PN}-japll-pi-controller = "/opt/microchip/japll-pi-controller"
FILES:${PN}-opcua = "/opt/microchip/opcua"
FILES:${PN}-motor-control-bldc = "\
    /opt/microchip/motor-control-bldc \
    ${PYTHON_SITEPACKAGES_DIR} \
    ${includedir}/motor-control \
    ${systemd_system_unitdir}/motor-modules.service \
"
ALLOW_EMPTY:${PN} = "1"
