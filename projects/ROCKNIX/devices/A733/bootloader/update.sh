#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

[ -z "$SYSTEM_ROOT" ] && SYSTEM_ROOT=""
[ -z "$BOOT_ROOT" ] && BOOT_ROOT="/flash"

# mount $BOOT_ROOT rw
mount -o remount,rw $BOOT_ROOT

echo "Updating device trees..."
mkdir -p $BOOT_ROOT/device_trees
cp -f $SYSTEM_ROOT/usr/share/bootloader/device_trees/* $BOOT_ROOT/device_trees

# The boot chain at 128 KiB (SPL + DRAM blob + BL31 + U-Boot) is not rewritten on
# update: a bad write there leaves the board unbootable from this card. To update
# it by hand, from another computer with the board off:
#   dd if=A733_u-boot-sunxi-with-spl.bin of=/dev/<card> bs=1K seek=128 conv=fsync,notrunc

# mount $BOOT_ROOT ro
sync
mount -o remount,ro $BOOT_ROOT
