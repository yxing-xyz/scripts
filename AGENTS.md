# Repository Guidelines

## 项目结构与模块组织

本仓库用于构建各 Linux 发行版的容器/虚拟机镜像，并管理 dotfiles 与 NixOS 配置。

- `<distro>/<version>/rootfs.sh`：容器 rootfs 初始化脚本（如 `debian/latest/`、`almalinux/9/`）。
- `rootfs.Dockerfile`：共享 Dockerfile 模板，构建前将 `${IMAGE}` 占位符替换为发行版名，构建上下文为对应发行版目录。
- `alpine/packer/`、`arch/packer/`：基于 Packer + QEMU 的虚拟机镜像构建（`*.pkr.hcl`、`build.sh`）。
- `nix/`：NixOS 与 home-manager flake；`lib/` 为配置工厂函数，`home/config/` 为按程序拆分的模块，`pkgs/` 为本地包。
- `home/`：dotfiles，由根目录 `install.sh` 软链至 `$HOME`；含 zinit git 子模块。
- `config/`：主机资源（grub 主题、内核配置、键盘映射）；`coreos/`：Butane/Ignition 示例；`url/`：记录时间戳 URL 的小工具。
- `.github/workflows/`：每个发行版一个工作流，按路径过滤触发。

## 构建、测试与开发命令

- 容器镜像：`sed -i -e 's|${IMAGE}|debian|' rootfs.Dockerfile && docker buildx build --platform linux/amd64,linux/arm64/v8 -f rootfs.Dockerfile ./debian/latest`。
- Packer 镜像：`cd alpine/packer && ./build.sh x86_64`（或 `aarch64`），需本机安装 QEMU。
- dotfiles：`./install.sh`，幂等创建符号链接，已存在的链接自动跳过。
- NixOS：`sudo nixos-rebuild switch --flake ./nix#yoga`；home-manager：`home-manager switch --flake ./nix#x`。
- 克隆后执行 `git submodule update --init` 拉取 zinit 子模块。

## 编码风格与命名约定

- Shell 脚本以 `#!/bin/sh` 或 `#!/bin/bash` 开头并 `set -e`，使用 4 空格缩进。
- 新增发行版遵循 `<distro>/<version>/rootfs.sh` 目录模式；工作流文件以发行版命名（如 `debian.yaml`）。
- Nix 代码保持 `nix/` 现有模块划分，新程序配置放入 `nix/home/config/<name>.nix`。

## 测试指南

仓库无单元测试框架，以 CI 构建作为验证手段。修改 `rootfs.sh` 或 Dockerfile 后，本地至少完成一次对应发行版的 `docker build`；Packer 改动需跑通 `packer build`。推送后确认对应工作流绿灯。

## 提交与 PR 指南

- 提交信息简短、祈使式，中英均可（历史示例：`upgrade`、`fix: donf依赖dbus问题`），修复类可加 `fix:` 前缀。
- PR 需说明涉及的发行版/镜像及验证方式（构建日志或截图），并关联相关 issue；仅改动某发行版路径时，确认只触发对应工作流。

## 安全与配置提示

- 勿提交 registry 凭据；CI 统一使用 `secrets.REGISTRY/USERNAME/PASSWORD`。
- `rootfs.sh` 会设置 root 密码并放行 root SSH 登录，仅限构建测试镜像使用。
