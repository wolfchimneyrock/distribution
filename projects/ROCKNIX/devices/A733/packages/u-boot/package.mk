# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="u-boot"
# Radxa's mainline-based tree (v2026.07 + A733), with the board-tested boot-chain
# patches from github.com/DockSeed/a7s-build (bootchain/patches/u-boot).
PKG_VERSION="9da4b3e82d641296f5b19d5e78eaad0d3cf56eec"
PKG_SHA256="f5464b3dba5d51cbeb78e53d50626f96d33e261a3663830cd62036789d098423"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/radxa/u-boot"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain Python3 swig:host pyelftools:host a733-dram-blob"
PKG_LONGDESC="Das U-Boot for Allwinner A733 boards: SPL + vendor DRAM blob + TF-A BL31 + U-Boot in one file"
PKG_TOOLCHAIN="manual"

PKG_NEED_UNPACK="${PROJECT_DIR}/${PROJECT}/bootloader ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/bootloader"
# the image embeds BL31 and the DRAM blob; rebuild when they change
PKG_NEED_UNPACK+=" ${SYSROOT_PREFIX}/usr/share/atf/bl31.bin ${SYSROOT_PREFIX}/usr/share/a733-dram-blob/ddr.bin"

if [ -n "${UBOOT_FIRMWARE}" ]; then
  PKG_DEPENDS_TARGET+=" ${UBOOT_FIRMWARE}"
  PKG_DEPENDS_UNPACK+=" ${UBOOT_FIRMWARE}"
fi

PKG_UBOOT_CONFIG="rocknix-cubie-a7a_defconfig"

post_unpack() {
  cp -v ${PKG_DIR}/sources/configs/*_defconfig ${PKG_BUILD}/configs/
}

make_target() {
  [ "${BUILD_WITH_DEBUG}" = "yes" ] && PKG_DEBUG=1 || PKG_DEBUG=0
  setup_pkg_config_host

  DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=arm make mrproper
  DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=arm make HOSTCC="${HOST_CC}" HOSTCFLAGS="-I${TOOLCHAIN}/include" HOSTLDFLAGS="${HOST_LDFLAGS}" ${PKG_UBOOT_CONFIG}
  DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=arm _python_sysroot="${TOOLCHAIN}" _python_prefix=/ _python_exec_prefix=/ make \
    BL31="${SYSROOT_PREFIX}/usr/share/atf/bl31.bin" \
    SUNXI_LIBDRAM="${SYSROOT_PREFIX}/usr/share/a733-dram-blob/ddr.bin" \
    HOSTCC="${HOST_CC}" HOSTCFLAGS="-I${TOOLCHAIN}/include" HOSTLDFLAGS="${HOST_LDFLAGS}" HOSTSTRIP="true" CONFIG_MKIMAGE_DTC_PATH="scripts/dtc/dtc"
}

makeinstall_target() {
  # bootloader/mkimage writes this to the card at 128 KiB.
  mkdir -p ${INSTALL}/usr/share/bootloader
    cp -av u-boot-sunxi-with-spl.bin ${INSTALL}/usr/share/bootloader/A733_u-boot-sunxi-with-spl.bin
}
