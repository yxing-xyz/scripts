#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive
echo "Asia/Shanghai" >/etc/timezone

apt -y update
apt -y upgrade

apt install -y gcc g++ make automake autoconf libtool perl bash git lrzsz procps locales \
    psmisc sudo vim tmux bsdmainutils htop netcat-openbsd
apt install -y openssh-server zlib1g-dev libssl-dev libpcre2-dev libpcre3-dev
apt install -y tcpdump lsof net-tools bind9-utils bind9-dnsutils mtr wget curl iputils-arping iputils-ping iputils-tracepath

echo "zh_CN.UTF-8 UTF-8" >>/etc/locale.gen
echo "en_US.UTF-8 UTF-8" >>/etc/locale.gen
echo "LANG=en_US.UTF-8" >>/etc/environment
locale-gen
sed -i 's/[# ]*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
ssh-keygen -A

echo 'root:root' | chpasswd
useradd -m -s /bin/bash x
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

## china
if [[ $(uname -a) == *"x86_64"* ]]; then
    sed -i 's|^URIs: http://archive.ubuntu.com/ubuntu/|URIs: http://mirror.nju.edu.cn/ubuntu/|g' /etc/apt/sources.list.d/ubuntu.sources
    sed -i 's|^URIs: http://security.ubuntu.com/ubuntu/|URIs: http://mirror.nju.edu.cn/ubuntu/|g' /etc/apt/sources.list.d/ubuntu.sources
else
    sed -i 's|^URIs: http://ports.ubuntu.com/ubuntu-ports/|URIs: http://mirror.nju.edu.cn/ubuntu-ports/|g' /etc/apt/sources.list.d/ubuntu.sources
fi
