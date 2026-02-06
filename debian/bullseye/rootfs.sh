#!/bin/sh
set -e

export DEBIAN_FRONTEND=noninteractive

dpkg --add-architecture arm64
apt -y update
apt -y upgrade
apt install -y gcc-aarch64-linux-gnu
apt install -y libpcap-dev:arm64 libcephfs-dev:arm64 librbd-dev:arm64 librados-dev:arm64
apt install -y gcc g++ make automake autoconf libtool perl bash git lrzsz procps netcat-openbsd jq \
    sudo vim tmux htop locales
apt install -y openssh-server zlib1g-dev libssl-dev libpcre2-dev libpcre3-dev
apt install -y tcpdump lsof net-tools bind9-utils bind9-dnsutils mtr wget curl

echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "LANG=en_US.UTF-8" >> /etc/environment
locale-gen
sed -i 's/[# ]*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
mkdir /var/run/sshd
ssh-keygen -A

echo 'root:root' | chpasswd
useradd -m -s /bin/bash x
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

## china
sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list

wget -qO- --delete-after https://go.dev/dl/go1.24.3.linux-amd64.tar.gz | sudo tar -xz -C /usr/local/lib/
ln -sf /usr/local/lib/go/bin/* /usr/local/bin/
