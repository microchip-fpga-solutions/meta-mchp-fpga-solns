SUMMARY = "Polarfire SoC Solutions Linux example applications"
DESCRIPTION = "Linux Example applications, includes the following: \
    - multimedia tsn japll-pi-controller opcua."

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${WORKDIR}/git/LICENSE;md5=06ec214e9fafe6d4515883d77674a453"

DEPENDS:append:mpfs-video-kit-tsn = " cjson"

RDEPENDS:${PN}-v4l2 += "\
    media-ctl \
    fswebcam \
    v4l-utils \
    "

PV = "1.0+git${SRCPV}"

SRCREV = "6f3acf15dcd080ed776b4b43b1bc411c5b1ee2cf"
SRC_URI = "git://github.com/microchip-fpga-solutions/mchp-fpga-solns-linux-apps.git;protocol=https;nobranch=1"

S = "${WORKDIR}/git"

PACKAGES = " \
    ${PN}-tsn \
    ${PN}-v4l2 \
    ${PN}-auto-enhance-osd \
    ${PN}-japll-pi-controller \
    ${PN}-opcua \
"

SECURITY_CFLAGS = ""

# Apply INSANE_SKIP flags to all packages listed (alphabetical order)
INSANE_SKIP:${PN}-tsn += "file-rdeps ldflags debug-files"
INSANE_SKIP:${PN}-v4l2 += "file-rdeps ldflags debug-files"
INSANE_SKIP:${PN}-auto-enhance-osd += "file-rdeps ldflags debug-files"
INSANE_SKIP:${PN}-japll-pi-controller += "file-rdeps ldflags debug-files"
INSANE_SKIP:${PN}-opcua  += "file-rdeps ldflags debug-files"

EXAMPLE_FILES:append = "\
    multimedia/v4l2 \
    multimedia/auto-enhance-osd \
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

FILES:${PN}-v4l2 = "/opt/microchip/multimedia/v4l2"
FILES:${PN}-auto-enhance-osd = "/opt/microchip/multimedia/auto-enhance-osd"
FILES:${PN}-tsn = "/opt/microchip/tsn"
FILES:${PN}-japll-pi-controller = "/opt/microchip/japll-pi-controller"
FILES:${PN}-opcua = "/opt/microchip/opcua"
ALLOW_EMPTY:${PN} = "1"
