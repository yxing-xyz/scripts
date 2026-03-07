#!/bin/bash

if [[ $(uname -a) == *"x86_64"* ]]; then
  echo 'Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch' >/etc/pacman.d/mirrorlist
else
  echo 'Server = https://mirrors.ustc.edu.cn/archlinuxarm/$arch/$repo' >/etc/pacman.d/mirrorlist
fi

sed -i 's|#Color|Color|' /etc/pacman.conf
sed -i 's|#ParallelDownloads|ParallelDownloads|' /etc/pacman.conf
sed -i 's|#MAKEFLAGS.*|MAKEFLAGS="-j17"|' /etc/makepkg.conf

tee >>/etc/pacman.conf <<EOF
[archlinuxcn]
SigLevel = Never
Server = https://mirrors.ustc.edu.cn/archlinuxcn/\$arch
EOF

pacman -Sy
pacman -Su paru openssh lsd zoxide fzf zsh lazygit vim bat zellij difftastic emacs-nox \
    --overwrite '*' --noconfirm
sed -i 's/[# ]*UsePAM.*/UsePAM no/' /etc/ssh/sshd_config
sed -i 's/[# ]*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
ssh-keygen -A

mkdir -p /etc/sudoers.d
echo '%wheel ALL=(ALL:ALL) ALL' >/etc/sudoers.d/wheel
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
sed -i 's/#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen
echo 'LANG=zh_CN.UTF-8' >>/etc/locale.conf
locale-gen
useradd -m -G wheel -s /bin/zsh x && echo "x:你的密码" | sudo chpasswd
