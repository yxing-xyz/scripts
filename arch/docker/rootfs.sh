#!/bin/sh
set -e
PACKAGE_GROUP='base base-devel'
BOOTSTRAP_EXTRA_PACKAGES=""
apk add arch-install-scripts pacman-makepkg curl zstd bash
mkdir -p /etc/pacman.d
if [[ $(arch) == *"x86_64"* ]]; then
    curl -L https://gitlab.archlinux.org/archlinux/packaging/packages/pacman/-/raw/main/pacman.conf -o /etc/pacman.conf
    echo 'Server = https://geo.mirror.pkgbuild.com/$repo/os/$arch' >/etc/pacman.d/mirrorlist
elif [[ $(arch) == *"aarch64"* ]]; then
    curl -L https://raw.githubusercontent.com/archlinuxarm/PKGBUILDs/master/core/pacman/pacman.conf -o /etc/pacman.conf
    sed -i 's/@CARCH@/auto/g' /etc/pacman.conf
    echo 'Server = http://ca.us.mirror.archlinuxarm.org/$arch/$repo' >/etc/pacman.d/mirrorlist
    BOOTSTRAP_EXTRA_PACKAGES="archlinuxarm-keyring"
else
    echo 'unknown architecture'
    exit 1
fi
# 修复arm archlinux key错误
# adduser -c "Arch Linux Package Management" -r alpm
adduser -g "Arch Linux Package Management" -S alpm
sed -i 's|^Include = /etc/pacman.d/mirrorlist|Include = /etc/pacman.d/mirrorlist\nSigLevel = Never|g' /etc/pacman.conf
sed -i 's|#Color|Color|' /etc/pacman.conf
sed -i 's|#ParallelDownloads|ParallelDownloads|' /etc/pacman.conf
sed -i 's|#MAKEFLAGS.*|MAKEFLAGS="-j2"|' /etc/makepkg.conf
pacman-key --init

mkdir -p /rootfs
mkdir -m 0755 -p /rootfs/var/cache/pacman/pkg
mkdir -m 0755 -p /rootfs/var/lib/pacman
mkdir -m 0755 -p /rootfs/var/log
mkdir -m 0755 -p /rootfs/dev
mkdir -m 0755 -p /rootfs/run
mkdir -m 0755 -p /rootfs/etc
mkdir -m 1777 -p /rootfs/tmp
mkdir -m 0555 -p /rootfs/sys
mkdir -m 0555 -p /rootfs/proc
pacman -r /rootfs -Sy --noconfirm $PACKAGE_GROUP
pacman -r /rootfs -Sy --noconfirm $BOOTSTRAP_EXTRA_PACKAGES
cp /etc/pacman.conf /rootfs/etc/pacman.conf
cp /etc/makepkg.conf /rootfs/etc/makepkg.conf
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /rootfs/etc/locale.gen
echo "LANG=en_US.UTF-8" >/rootfs/etc/locale.conf
chroot /rootfs locale-gen
