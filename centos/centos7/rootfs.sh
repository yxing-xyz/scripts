#!/bin/bash
set -e
# china
if [[ $(uname -a) == *"x86_64"* ]]; then
    sed -e 's|^mirrorlist=|#mirrorlist=|g' \
        -e 's|^#baseurl=http://mirror.centos.org/centos|baseurl=https://mirrors.aliyun.com/centos-vault|g' \
        -i.bak \
        /etc/yum.repos.d/CentOS-*.repo
else
    sed -e 's|^mirrorlist=|#mirrorlist=|g' \
        -e 's|^#baseurl=http://mirror.centos.org/altarch/|baseurl=https://mirrors.aliyun.com/centos-vault/altarch/|g' \
        -e 's|^#baseurl=http://mirror.centos.org/$contentdir/|baseurl=https://mirrors.aliyun.com/centos-vault/altarch/|g' \
        -i.bak \
        /etc/yum.repos.d/CentOS-*.repo
fi

yum clean all && yum makecache
yum update -y

yum install -y epel-release
sed -e 's!^metalink=!#metalink=!g' \
    -e 's!^#baseurl=!baseurl=!g' \
    -e 's!https\?://download\.fedoraproject\.org/pub/epel!https://mirrors.aliyun.com/epel!g' \
    -e 's!https\?://download\.example/pub/epel!https://mirrors.aliyun.com/epel!g' \
    -i /etc/yum.repos.d/epel{,-testing}.repo
yum update -y

yum install -y gcc gcc-c++ make automake autoconf libtool perl bash git lrzsz procps \
    psmisc sudo vim tmux netcat
yum install -y openssh-server zlib-devel openssl-devel pcre-devel
yum install -y tcpdump lsof net-tools bind-utils mtr wget curl

echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "LANG=en_US.UTF-8" >> /etc/environment
locale-gen
sed -i 's/[# ]*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
ssh-keygen -A
echo 'root:root' | chpasswd
useradd -m -s /bin/bash x
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
