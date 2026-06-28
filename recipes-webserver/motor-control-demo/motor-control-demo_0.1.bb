DESCRIPTION = "Web server application showcasing video streaming over Ethernet \
using the Polarfire SoC Video kit's Video4Linux pipeline"

SECTION = "examples"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"
PR = "r0"

RDEPENDS:${PN} += "bash"
INSANE_SKIP:${PN} += "already-stripped"
UART_PATH="/srv/www/tsn/uart"
SYSTEM_CONF="/etc"

SRC_URI:append = "file://. "

do_install:append () {
	install -d ${D}${UART_PATH}
	install -m 0755 ${WORKDIR}/tsn/uart/* ${D}${UART_PATH}

	chown -R 1:root ${D}${WEB_PATH}/
}

FILES:${PN} += "${UART_PATH}/*"

COMPATIBLE_MACHINE = "mpfs-motor-control-kit-tsn"
