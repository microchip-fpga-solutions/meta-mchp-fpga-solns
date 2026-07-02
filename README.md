# Microchip PolarFire SoC FPGA Solutions Layer

This repository provides an Yocto layer to include applications and demos, which demonstrate reference solutions on Microchip's PolarFire SoC FPGA devices. This layer containing recipes that extend and supplement the [meta-mchp](https://github.com/linux4microchip/meta-mchp) layer.

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Description](#description)
- [Layer Dependencies](#layer-dependencies)
- [Supported Machine Targets](#supported-machines)
- [Image Targets](#image-targets)
- [Build Instructions](#build-instructions)
- [Build for Motor Control Kit BLDC](#build-for-motor-control-bldc)
- [Build for Different Machines](#build-for-machines)
- [Finding the image](#find-the-image)
- [Updating Yocto Image](#update-yocto-image)
- [Updating Design and Running the Demo](#update-job-files)
- [Host PC setup for Yocto](#dependencies)
- [Additional Reading](#additional-reading)
- [Licensing](#licensing)

<a name="description"></a>
## Description

This repository supports the following Devices:

- [MPFS-VIDEO-KIT](https://mi-v-ecosystem.github.io/redirects/boards-mpfs-sev-kit-sev-kit-user-guide) (PolarFire SoC Video Kit)
- MPFS-MOTOR-CONTROL-KIT (PolarFire SoC Motor Control Kit)
- MPFS-MOTOR-CONTROL-KIT-BLDC (PolarFire SoC Motor Control Kit)

<a name="layer-dependencies"></a>
## Layer Dependencies

This layer depends on the following layers:

```text
- openembedded-core
  - URI: git://git.openembedded.org/openembedded-core
  - Layers: meta
```

```text
- meta-mchp
  - URI: https://github.com/linux4microchip/meta-mchp
  - Layers: meta-mchp
```

For Motor Control Kit BLDC, additional layers are required:

```text
- meta-ros
  - URI: https://github.com/ros/meta-ros
  - Layers: meta-ros-common, meta-ros2, meta-ros2-humble
```

For information on the specific revisions used, refer to the
[meta-mchp-fpga-solns-manifest](https://github.com/microchip-fpga-solutions/meta-mchp-fpga-solns-manifest) repository.

<a name="supported-machines"></a>
## Supported Machine Targets

The below table lists the machines which correspond to the various solutions:

| `MACHINE`                             | Board Name                     | Solution                                      |
| --------------------------------------| -------------------------------|-----------------------------------------------|
| `MACHINE=mpfs-video-kit-h264`         | MPFS-VIDEO-KIT                 | H.264                                         |
| `MACHINE=mpfs-video-kit-h264-mm`      | MPFS-VIDEO-KIT                 | H.264 Modular                                 |
| `MACHINE=mpfs-video-kit-raw-bayer`    | MPFS-VIDEO-KIT                 | Raw bayer                                     |
| `MACHINE=mpfs-video-kit-tsn`          | MPFS-VIDEO-KIT                 | TSN                                           |
| `MACHINE=mpfs-video-kit-drm`          | MPFS-VIDEO-KIT                 | DRM Display                                   |
| `MACHINE=mpfs-motor-control-kit`      | MPFS-MOTOR-CONTROL-KIT         | Motor Control Base                            |
| `MACHINE=mpfs-motor-control-kit-tsn`  | MPFS-MOTOR-CONTROL-KIT         | Motor Control TSN                             |
| `MACHINE=mpfs-motor-control-kit-bldc` | MPFS-MOTOR-CONTROL-KIT         | Motor Control BLDC                            |

<a name="image-targets"></a>
## Image Targets

The table below describes some custom Microchip image targets that can be used to run various demos. For additional standard OpenEmbedded images, please refer to the
[OpenEmbedded documentation](https://docs.yoctoproject.org/dev/ref-manual/images.html#images).

| `IMAGE`                       | Description                                                                                           |
| ----------------------------- | ------------------------------------------------------------------------------------------------------|
| `mchp-base-image`             | A Microchip base image with standard Linux utilities, as well as some Microchip apps and examples     |

<a name="build-instructions"></a>
## Build Instructions

Before continuing, ensure that the prerequisite packages are present on your system. Please see the [Host PC setup for Yocto section](#Dependencies) for further details.

### Create the Workspace

Create an empty directory to hold the workspace:

  ```bash
  mkdir yocto-dev
  cd yocto-dev
  ```

Use the repo tool to fetch all the required repositories

> Make sure to install the [repo](https://gerrit.googlesource.com/git-repo/+/HEAD/README.md) utility first.

  ```bash
  repo init -u https://github.com/microchip-fpga-solutions/meta-mchp-fpga-solns-manifest.git -b <branch-or-tag> -m default.xml
  ```

Replace `<tag>` with the Yocto release latest tag and the manifest required. For example:

  ```bash
  repo init -u https://github.com/microchip-fpga-solutions/meta-mchp-fpga-solns-manifest.git -b refs/tags/v2026.1 -m default.xml
  ```

Replace `<branch>` with the Yocto release latest branch and the manifest required. For example:

  ```bash
  repo init -u https://github.com/microchip-fpga-solutions/meta-mchp-fpga-solns-manifest.git -b scarthgap -m default.xml
  ```

> For BLDC

  ```bash
  repo init -u https://github.com/microchip-fpga-solutions/meta-mchp-fpga-solns-manifest.git -b <branch> -m default_bldc.xml
  ```

Replace `<branch>` with the Yocto release branch and the manifest required. For example:

  ```bash
  repo init -u https://github.com/microchip-fpga-solutions/meta-mchp-fpga-solns-manifest.git -b scarthgap -m default_bldc.xml
  ```

Fetch all the required repositories using the following repo command:

  ```bash
  repo sync
  ```

<a name="build-for-motor-control-bldc"></a>
## Build for Motor Control Kit BLDC

The Motor Control Kit BLDC requires a dedicated configuration. Use the `bldc` template:

```bash
cd yocto-dev
TEMPLATECONF=../meta-mchp-fpga-solns/conf/templates/bldc source openembedded-core/oe-init-build-env
```

This will:
- Set default machine to `mpfs-motor-control-kit-bldc`
- Include required layers (meta-ros-common, meta-ros2, meta-ros2-humble)

Build the image:

```bash
bitbake mchp-base-image
```

<a name="build-for-machines"></a>
## Build for Different Machines

Set the `TEMPLATECONF` environment variable to point to the default configuration template:

  ```bash
  export TEMPLATECONF=${TEMPLATECONF:-../meta-mchp-fpga-solns/conf/templates/default}
  ```

Then initialize the Yocto build environment:

  ```bash
  source openembedded-core/oe-init-build-env
  ```

Use the following build command depending on the required solution (i.e, machine):

```bash
MACHINE=<supported machine>  bitbake <image target>
```

Example To build WIC for TSN solution:

```bash
MACHINE=mpfs-video-kit-tsn bitbake mchp-base-image
```

<a name="find-the-image"></a>
## Finding the Image

On successful build, the disk image (a `.wic` file) would be generated in `yocto-dev/build/tmp-glibc/deploy/images/<MACHINE>/`.
Example:
`yocto-dev/build/tmp-glibc/deploy/images/mpfs-video-kit-tsn/mchp-base-image-mpfs-video-kit-tsn.rootfs.wic`

<a name="update-yocto-image"></a>
## Updating Yocto Image

- [Updating Linux in MPFS kit](https://github.com/polarfire-soc/polarfire-soc-documentation/blob/master/reference-designs-fpga-and-development-kits/updating-linux-in-mpfs-kit.md)

<a name="update-job-files"></a>
## Updating Design and Running the Demo

Following table provides links to the Design files and the documentation for running the Demo's corresponding to the solutions:

| Design                                              | Running Demo Applications                    |
| -------------------------------------------------- | ---------------------------------------------|
| [H264 Programming Job File][1]                     | [Running H264 Demo][2]                       |
| [H264 MM Programming Job File][3]                  | [Running H264 MM Demo][4]                    |
| [Raw Bayer Programming Job File][5]                | [Raw Bayer demo][6]                          |
| [TSN Programming Job File][7]                      | [Running TSN Demo][8]                        |
| [DRM Programming Job File][9]                      | [Running DRM Demo][10]                       |
| [mpfs095-som-base Programming Job File][11]        | [Basic Linux booting][12]                    |
| [mpfs095-motor-kit-bldc Programming Job File][13]  | [Running Motor Control BLDC Demo][14]        |

[1]: https://github.com/polarfire-soc/polarfire-soc-video-kit-reference-design/releases/download/v2024.06/MPFS_VIDEO_KIT_BASE_DESIGN_2024_06.zip
[2]: https://github.com/polarfire-soc/polarfire-soc-documentation/blob/master/applications-and-demos/mpfs-video-kit-h264-demo.md
[3]: https://github.com/polarfire-soc/polarfire-soc-video-kit-reference-design/releases/download/v2024.06/MPFS_VIDEO_KIT_H264_MM_DESIGN_2024_06.zip
[4]: https://github.com/polarfire-soc/polarfire-soc-documentation/blob/master/applications-and-demos/mpfs-video-kit-h264-modular-pipeline-demo.md
[5]: https://github.com/polarfire-soc/polarfire-soc-video-kit-reference-design/releases/download/v2024.06/MPFS_VIDEO_KIT_RAW_BAYER_DESIGN_2024_06.zip
[6]: https://github.com/polarfire-soc/polarfire-soc-linux-examples/tree/master/multimedia/v4l2#polarfire-soc-video-kit-frame-capture-examples-scripts
[7]: https://github.com/microchip-fpga-solutions/mpfs250-video-kit-tsn/releases
[8]: https://github.com/microchip-fpga-solutions/mpfs250-video-kit-tsn?tab=readme-ov-file#instructions-to-run-the-demo-on-linux
[9]: https://github.com/microchip-fpga-solutions/mpfs250-video-kit-drm/releases/download/DRM_v2026.0/mpfs250-video-kit-drm-Job-v2026.0.zip
[10]: https://github.com/microchip-fpga-solutions/mpfs250-video-kit-drm#demo-applications
[11]: https://github.com/microchip-fpga-solutions/mpfs095-som-fcsg536e-base/releases
[12]: https://github.com/polarfire-soc/polarfire-soc-documentation/blob/master/reference-designs-fpga-and-development-kits/updating-linux-in-mpfs-kit.md
[13]: https://github.com/microchip-fpga-solutions/mpfs095-motor-kit-bldc/releases/download/BLDC_v2026.0/bldc-design-mpfs095-som-job-v2026.0.zip
[14]: https://github.com/microchip-fpga-solutions/mpfs095-motor-kit-bldc/tree/main#instructions-to-run-the-demo

For details about design or solution-specific job files, see the latest release notes.

<a name="dependencies"></a>
## Host PC setup for Yocto

### Yocto Dependencies

This document assumes you are running on a modern Linux system. The process documented here was tested using Ubuntu  22.04 LTS.
It should also work with other Linux distributions if the equivalent prerequisite packages are installed.

The BSP uses the Yocto release Scarthgap (Revision 5.0.3) (Released August 2024).

**Make sure to install the [repo utility](https://gerrit.googlesource.com/git-repo/+/HEAD/README.md) first.**

Detailed instructions for various distributions can be found in the ["Required Packages for the Build Host"](https://docs.yoctoproject.org/5.0.3/ref-manual/system-requirements.html#required-packages-for-the-build-host) section in the Yocto Project Reference Manual.

**Note: Some extra packages are required to support the Yocto 5.0.3 Release (codename Scarthgap) compared to the prior release.**

<a name="OtherDeps"></a>
### Other Dependencies

For Ubuntu 22.04 (or newer) install python3-distutils:

```bash
sudo apt install python3-distutils
```

You can install the bmap-tools package using the following command:

```bash
sudo apt-get install bmap-tools
```

<a name="additional-reading"></a>
## Additional Reading

[Yocto Overview Manual](https://docs.yoctoproject.org/overview-manual/index.html)

[Yocto Development Task Manual](https://docs.yoctoproject.org/dev-manual/index.html)

[Yocto Bitbake User Manual](https://docs.yoctoproject.org/bitbake/index.html)

[Yocto Flashing images using bmaptool](https://www.yoctoproject.org/docs/current/mega-manual/mega-manual.html#flashing-images-using-bmaptool)

<a name="licensing"></a>
## Licensing

This project is licensed under the terms of the MIT license (please see LICENSE file in this directory for further details).
By using the PolarFire SoC Yocto BSP layer in this repository, the user agrees to the terms and conditions from the licenses of the packages that are installed into the final image and that are covered by a commercial license.
The user also acknowledges that it's their responsibility to make sure they hold the right to use code protected by commercial agreements, whether the commercially protected packages are selected by Microchips' PolarFire SoC BSPs or by them.
Finally, the user acknowledges that it's their responsibility to make sure they hold the right to copy, use, modify, and re-distribute the intellectual property offered by this collection of meta-layers.

## Contributing

If you want to contribute changes, you can send Github pull requests at
**<https://github.com/microchip-fpga-solutions/meta-mchp-fpga-solns/pulls>**.

