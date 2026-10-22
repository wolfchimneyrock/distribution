# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="aic8800"
PKG_VERSION="e9e43ed79c50483080e9bcdfb08caeeb869d7191" # 5.0+git20260123.5f7be68d-10
PKG_SHA256="0ab4fdc48395947a906844ef5b696256a390afbb2304f87ba9e0c08fea4c60c8"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/radxa-pkg/aic8800"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux usb-modeswitch"
PKG_LONGDESC="AICSemi AIC8800 Wi-Fi/Bluetooth drivers and firmware (USB and SDIO, Radxa packaging)"
PKG_TOOLCHAIN="manual"
PKG_IS_KERNEL_PKG="yes"

# Which bus variants to build; a device can override this in its options.
AIC8800_TYPE="${AIC8800_TYPE:-usb sdio}"

AIC_USB_DIR="src/USB/driver_fw/drivers"
AIC_SDIO_DIR="src/SDIO/driver_fw/driver/aic8800"

# The USB and SDIO trees export five functions with the same names; give the
# SDIO build its own names so depmod can't resolve aic8800_fdrv_sdio against
# the USB helper (aic_load_fw).
AIC_SDIO_DEFS="-Dget_fw_path=aicsdio_get_fw_path -Dget_testmode=aicsdio_get_testmode \
               -Dget_adap_test=aicsdio_get_adap_test \
               -Daicwf_prealloc_txq_alloc=aicsdio_prealloc_txq_alloc \
               -Dbtchr_external_write=aicsdio_btchr_external_write"

post_unpack() {
  # Two USB sources ship with CRLF line endings, which Radxa's patches don't match.
  sed -i 's/\r$//' ${PKG_BUILD}/${AIC_USB_DIR}/aic8800/aic_load_fw/aicbluetooth.c \
                   ${PKG_BUILD}/${AIC_USB_DIR}/aic8800/aic_load_fw/aic_bluetooth_main.c

  # Apply Radxa's Debian patch series (firmware paths, kernel 6.1 - 7.3 build fixes).
  local p
  while read -r p; do
    [ -z "${p}" ] && continue
    [[ "${p}" =~ ^# ]] && continue
    patch -d ${PKG_BUILD} -p1 --no-backup-if-mismatch < ${PKG_BUILD}/debian/patches/${p} || die "aic8800: patch ${p} failed"
  done < ${PKG_BUILD}/debian/patches/series

  # Both variants build an "aic8800_fdrv"; give them distinct module names
  # (as Radxa's DKMS packages do) so they can be installed side by side.
  sed -i 's/^MODULE_NAME = aic8800_fdrv$/MODULE_NAME = aic8800_fdrv_usb/' \
      ${PKG_BUILD}/${AIC_USB_DIR}/aic8800/aic8800_fdrv/Makefile
  sed -i 's/^MODULE_NAME = aic8800_fdrv$/MODULE_NAME = aic8800_fdrv_sdio/' \
      ${PKG_BUILD}/${AIC_SDIO_DIR}/aic8800_fdrv/Makefile
}

make_target() {
  unset LDFLAGS
  local m
  if listcontains "${AIC8800_TYPE}" "usb"; then
    for m in aic8800 aic_btusb; do
      make -C $(kernel_path) M=${PKG_BUILD}/${AIC_USB_DIR}/${m} \
           ARCH=${TARGET_KERNEL_ARCH} CROSS_COMPILE=${TARGET_KERNEL_PREFIX} modules
    done
  fi
  if listcontains "${AIC8800_TYPE}" "sdio"; then
    make -C $(kernel_path) M=${PKG_BUILD}/${AIC_SDIO_DIR} \
         ARCH=${TARGET_KERNEL_ARCH} CROSS_COMPILE=${TARGET_KERNEL_PREFIX} \
         KCFLAGS="${AIC_SDIO_DEFS}" modules
  fi
}

makeinstall_target() {
  local MODDIR=${INSTALL}/$(get_full_module_dir)/kernel/drivers/net/wireless/aic8800
  local FWDIR=${INSTALL}/$(get_kernel_overlay_dir)/lib/firmware/aic8800_fw
  mkdir -p ${MODDIR}

  if listcontains "${AIC8800_TYPE}" "usb"; then
    cp ${PKG_BUILD}/${AIC_USB_DIR}/aic8800/aic_load_fw/aic_load_fw.ko \
       ${PKG_BUILD}/${AIC_USB_DIR}/aic8800/aic8800_fdrv/aic8800_fdrv_usb.ko \
       ${PKG_BUILD}/${AIC_USB_DIR}/aic_btusb/aic_btusb.ko ${MODDIR}/
    # Firmware path set by fix-usb-firmware-path.patch
    mkdir -p ${FWDIR}/USB
      cp -r ${PKG_BUILD}/src/USB/driver_fw/fw/* ${FWDIR}/USB/
  fi

  if listcontains "${AIC8800_TYPE}" "sdio"; then
    cp ${PKG_BUILD}/${AIC_SDIO_DIR}/aic8800_bsp/aic8800_bsp.ko \
       ${PKG_BUILD}/${AIC_SDIO_DIR}/aic8800_fdrv/aic8800_fdrv_sdio.ko \
       ${PKG_BUILD}/${AIC_SDIO_DIR}/aic8800_btlpm/aic8800_btlpm.ko ${MODDIR}/
    # Firmware path set by fix-sdio-firmware-path.patch
    mkdir -p ${FWDIR}/SDIO
      cp -r ${PKG_BUILD}/src/SDIO/driver_fw/fw/* ${FWDIR}/SDIO/
    rm -f ${FWDIR}/SDIO/*.7z
  fi
}
