# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="g610-mali-csffw"
# CSF firmware that Rockchip ships with kbase g25p0..g29p1 in rockchip-linux/kernel develop-6.1
# (drivers/gpu/arm/bifrost/mali_csffw.bin, git_sha 8e5cfcfec20cc8aff8509d37e72babc935d34a3b).
PKG_VERSION="8e5cfcfe"
PKG_LICENSE="nonfree"
PKG_SITE="https://github.com/rockchip-linux/kernel"
PKG_URL=""
PKG_LONGDESC="Mali CSF firmware needed for the RK3588 GPU (kbase g29p1)"
PKG_DEPENDS_TARGET="toolchain"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_firmware_dir)
  cp -a ${PKG_DIR}/firmware/mali_csffw.bin ${INSTALL}/$(get_full_firmware_dir)
}
