SUMMARY = "Package group for Motor Control BLDC with camera support."
DESCRIPTION = "Optional vision packages for motor control kit - adds OpenCV, image processing, and camera support."

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PROVIDES = "${PACKAGES}"
PACKAGES = " \
    packagegroup-mchp-motor-control-bldc-vision \
"

RDEPENDS:packagegroup-mchp-motor-control-bldc-vision = "\
    opencv \
    cv-bridge \
    image-transport \
    image-proc \
    image-view \
    image-pipeline \
    stereo-image-proc \
    compressed-image-transport \
    theora-image-transport \
    v4l2-camera \
    camera-info-manager \
"
