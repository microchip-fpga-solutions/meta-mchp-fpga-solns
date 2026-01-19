setenv fdt_high 0xffffffffffffffff
setenv initrd_high 0xffffffffffffffff

load mmc 0:${distro_bootpart} ${scriptaddr} fitImage
bootm start ${scriptaddr}#conf-mpfs-video-kit.dtb#conf-mpfs_coretse.dtbo;
bootm loados ${scriptaddr};
# Try to load a ramdisk if available inside fitImage
bootm ramdisk;
bootm prep;
bootm go;
