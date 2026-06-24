# Copyright (c) 2019-2021 LG Electronics, Inc.
# Copyright (c) Qualcomm Innovation Center, Inc. All rights reserved
#
# Modified for Yocto Scarthgap (Python 3.12) cross-compilation fix
# Fixes undefined reference errors (_Py_Dealloc, PyObject_GetAttrString, etc.)
# when building ROS2 packages with rosidl_generator_py

# The SOABI setting changed in newer python3 with:
# http://git.openembedded.org/openembedded-core/commit/?h=warrior&id=f3326309c7c22a6034917f6eee21908c61f44a2f
# https://github.com/python/cpython/pull/13196/commits/752b61141da76e81e53700bdbea81cd95af617b6


PYTHON_SOABI_ARCH = "${TUNE_ARCH}-${TARGET_OS}"
PYTHON_SOABI_ARCH_SUFFIX = "-gnu"
# The suffix is already included in TARGET_OS
PYTHON_SOABI_ARCH_SUFFIX:arm = ""
# Another exception is i686 TUNE_ARCH in dunfell and newer with this change:
# https://git.openembedded.org/openembedded-core/commit/?h=dunfell&id=6beab388e73b3ac6157650855a6c1fb1d71e8015
PYTHON_SOABI_ARCH:i686 = "i386-${TARGET_OS}"
# Add in hf suffix if on a hard float capable device
HF = ""
HF:class-target = "${@ bb.utils.contains('TUNE_CCARGS_MFLOAT', 'hard', 'hf', '', d)}"
PYTHON_SOABI = "cpython-${@d.getVar('PYTHON_BASEVERSION').replace('.', '')}${PYTHON_ABI}-${PYTHON_SOABI_ARCH}${PYTHON_SOABI_ARCH_SUFFIX}${HF}"

EXTRA_OECMAKE:append = " -DBUILD_TESTING=OFF"
EXTRA_OECMAKE:append:class-target = " -DPYTHON_SOABI=${PYTHON_SOABI}"

# =============================================================================
# Python3 cross-compilation fix for scarthgap (Python 3.12)
# =============================================================================
# Force CMake to use target Python paths instead of native/host Python paths
# This fixes undefined reference errors in rosidl_generator_py
# FIND_REGISTRY=NEVER and FIND_FRAMEWORK=NEVER prevent finding host Python
EXTRA_OECMAKE:append:class-target = " \
    -DPython3_FIND_STRATEGY=LOCATION \
    -DPython3_FIND_REGISTRY=NEVER \
    -DPython3_FIND_FRAMEWORK=NEVER \
    -DPython3_ROOT_DIR=${STAGING_DIR_HOST}${prefix} \
    -DPython3_INCLUDE_DIR=${STAGING_INCDIR}/python${PYTHON_BASEVERSION} \
    -DPython3_INCLUDE_DIRS=${STAGING_INCDIR}/python${PYTHON_BASEVERSION} \
    -DPython3_LIBRARY=${STAGING_LIBDIR}/libpython${PYTHON_BASEVERSION}.so \
    -DPython3_LIBRARIES=${STAGING_LIBDIR}/libpython${PYTHON_BASEVERSION}.so \
    -DPython3_NumPy_INCLUDE_DIR=${STAGING_LIBDIR}/python${PYTHON_BASEVERSION}/site-packages/numpy/core/include \
    -DPython3_NumPy_INCLUDE_DIRS=${STAGING_LIBDIR}/python${PYTHON_BASEVERSION}/site-packages/numpy/core/include \
    -DPYTHON_INCLUDE_DIR=${STAGING_INCDIR}/python${PYTHON_BASEVERSION} \
    -DPYTHON_INCLUDE_DIRS=${STAGING_INCDIR}/python${PYTHON_BASEVERSION} \
    -DPYTHON_LIBRARY=${STAGING_LIBDIR}/libpython${PYTHON_BASEVERSION}.so \
    -DPYTHON_LIBRARIES=${STAGING_LIBDIR}/libpython${PYTHON_BASEVERSION}.so \
"

