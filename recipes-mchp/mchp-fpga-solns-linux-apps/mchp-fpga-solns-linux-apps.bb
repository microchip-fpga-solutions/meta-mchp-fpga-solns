SUMMARY = "Polarfire SoC Solutions Linux example applications"
DESCRIPTION = "Linux Example applications, includes the following: \
    - multimedia tsn japll-pi-controller opcua."

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${WORKDIR}/git/LICENSE;md5=06ec214e9fafe6d4515883d77674a453"

DEPENDS:append:mpfs-video-kit-tsn = " cjson"
DEPENDS:append:mpfs-video-kit-drm = " libdrm"

RDEPENDS:${PN}-raw-bayer-capture += "\
    media-ctl \
    fswebcam \
    v4l-utils \
    "

PV = "1.0+git${SRCPV}"

SRCREV = "08a0675a2eca23936116e900b91c4eab09bfa19f"
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

EXAMPLE_FILES:append = "\
    multimedia/raw-bayer-capture \
    multimedia/auto-gain-osd-h264 \
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

do_compile() {
  for i in ${EXAMPLE_FILES}; do
    if [ -f ${S}/$i/Makefile ]; then
      oe_runmake -C ${S}/$i
    fi
  done
}

do_install() {
    install -d ${D}/opt/microchip
    chmod a+x ${D}/opt/microchip

    for i in ${EXAMPLE_FILES}; do
        install -d ${D}/opt/microchip/$(dirname $i)/$(basename $i)
        cp -rfd ${S}/$i ${D}/opt/microchip/$(dirname $i)
    done
}

do_install:append:mpfs-video-kit-tsn() {
    rm -rf ${D}/opt/microchip/opcua/icicle-kit
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
ALLOW_EMPTY:${PN} = "1"
