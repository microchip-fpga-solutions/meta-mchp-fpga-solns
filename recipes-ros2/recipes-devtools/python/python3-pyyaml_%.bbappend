# Fix QA error: python3-pyyaml requires libyaml at runtime
# Without this, you get:
#   QA Issue: python3-pyyaml requires libyaml, but no providers found in RDEPENDS

RDEPENDS:${PN}:append = " libyaml"
