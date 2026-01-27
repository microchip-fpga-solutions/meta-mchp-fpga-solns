# meta-mpfs-fpga-soln

- **meta-mpfs-fpga-soln**: layer containing recipes that extend and supplement the meta-mchp layer. These include additional applications and demos to demonstrate PolarFire SoC solutions.

The complete User Guide for MPFS-VIDEO-KIT development platform, containing board and boot instructions, are available below:

- [MPFS-VIDEO-KIT](https://mi-v-ecosystem.github.io/redirects/boards-mpfs-sev-kit-sev-kit-user-guide) (PolarFire SoC Video Kit)

## Supported machines

| `MACHINE`                           | Board Name, Solution                     | Description                                                           |
| ------------------------------------| -----------------------------------------|-----------------------------------------------------------------------|
| `MACHINE=mpfs-video-kit-h264`       | MPFS-VIDEO-KIT, H264 Video solution      | PolarFire SoC Video Kit H.264 Demo                                    |
| `MACHINE=mpfs-video-kit-h264-mm`    | MPFS-VIDEO-KIT, H264 Modular solution    | PolarFire SoC Video Kit H.264 Modular Pipeline Demo     		 |
| `MACHINE=mpfs-video-kit-raw-bayer`  | MPFS-VIDEO-KIT, Bayer Pipeline solution  | PolarFire SoC Video Kit Frame Capture Examples Scripts                |
| `MACHINE=mpfs-video-kit-tsn`        | MPFS-VIDEO-KIT, TSN solution             | PolarFire SoC Video Kit TSN Demo                                      |


## Image Targets

The table below describes some custom Microchip image targets that can be used to run various demos, as well as recommended
standard OpenEmbedded image targets. For additional standard OpenEmbedded images, please refer to the
[OpenEmbedded documentation](https://docs.yoctoproject.org/dev/ref-manual/images.html#images).

| `MACHINE`                     | Description                                                                                           |
| ----------------------------- | ------------------------------------------------------------------------------------------------------|
| `mchp-base-image`             | A Microchip base image with standard Linux utilities, as well as some Microchip apps and examples     |


## Build Instructions

Before continuing, ensure that the prerequisite packages are present on your system. Please see the [Host PC setup for Yocto section](#Dependencies) for further details.

### Create the Workspace

repo init -u https://bitbucket.microchip.com/scm/fpga_pfsoc_sev_solutions/meta-mchp-fpga-soln-manifest -b tsn -m default.xml

repo sync

export TEMPLATECONF=${TEMPLATECONF:-../meta-mchp-fpga-soln/conf/templates/default}

source openembedded-core/oe-init-build-env

# To build WIC for H264 solution

MACHINE=mpfs-video-kit-h264 bitbake mchp-base-image  

# To build WIC for H264 MM solution

MACHINE=mpfs-video-kit-h264-mm bitbake mchp-base-image  

# To build WIC for Bayer modular pipeline  solution

MACHINE=mpfs-video-kit-raw-bayer bitbake mchp-base-image  

# To build WIC for TSN solution

MACHINE=mpfs-video-kit-tsn bitbake mchp-base-image  

<a name="Dependencies"></a>
## Host PC setup for Yocto

### Yocto Dependencies

This document assumes you are running on a modern Linux system. The process documented here was tested using Ubuntu 18.04 LTS.
It should also work with other Linux distributions if the equivalent prerequisite packages are installed.

The BSP uses the Yocto release Scarthgap (Revision 5.0.3) (Released August 2024).

**Make sure to install the [repo utility](https://gerrit.googlesource.com/git-repo/+/HEAD/README.md) first.**

Detailed instructions for various distributions can be found in the ["Required Packages for the Build Host"](https://docs.yoctoproject.org/5.0.3/ref-manual/system-requirements.html#required-packages-for-the-build-host) section in the Yocto Project Reference Manual.

```bash
**Note: Some extra packages are requried to support the Yocto 5.0.3 Release (codename scarthgap) compared to the prior release.**
```

<a name="OtherDeps"></a>
### Other Dependencies

For Ubuntu 18.04 (or newer) install python3-distutils:

```bash
sudo apt install python3-distutils
```

You can install the bmap-tools package using the following command:

```bash
sudo apt-get install bmap-tools
```

## Additional Reading

[Yocto Overview Manual](https://docs.yoctoproject.org/overview-manual/index.html)

[Yocto Development Task Manual](https://docs.yoctoproject.org/dev-manual/index.html)

[Yocto Bitbake User Manual](https://docs.yoctoproject.org/bitbake/index.html)

[Yocto Flashing images using bmaptool](https://www.yoctoproject.org/docs/current/mega-manual/mega-manual.html#flashing-images-using-bmaptool)

## Licensing

This project is licensed under the terms of the MIT license (please see LICENSE file in this directory for further details).
By using the PolarFire SoC Yocto BSP layer in this repository, the user agrees to the terms and conditions from the licenses of the packages that are installed into the final image and that are covered by a commercial license.
The user also acknowledges that it's their responsibility to make sure they hold the right to use code protected by commercial agreements, whether the commercially protected packages are selected by Microchips' PolarFire SoC BSPs or by them.
Finally, the user acknowledges that it's their responsibility to make sure they hold the right to copy, use, modify, and re-distribute the intellectual property offered by this collection of meta-layers.

## Known issues

