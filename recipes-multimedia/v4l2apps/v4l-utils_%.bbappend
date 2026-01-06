FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append:mpfs-video-kit-all = " \
	file://0001-media-bus-format-header-update.patch \
"

