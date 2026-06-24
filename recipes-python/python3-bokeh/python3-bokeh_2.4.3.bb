SUMMARY = "Interactive Web Visualization Library"
HOMEPAGE = "https://bokeh.org"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=b3d447f35efc42b4920e3e7cbf610d54"

SRC_URI = "https://files.pythonhosted.org/packages/source/b/bokeh/bokeh-${PV}.tar.gz"
SRC_URI[sha256sum] = "ef33801161af379665ab7a34684f2209861e3aefd5c803a21fbbb99d94874b03"

inherit pypi setuptools3

RDEPENDS:${PN} += " \
    python3-core \
    python3-numpy \
    python3-pandas \
    python3-jinja2 \
    python3-tornado \
    python3-packaging \
    python3-pyyaml \
    python3-dateutil \
    python3-pillow \
    python3-typing-extensions \
"
