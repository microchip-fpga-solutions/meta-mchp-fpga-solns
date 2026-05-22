COMPATIBLE_MACHINE:append:mpfs-video-kit-all = "|mpfs-video-kit-all"

DT_FILES_PATH:mpfs-video-kit-all = "${WORKDIR}/git/mpfs_video"

BRANCH = "linux4microchip-2026.04+fpga"
SRCREV = "cada2b4b4cee82d84756a131032ed0a55d370e7c"
SRC_URI = "git://github.com/microchip-fpga-solutions/dt-overlay4polarfire.git;protocol=https;branch=${BRANCH}"
 
