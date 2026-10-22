# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="powervr-firmware"
# Imagination's linux-firmware "powervr" branch; BXM-4-64 (A733) firmware is not upstream yet.
PKG_VERSION="8a58f81883f7be458daa34e418cc4079f995b279"
PKG_SHA256="1db1c399c17401d1f79d46c880db81c724d748c784d4639433b076aba2f9c0d2"
PKG_LICENSE="nonfree"
PKG_SITE="https://gitlab.freedesktop.org/imagination/linux-firmware"
PKG_URL="${PKG_SITE}/-/raw/${PKG_VERSION}/powervr/rogue_36.56.104.183_v1.fw"
PKG_SOURCE_NAME="rogue_36.56.104.183_v1-${PKG_VERSION:0:7}.fw"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Imagination PowerVR Rogue GPU firmware for the open drm/imagination driver"
PKG_TOOLCHAIN="manual"

unpack() {
  mkdir -p ${PKG_BUILD}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_firmware_dir)/powervr
    cp ${SOURCES}/${PKG_NAME}/${PKG_SOURCE_NAME} \
       ${INSTALL}/$(get_full_firmware_dir)/powervr/rogue_36.56.104.183_v1.fw
}
