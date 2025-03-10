#!/bin/env bash

srcDir=$(dirname "$(realpath "$0")")
# GRUB
sudo tar -xzf ${srcDir}/Grub_Pochita.tar.gz -C /usr/share/grub/themes/
sudo sed -i "/^GRUB_DEFAULT=/c\GRUB_DEFAULT=saved
            /^GRUB_GFXMODE=/c\GRUB_GFXMODE=1280x1024x32,auto
            /^GRUB_THEME=/c\GRUB_THEME=\"/usr/share/grub/themes/Pochita/theme.txt\"
            /^#GRUB_THEME=/c\GRUB_THEME=\"/usr/share/grub/themes/Pochita/theme.txt\"
            /^#GRUB_SAVEDEFAULT=true/c\GRUB_SAVEDEFAULT=true" /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# tty keyboard map
cp -f ${srcDir}/us.map.gz /usr/share/keymaps/i386/qwerty/us.map.gz
# xkb keyboard map
cp -f ${srcDir}/pc /usr/share/X11/xkb/symbols/pc

## systemd配置
echo 'HandlePowerKey=suspend' >>/etc/systemd/logind.conf
tee >>/etc/systemd/system.conf <<EOF
DefaultTimeoutStartSec=10s
DefaultTimeoutStopSec=10s
EOF

localectl set-keymap us
localectl set-locale LANG=zh_CN.UTF-8
timedatectl set-timezone Asia/Shanghai
