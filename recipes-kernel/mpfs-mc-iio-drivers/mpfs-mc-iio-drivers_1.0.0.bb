HOMEPAGE = "https://github.com/microchip-fpga-solutions/linux4polarfire"
SUMMARY = "Microchip PolarFire SoC Motor Control IIO out-of-tree kernel drivers"
DESCRIPTION = "Out-of-tree IIO motor control drivers (ADC, PI controller, PWM, \
rate limiter, sequencer manager, stepper theta) for mpfs-motor-control-kit-bldc, \
from the linux4polarfire repository. Auto-discovers all driver \
subdirectories containing a Makefile via the top-level Makefile and builds \
them against the target kernel."

LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=a362c03f8df4e23f8a155e1cb2c45b2a"

inherit module

require ../linux4polarfire-drivers/linux4polarfire-src.inc

PV = "1.0.0"

S = "${WORKDIR}/git"

# Top-level Makefile auto-discovers all drivers/ subdirectories.
# New drivers added to the branch are built automatically.
#
# All six CONFIG_IIO_MPFS_MC_* symbols are declared "tristate" in the
# driver's own Kconfig (unlike CORE1588_HWTSTAMP in linux4polarfire-drivers),
# so "obj-$(CONFIG_IIO_MPFS_MC_*)" correctly expands to obj-m for an
# out-of-tree (M=) build without any extra workaround - just force =m here.
EXTRA_OEMAKE += "KERNEL_SRC=${STAGING_KERNEL_DIR} \
                  CONFIG_IIO_MPFS_MC_ADC=m \
                  CONFIG_IIO_MPFS_MC_PICON=m \
                  CONFIG_IIO_MPFS_MC_PWM=m \
                  CONFIG_IIO_MPFS_MC_RATELIM=m \
                  CONFIG_IIO_MPFS_MC_SQMNG=m \
                  CONFIG_IIO_MPFS_MC_STPTHETA=m \
                 "

do_install() {
    install -d ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra
    # linux4polarfire (branch linux-6.18-mchp+fpga+2026.04) also carries
    # drivers/net/ethernet/microchip/{coretse,coretsn}, built out-of-tree
    # separately by the linux4polarfire-drivers recipe. Scope this to
    # drivers/iio/mpfs-mc only, so the two recipes don't both try to
    # install the same files into the shared pkgdata area.
    for ko in $(find ${S}/drivers/iio/mpfs-mc -name "*.ko"); do
        install -m 0644 ${ko} ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra/
    done
}

RPROVIDES:${PN} += "kernel-module-mpfs-mc-adc kernel-module-mpfs-mc-picon kernel-module-mpfs-mc-pwm kernel-module-mpfs-mc-ratelim kernel-module-mpfs-mc-sqmng kernel-module-mpfs-mc-stptheta"
