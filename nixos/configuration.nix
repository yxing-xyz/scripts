{
  config,
  pkgs,
  lib,
  inputs,
  stateVersion,
  ...
}:

{
  system.stateVersion = stateVersion;
  boot.kernelPackages = pkgs.linuxPackages;

  # --- 1. 引导加载器配置 (使用 mkDefault) ---
  boot.loader = {
    systemd-boot.enable = lib.mkDefault false;
    grub = {
      enable = lib.mkDefault true;
      efiSupport = lib.mkDefault true;
      useOSProber = lib.mkDefault true;
      efiInstallAsRemovable = lib.mkDefault false;
      device = lib.mkDefault "nodev";
      gfxmodeEfi = lib.mkDefault "1024x768";
      fontSize = lib.mkDefault 32;
    };
    efi = {
      canTouchEfiVariables = lib.mkDefault true;
      efiSysMountPoint = lib.mkDefault "/boot/efi";
    };
  };

  # --- 2. 基础系统性能优化 ---
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "70%";
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "kernel.sysrq" = 1;
  };

  # binfmt 用于 ARM 模拟
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # --- 3. 网络与防火墙 ---
  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowPing = true;
      # 使用 ranges 语法简化
      allowedTCPPortRanges = [
        {
          from = 1;
          to = 65535;
        }
      ];
      allowedUDPPortRanges = [
        {
          from = 1;
          to = 65535;
        }
      ];
      checkReversePath = false;
    };
  };

  # --- 4. 服务与用户 ---
  services.chrony = {
    enable = true;

    # 修正：直接使用字符串列表，将 iburst 作为字符串的一部分
    servers = [
      "ntp.aliyun.com iburst"
    ];

    # 其余配置保持不变
    enableMemoryLocking = true;

    makestep = {
      enable = true;
      threshold = 1.0;
      limit = 3;
    };

    extraConfig = ''
      maxupdateskew 100
      minsources 1
      leapsecmode slew
      local stratum 10
      noclientlog
      logchange 0.5
      hwtimestamp *
    '';
  };
  users.users = {
    root = {
      password = "root";
      shell = pkgs.zsh;
    };
    x = {
      isNormalUser = true;
      uid = 1000;
      extraGroups = [
        "networkmanager"
        "wheel"
        "video"
        "wireshark"
        "docker"
      ];
      initialPassword = "x";
      shell = pkgs.zsh;
    };
  };

  # --- 5. Nix 设置 ---
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      substituters = [
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
        "https://niri.cachix.org"
        "https://nix-community.cachix.org"
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
      trusted-users = "*";
      system-features = [ "gccarch-x86-64-v4" ];
      accept-flake-config = true;
      max-jobs = "auto";
    };
  };

  # 其他配置保持原样...
  virtualisation.docker = {
    enable = true;
    storageDriver = "overlay2";
  };
  time.timeZone = "Asia/Shanghai";
  nixpkgs.config.allowUnfree = true;
}
