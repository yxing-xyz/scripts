# apk
```bash
# 查看已经安装的包
apk list -I
# 查看包内容
apk info -L busybox
# 递归强制删除
apk del -rf tcpdump
# 修复或者升级已经安装的包
apk fix
# 升级
apk update
apk add --upgrade apk-tools
apk upgrade --available
```


# 安装
```bash
# alpine的setup脚本
tee >/etc/apk/repositories <<EOF
http://mirrors.nju.edu.cn/alpine/latest-stable/main
http://mirrors.nju.edu.cn/alpine/latest-stable/community
http://mirrors.nju.edu.cn/alpine/edge/testing/
EOF

## 常用package
apk add linux-virt linux-headers alpine-conf apk-tools bash zsh sudo go gcc g++ automake autoconf \
    wget curl e2fsprogs-extra dhcpcd psutils mkinitfs dracut cloud-utils-growpart \
    ripgrep fd fzf vim emacs-nox zsh musl-locales py3-pip tree ip6tables iptables docker
## glibc lib目录位于/usr/glibc-compat/lib
wget https://gh.bink.cc/github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r1/glibc-2.35-r1.apk
apk add --allow-untrusted glibc-2.35-r1.apk
rm -rf glibc-2.35-r1.apk
# 启用/etc/local.d/
rc-update add local
rc-update add docker

apk update
apk add --upgrade apk-tools
apk upgrade --available

# 支持shutdown命令，比如阿里云控制台重启ECS
tee > /sbin/shutdown <<EOF
#!/bin/sh
/sbin/poweroff
EOF
sudo chmod 4777 /sbin/shutdown

sync
reboot

# 重启完后执行setup
/sbin/setup-alpine
```


## aliyun
## nvme
编辑`etc/mkinitfs/mkinitfs.conf`

添加`features="nvme"` nvme驱动

执行打包
```bash
mkinitfs -c /etc/mkinitfs/mkinitfs.conf -b / $(ls /lib/modules/)
```

## cloud-init
```bash
apk add cloud-init
sed -i 's/disable_root.*/disable_root: false/' /etc/cloud/cloud.cfg
sed -i "s/^datasource_list:.*/datasource_list: ['AliYun']/" /etc/cloud/cloud.cfg
sed -i "s/^ssh_pwauth.*/ssh_pwauth: true/" /etc/cloud/cloud.cfg
rm -rf /var/lib/cloud/*

rc-update add cloud-init-local
rc-update add cloud-init-hotplugd
rc-update add cloud-init
rc-update add cloud-config
rc-update add cloud-final
```

## service
### agent
```bash
去一台官方镜像阿里云机器拷贝整个agent目录出来，然后放入alpine linux中，将缺失的库拷贝到glibc混合层中
```
### assist
```bash
wget "https://aliyun-client-assist.oss-accelerate.aliyuncs.com/linux/aliyun_assist_latest_update.zip"
unzip  -o ./aliyun_assist_latest_update.zip -d /usr/local/share/aliyun-assist/
rm -f ./aliyun_assist_latest_update.zip
```
### init script
```bash
tee <<EOF > /etc/local.d/aliyun-service.start
/usr/local/share/aliyun-assist/*/aliyun-service -d
/usr/local/aegis/aegis_client/aegis_11_83/AliYunDun
/usr/local/aegis/aegis_client/aegis_11_83/AliYunDunMonitor
/usr/local/aegis/aegis_update/AliYunDunUpdate
EOF
chmod a+x /etc/local.d/aliyun-service.start
```