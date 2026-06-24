# Fix Python3 linking for cross-compilation
# Python3::Module doesn't link libpython (intended for native extension modules)
# Python3::Python links libpython (required for cross-compilation)
#
# Without this fix, you get undefined reference errors:
#   undefined reference to `_Py_Dealloc'
#   undefined reference to `PyObject_GetAttrString'

do_configure:prepend:class-target() {
    # Replace Python3::Module with Python3::Python in the cmake file
    sed -i 's/Python3::Module/Python3::Python/g' ${S}/cmake/rosidl_generator_py_generate_interfaces.cmake
}
