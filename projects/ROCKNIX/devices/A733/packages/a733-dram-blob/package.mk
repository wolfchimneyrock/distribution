# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="a733-dram-blob"
# radxa-pkg/u-boot-dlan17 tag 2026.04-4; the same blob the a7s-build chain pins.
PKG_VERSION="b1cec0a90c795f65b82cee7098489e0bdf550b74"
PKG_SHA256="d89804f404f2eef6ef5b03d82a310ef0906c4db8ded760be221b131f5c813a05"
PKG_LICENSE="nonfree"
PKG_SITE="https://github.com/radxa-pkg/u-boot-dlan17"
PKG_URL="https://raw.githubusercontent.com/radxa-pkg/u-boot-dlan17/${PKG_VERSION}/awbin/a733/ddr.bin"
PKG_SOURCE_NAME="a733-ddr-${PKG_VERSION:0:12}.bin"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Allwinner A733 DRAM init (vendor AArch32 blob), linked into the U-Boot SPL"
PKG_TOOLCHAIN="manual"

unpack() {
  mkdir -p ${PKG_BUILD}
}

makeinstall_target() {
  # Staged in the sysroot so u-boot finds it across CI jobs.
  mkdir -p ${SYSROOT_PREFIX}/usr/share/${PKG_NAME}
    cp ${SOURCES}/${PKG_NAME}/${PKG_SOURCE_NAME} ${SYSROOT_PREFIX}/usr/share/${PKG_NAME}/ddr.bin
}
