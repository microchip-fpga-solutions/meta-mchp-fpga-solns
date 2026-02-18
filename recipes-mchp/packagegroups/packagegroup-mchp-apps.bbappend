RDEPENDS:packagegroup-mchp-apps:mpfs-video-kit-raw-bayer += "\
    mchp-fpga-soln-linux-apps-v4l2 \
"

RDEPENDS:packagegroup-mchp-apps:mpfs-video-kit-h264 += "\
    polarfire-soc-linux-examples-dt-overlays \
    polarfire-soc-linux-examples-pdma \
"

RDEPENDS:packagegroup-mchp-apps:mpfs-video-kit-h264-mm += "\
    polarfire-soc-linux-examples-dt-overlays \
    polarfire-soc-linux-examples-pdma \
    mchp-fpga-soln-linux-apps-auto-enhance-osd \
"

RDEPENDS:packagegroup-mchp-apps:mpfs-video-kit-tsn += "\
    polarfire-soc-linux-examples-dt-overlays \
    polarfire-soc-linux-examples-pdma \
    mchp-fpga-soln-linux-apps-tsn \
    mchp-fpga-soln-linux-apps-japll-pi-controller \
    mchp-fpga-soln-linux-apps-opcua \
"
