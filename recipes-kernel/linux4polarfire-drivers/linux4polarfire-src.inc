# Common SRC_URI/SRCREV for recipes pulling out-of-tree driver sources from
# the linux4polarfire repository.
#
#   require ../linux4polarfire-drivers/linux4polarfire-src.inc
#

SRC_URI = "git://github.com/microchip-fpga-solutions/linux4polarfire.git;protocol=https;branch=linux-6.18-mchp+fpga+2026.04"
SRCREV = "c28e45a89657cc386540a8b6f30bda136f343b1e"