# Force compiler to use sysroot Python headers explicitly
TARGET_CFLAGS:append:class-target = " -I${STAGING_INCDIR}/python${PYTHON_BASEVERSION}"
TARGET_CXXFLAGS:append:class-target = " -I${STAGING_INCDIR}/python${PYTHON_BASEVERSION}"

# Fix rosidl_generator_py cmake file in native sysroot for cross-compilation:
# 1. Replace Python3::Module with Python3::Python for proper linking
# 2. Skip automatic Python3 discovery which finds host Python - use pre-set variables instead
do_configure:prepend:class-target() {
    CMAKE_FILE="${STAGING_DIR_NATIVE}${ros_prefix}/share/rosidl_generator_py/cmake/rosidl_generator_py_generate_interfaces.cmake"
    if [ -f "${CMAKE_FILE}" ]; then
        # Replace Python3::Module with Python3::Python for proper linking
        sed -i 's/Python3::Module/Python3::Python/g' "${CMAKE_FILE}"

        # Replace the find_package(Python3) call with a cross-compilation friendly version
        # that uses pre-set variables and creates proper imported targets
        sed -i 's/find_package(Python3 REQUIRED COMPONENTS Development NumPy)/# Cross-compilation fix: use pre-set Python3 variables instead of find_package\
if(NOT TARGET Python3::Python)\
  add_library(Python3::Python SHARED IMPORTED)\
  set_target_properties(Python3::Python PROPERTIES\
    IMPORTED_LOCATION "${Python3_LIBRARY}"\
    INTERFACE_INCLUDE_DIRECTORIES "${Python3_INCLUDE_DIR}"\
  )\
endif()\
if(NOT TARGET Python3::NumPy)\
  add_library(Python3::NumPy INTERFACE IMPORTED)\
  set_target_properties(Python3::NumPy PROPERTIES\
    INTERFACE_INCLUDE_DIRECTORIES "${Python3_NumPy_INCLUDE_DIR}"\
  )\
endif()/g' "${CMAKE_FILE}"
    fi
}

# Add python3-numpy dependency for cross-compilation of packages generating Python interfaces
# This ensures NumPy headers are available in the sysroot for rosidl_generator_py
DEPENDS:append:class-target = " python3-numpy"
# =============================================================================

# XXX Without STAGING_DIR_HOST path included, rmw-implementation:do_configure() fails with:
#
#    "Could not find ROS middleware implementation 'NOTFOUND'"
#
export AMENT_PREFIX_PATH = "${STAGING_DIR_HOST}${prefix};${STAGING_DIR_NATIVE}${prefix};${STAGING_DIR_HOST}${ros_prefix};${STAGING_DIR_NATIVE}${ros_prefix}"

inherit cmake python3native

FILES:${PN}:prepend = " \
    ${datadir}/ament_index \
"
EXTRA_OECMAKE:append = " -DAMENT_CMAKE_ENVIRONMENT_PARENT_PREFIX_PATH_GENERATION=OFF"

EXTRA_OECMAKE:prepend:class-target = "\
    -DCMAKE_PREFIX_PATH='${STAGING_DIR_HOST}${ros_prefix};${STAGING_DIR_HOST}${prefix}' \
    -DCMAKE_INSTALL_PREFIX:PATH='${ros_prefix}' \
"

EXTRA_OECMAKE:prepend:class-native = "\
    -DCMAKE_PREFIX_PATH='${ros_prefix}' \
    -DCMAKE_INSTALL_PREFIX:PATH='${ros_prefix}' \
"

EXTRA_OECMAKE:prepend:class-nativesdk = "\
    -DCMAKE_PREFIX_PATH='${STAGING_DIR_NATIVE}${ros_base_prefix};${STAGING_DIR_NATIVE}${ros_prefix};${STAGING_DIR_NATIVE}${prefix}' \
    -DCMAKE_INSTALL_PREFIX:PATH='${ros_prefix}' \
"
