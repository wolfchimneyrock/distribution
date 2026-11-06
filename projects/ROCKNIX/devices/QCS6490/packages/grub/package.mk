# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

# arm64-efi grub for boards with a standard UEFI (Radxa Dragon Q6A EDK2):
# the firmware runs \EFI\BOOT\BOOTAA64.EFI, grub loads the kernel and the
# mainline DTB from the boot partition.

PKG_NAME="grub"
PKG_VERSION="2.14"
PKG_SHA256="bc8d3c73535b8838d8c8e2654d73edc4e6ae8c8acdb45d5df5dc9a1547446d43"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://www.gnu.org/software/grub/index.html"
PKG_URL="https://ftp.gnu.org/gnu/grub/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_HOST="toolchain:host"
PKG_DEPENDS_TARGET="toolchain flex freetype:host gettext:host grub:host"
PKG_NEED_UNPACK="${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/options"
PKG_LONGDESC="GRUB is a Multiboot boot loader."
PKG_TOOLCHAIN="configure"
PKG_BUILD_FLAGS="-cfg-libs -cfg-libs:host"

GRUB_DTB="qcs6490-radxa-dragon-q6a"

pre_configure_host() {
  unset CFLAGS
  unset CPPFLAGS
  unset CXXFLAGS
  unset LDFLAGS
  unset CPP
}

pre_configure_target() {
  PKG_CONFIGURE_OPTS_TARGET="--target=aarch64-linux \
                             --disable-nls \
                             --with-platform=efi"

  unset CFLAGS
  unset CPPFLAGS
  unset CXXFLAGS
  unset LDFLAGS
  unset CPP

  # configure requires explicit TARGET_PREFIX binaries when cross compiling.
  export TARGET_CC="${TARGET_PREFIX}gcc"
  export TARGET_OBJCOPY="${TARGET_PREFIX}objcopy"
  export TARGET_STRIP="${TARGET_PREFIX}strip"
  export TARGET_NM="${TARGET_PREFIX}nm"
  export TARGET_RANLIB="${TARGET_PREFIX}ranlib"
}

make_target() {
  make CC=${CC} \
       AR=${AR} \
       RANLIB=${RANLIB} \
       CFLAGS="-I${SYSROOT_PREFIX}/usr/include -fomit-frame-pointer -D_FILE_OFFSET_BITS=64" \
       LDFLAGS="-L${SYSROOT_PREFIX}/usr/lib"
}

makeinstall_target() {
  ${PKG_BUILD}/.${HOST_NAME}/grub-mkimage -d grub-core -o bootaa64.efi -O arm64-efi -p /EFI/BOOT \
    boot linux fdt fat part_gpt part_msdos search search_fs_file normal configfile \
    loadenv test echo reboot efi_gop gfxterm

  mkdir -p ${INSTALL}/usr/share/bootloader/EFI/BOOT
    cp -P bootaa64.efi ${INSTALL}/usr/share/bootloader/EFI/BOOT

  cat << EOF > ${INSTALL}/usr/share/bootloader/EFI/BOOT/grub.cfg
set timeout=1
set default=0
search --no-floppy --set=root --file /${KERNEL_NAME}

menuentry '${DISTRONAME}' {
  linux /${KERNEL_NAME} boot=LABEL=${DISTRO_BOOTLABEL} disk=LABEL=${DISTRO_DISKLABEL} ${EXTRA_CMDLINE}
  devicetree /dtbs/${GRUB_DTB}.dtb
}
EOF
}
