{ config, lib, pkgs, modulesPath, ... }:

let
  # 定义公共的 Btrfs 挂载选项，增强可维护性
  btrfsOpts = [ "compress=zstd" "discard=async" ];
  noatimeOpts = btrfsOpts ++ [ "noatime" ];
in
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # 1. 固件与 CPU 支持
  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  # 2. 启动与内核设置
  boot = {
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };

  # 3. 文件系统挂载 (使用变量简化)
  fileSystems = {
    "/"         = { device = "/dev/disk/by-uuid/69fb64e8-926b-41bd-98da-025e32ab1d20"; fsType = "btrfs"; options = [ "subvol=@" ] ++ noatimeOpts; };
    "/home"     = { device = "/dev/disk/by-uuid/69fb64e8-926b-41bd-98da-025e32ab1d20"; fsType = "btrfs"; options = [ "subvol=@home" ] ++ btrfsOpts; };
    "/nix"      = { device = "/dev/disk/by-uuid/69fb64e8-926b-41bd-98da-025e32ab1d20"; fsType = "btrfs"; options = [ "subvol=@nix" ] ++ noatimeOpts; };
    "/var/log"  = { device = "/dev/disk/by-uuid/69fb64e8-926b-41bd-98da-025e32ab1d20"; fsType = "btrfs"; options = [ "subvol=@log" ] ++ noatimeOpts; };
    "/boot/efi" = { device = "/dev/disk/by-uuid/23BB-F42B"; fsType = "vfat"; options = [ "fmask=0022" "dmask=0022" ]; };
  };

  # 4. 音频服务 (PipeWire 优化)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber = {
      enable = true;
      extraConfig."10-bluez" = {
        "monitor.bluez5.properties" = {
          "bluez5.enable-sbc-xq" = true;
          "bluez5.enable-msbc" = true;
          "bluez5.enable-hw-volume" = true;
        };
      };
    };
  };

  # 5. 其他杂项
  # 充电保护规则保持不变
  systemd.tmpfiles.rules = [ "f /var/lib/upower/charging-threshold-status 0644 root root - 1" ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
