```bash
qemu-img create -f qcow2 gentoo.qcow2 100G

# 桥接网卡参数 -nic vmnet-bridged,ifname=en0 \
sudo qemu-system-aarch64 \
    -machine virt \
    -accel hvf \
    -boot d \
    -cpu host \
    -smp 8 \
    -m 4096 \
    -bios /opt/homebrew/Cellar/qemu/7.2.0/share/qemu/edk2-aarch64-code.fd \
    -drive format=qcow2,file=gentoo.qcow2 \
    -cdrom  install-arm64-minimal-20230226T234708Z.iso\
    -device virtio-gpu \
    -device usb-ehci \
    -device usb-kbd \
    -device usb-mouse \
    -nic user,hostfwd=tcp::60022-:22
```
### install gentoo
下载livecd进入
1. parted分区
```bash
##
paretd
mklabel gpt
mkparted linux 1M 100G
exit
```
2. 格式化分区, 挂载分区
```bash
mkfs.ext4 /dev/vda1
mount /dev/vda1 /mnt/gentoo
```

3. 上传,解压stage3
```bash
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
```

4. make.conf,换源
编辑`/mnt/gentoo/etc/portage/make.conf`,修改增加以下内容
```txt
# march指定了mac m1芯片，如果是amd64请自行修改, -j参数需要考虑内存，小心编译器爆内存
COMMON_FLAGS="-march=armv8-a -O2 -pipe"
MAKEOPTS="-j8"
USE="-X"
GENTOO_MIRRORS="http://mirrors.tencent.com/gentoo/"
```
```bash
mirrorselect -i -o >> /mnt/gentoo/etc/portage/make.conf
mkdir --parents /mnt/gentoo/etc/portage/repos.conf
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf
sed "s|rsync://rsync.gentoo.org/gentoo-portage|rsync://mirrors.tencent.com/gentoo-portage|" /mnt/gentoo/etc/portage/repos.conf/gentoo.conf
```

5. 挂载
```bash
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run
mount --make-slave /mnt/gentoo/run
```
6. 进入新环境，同步源, 选配置文件
```bash
chroot /mnt/gentoo /bin/bash
source /etc/profile
export PS1="(chroot) ${PS1}"
emerge-webrsync
emerge --sync
eselect profile list
# 这里选的systemd无桌面，带桌面的自行修改
eselect profile set 14
emerge --ask --verbose --update --deep --newuse @world
```

7. USE
```bash
# emerge --ask app-portage/cpuid2cpuflags
# echo "*/* $(cpuid2cpuflags)" > /etc/portage/package.use/00cpu-flags
```

8. systemd设置时区
```bash
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
eselect locale set zh_CN.utf8
# 重新加载环境
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
```
9. 配置内核
9.1 使用 distribution内核，支持大多数硬件
```bash
# grub, lilo传统启动使用
# emerge --ask sys-kernel/installkernel-gentoo

emerge --ask sys-kernel/installkernel-systemd-boot

# 安装源码编译内核
# emerge --ask sys-kernel/gentoo-kernel

# 安装二进制内核
emerge --ask sys-kernel/gentoo-kernel-bin
# 清除旧软件包
emerge --depclean
# 为了节省空间，可以选择清除旧版本内核
# emerge --prune sys-kernel/gentoo-kernel sys-kernel/gentoo-kernel-bin

# 只要内核更新就要重建inittramfs
emerge --ask @module-rebuild
```

10. 应用软件
```bash
emerge --ask vim emacs go ssh
```