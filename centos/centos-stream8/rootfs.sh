#!/bin/sh
set -e
# mirror
sed -e "s|^mirrorlist=|#mirrorlist=|g" \
    -e "s|^#baseurl=http://mirror.centos.org|baseurl=https://mirrors.aliyun.com/centos-vault|g" \
    -i.bak \
    /etc/yum.repos.d/CentOS-*.repo

yum clean all && yum makecache
yum update -y
yum install -y epel-release
sed -e 's!^metalink=!#metalink=!g' \
    -e 's!^#baseurl=!baseurl=!g' \
    -e 's!https\?://download\.fedoraproject\.org/pub/epel!https://mirrors.aliyun.com/epel!g' \
    -e 's!https\?://download\.example/pub/epel!https://mirrors.aliyun.com/epel!g' \
    -i /etc/yum.repos.d/epel*.repo
yum update -y
sed -e 's!^metalink=!#metalink=!g' \
    -e 's!^#baseurl=!baseurl=!g' \
    -e 's!https\?://download\.fedoraproject\.org/pub/epel!https://mirrors.aliyun.com/epel!g' \
    -e 's!https\?://download\.example/pub/epel!https://mirrors.aliyun.com/epel!g' \
    -i /etc/yum.repos.d/epel*.repo
