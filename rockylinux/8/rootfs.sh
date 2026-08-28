#!/bin/sh
set -e
yum clean all && yum makecache
yum update -y
yum install -y epel-release
yum update -y

yum install -y gcc gcc-c++ make automake autoconf libtool perl bash git lrzsz procps \
    psmisc sudo vim tmux netcat glibc-common
yum install -y openssh-server zlib-devel openssl-devel pcre-devel
yum install -y tcpdump lsof net-tools bind-utils mtr wget curl glibc-locale-source glibc-langpack-en glibc-langpack-zh
echo "LANG=en_US.UTF-8" >>/etc/environment
localedef -i en_US -f UTF-8 en_US.UTF-8
localedef -i zh_CN -f UTF-8 zh_CN.UTF-8
sed -i 's/[# ]*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
ssh-keygen -A

echo 'root:root' | chpasswd
useradd -m -s /bin/bash x
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

sed -e 's|^mirrorlist=|#mirrorlist=|g' \
    -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.aliyun.com/rocky|g' \
    -i.bak \
    /etc/yum.repos.d/*.repo

sed -e 's!^metalink=!#metalink=!g' \
    -e 's!^#baseurl=!baseurl=!g' \
    -e 's!https\?://download\.fedoraproject\.org/pub/epel!https://mirrors.aliyun.com/epel!g' \
    -e 's!https\?://download\.example/pub/epel!https://mirrors.aliyun.com/epel!g' \
    -i /etc/yum.repos.d/epel*.repo
