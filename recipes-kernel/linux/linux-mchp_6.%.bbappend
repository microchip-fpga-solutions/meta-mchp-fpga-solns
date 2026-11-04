FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRCREV = "31dca4a2b554a9ea57216bb1638bc54580615aad"

SRC_URI:append:mpfs-video-kit-raw-bayer = " \
	file://mpfs-v4l2.cfg \
"

SRC_URI:append:mpfs-video-kit-h264 = " \
	file://mpfs-v4l2-h264.cfg \
"

SRC_URI:append:mpfs-video-kit-mjpeg = " \
	file://mpfs-v4l2-mjpeg.cfg \
"

SRC_URI:append:mpfs-video-kit-h264-mm = " \
	file://mpfs-v4l2-h264-mm.cfg \
"

SRC_URI:append:mpfs-video-kit-tsn = " \
	file://mpfs-tsn.cfg \
"

SRC_URI:append:mpfs-video-kit-drm = " \
	file://mpfs-v4l2-drm.cfg \
"

SRC_URI:append:mpfs-motor-control-kit = " \
    file://mpfs_generic.cfg \
"

SRC_URI:append:mpfs-motor-control-kit-bldc = " \
    file://motor-control.cfg \
"

SRC_URI:append:mpfs-motor-control-kit-tsn = " \
    file://motor-control.cfg \
    file://mpfs_generic.cfg \
    file://mpfs-tsn.cfg \
"

# Ensure the FIT image is only assembled after the device-tree overlays
# have been deployed, so the FIT packaging step can pick them up.
do_assemble_fitimage[depends] += "dt-overlay-mchp:do_deploy"

SRCREV_linux4polarfire-explore:mpfs-video-kit-all = "${AUTOREV}"
SRC_URI:append:mpfs-video-kit-all = " \
        git://github.com/microchip-fpga-solutions/linux4polarfire.git;protocol=https;branch=linux-6.18-mchp+fpga+2026.04;name=linux4polarfire-explore;destsuffix=linux4polarfire-explore \
"

DRM_PATCHES_DIR = "${WORKDIR}/linux4polarfire-explore/drivers/gpu/drm/microchip/files/linux-6.18-2026.04/"
V4L2_PATCHES_DIR = "${WORKDIR}/linux4polarfire-explore/drivers/media/files/linux-6.18-2026.04/"

do_patch:append:mpfs-video-kit-all() {
        for patch in ${V4L2_PATCHES_DIR}/*.patch; do
                if [ -f "$patch" ]; then
                        cd ${S}
                        git am "$patch"
                fi
        done

        for patch in ${DRM_PATCHES_DIR}/*.patch; do
                if [ -f "$patch" ]; then
                        cd ${S}
                        git am "$patch"
                fi
        done
}

