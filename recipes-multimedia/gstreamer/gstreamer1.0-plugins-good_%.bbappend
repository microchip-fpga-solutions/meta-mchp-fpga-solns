FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

ERROR_QA:remove = "patch-status"

SRC_URI:append:mpfs-video-kit = " \
	file://0001-gst-v4l2src-sys-gstv4l2object-min-buffer-count-incre.patch \
"

SRC_URI:append:mpfs-video-kit-drm = " \
	file://0001-gst-v4l2src-sys-gstv4l2object-min-buffer-count-incre.patch \
"

