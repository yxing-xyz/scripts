{
  config,
  pkgs,
  lib,
  ...
}:

{
  system.stateVersion = "25.11"; # ⚠️ 只能升不能降
  hardware.graphics.enable = true;
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "70%";
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
  };
  boot.loader.grub = {
    theme = pkgs.nixos-grub2-theme;
    gfxmodeEfi = "1920x1080";
    # timeout 也可以放在这
  };
  boot.loader.timeout = 10;

  networking.networkmanager.enable = true;
  systemd.settings.Manager = {
    DefaultTimeoutStartSec = "10s";
    DefaultTimeoutStopSec = "10s";
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [ "https://mirrors.ustc.edu.cn/nix-channels/store" ];
    trusted-users = [
      "root"
      "@wheel"
    ];
    # 自动合并
    auto-optimise-store = true;
  };
  # 自动清理
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  nixpkgs.config.allowUnfree = true;
  hardware.enableRedistributableFirmware = true;
  users.users.root = {
    password = "root";
  };
  console = {
    # Nix 会直接将此文件路径转换为 store 路径
    keyMap = ../config/us.map.gz;
  };
  time.timeZone = "Asia/Shanghai";
  # 笔记本开启充电保护
  systemd.tmpfiles.rules = [
    "f /var/lib/upower/charging-threshold-status 0644 root root - 1"
  ];
  environment.systemPackages = with pkgs; [
    vim
    git
    lazygit
    git-lfs
    curl
    unzip
    fastfetch
    htop
    docker
    nixfmt
    lsof
  ];
  programs.zsh.enable = true;
}
