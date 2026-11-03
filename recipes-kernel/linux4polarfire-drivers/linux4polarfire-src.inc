# Common SRC_URI/SRCREV for recipes pulling out-of-tree driver sources from
# the linux4polarfire repository.
#
#   require ../linux4polarfire-drivers/linux4polarfire-src.inc
#

SRC_URI = "git://git@bitbucket.microchip.com/fpga_pfsoc_sev_solutions/linux4polarfire.git;protocol=ssh;branch=linux-6.18-mchp+fpga+2026.04"
SRCREV = "d7152cbd93ed625b24bcf6535e614c99da272f7b"
