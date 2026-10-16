# Kas Build Configurations

## Prerequisites

Install kas using pip:

```bash
pip install kas
```

### PolarFire SoC

```bash
cd meta-mchp-fpga-solns/kas
export KAS_WORK_DIR=../../
KAS_MACHINE=mpfs-video-kit-drm kas build meta-mchp-fpga-solns.yml --target mchp-base-image-sdk
```

