{
  config,
  pkgs,
  lib,
  ...
}:
let
  # 将你的配置定义为一个变量
  myChronyConfig = pkgs.writeText "my-chrony.conf" ''
    # 配置了一个时间服务器池
    pool ntp.aliyun.com iburst

    # 最大更新偏斜值（单位：秒）；
    # 核心作用：chrony 会持续计算上游 NTP 服务器的时间偏移（你的时钟 vs 服务器时钟），
    # 如果某次计算出的偏移值超过这个阈值，chrony 会判定该服务器的测量结果 “不可靠”，拒绝用这个值更新本地时钟，同时会忽略该服务器的此次测量数据
    # 它只是为了防止单次的网络波动导致时间瞬间乱跳，而不是为了阻止时间最终同步。
    # 建议互联网设置100 局域网设置3
    maxupdateskew 100

    # 最小源数量
    minsources 1

    # 作用：1. 当系统时间与NTP服务器的偏差超过1.0秒时，执行"跳变修正"（直接把时间拨准）；2. 仅在Chrony启动后的前3次同步中生效
    # 注意：启动完成后，即使偏差超1.0秒，也会改用缓慢漂移（slew）修正，避免时间跳变影响业务
    makestep 1.0 3

    # slew启用闰秒平滑调整模式, 当遇到闰秒时，不进行时间跳跃（Step），而是通过拉长或缩短时间的方式，用一段时间（通常是 24 小时）慢慢把这 1 秒钟 “消化” 掉。
    leapsecmode slew

    # local stratum 10：启用本机作为NTP服务器的兜底模式，设置本机时钟层级为10
    # 作用：当本机无法同步上游NTP服务器时，仍可向局域网客户端提供时间服务
    # stratum含义：NTP层级（1=原子钟/GPS，数值越大精度越低，16=未同步）
    local stratum 10

    # 禁用客户端访问日志和交错模式，核心价值是节省内存
    noclientlog

    # 当日志记录的时钟调整幅度超过0.5秒时，向系统日志（syslog）输出告警信息
    logchange 0.5

    # 为所有支持硬件时间戳的网卡启用该功能（*为通配符）
    # 作用：由网卡硬件而非系统内核记录NTP数据包的收发时间，消除内核延迟，大幅提升同步精度（至亚毫秒级）
    hwtimestamp *


    # 作用：每隔11分钟自动将系统时钟（System Time）同步到硬件时钟（RTC/CMOS），确保关机/重启后时间不回退
    # 注意：这是Chrony的标准配置，通常应保持启用状态
    rtcsync


    # 作用：防止数据落盘泄露（特别是密钥），并保证极低延迟的响应。
    # 建议：只要内存够用，建议一直开启，尤其是在使用加密功能时。
    lock_all
  '';
in
{
  system.stateVersion = "25.11";
  # 自动清理
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
        # "https://mirrors.nju.edu.cn/nix-channels/store"
        "https://cache.nixos.org"
        "https://niri.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      ];
      download-attempts = 3;
      trusted-users = [
        "root"
        "@wheel"
        "x"
      ];
      # 自动合并
      auto-optimise-store = true;
    };
  };
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "70%";
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "kernel.sysrq" = 1;
  };
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true; # 联想主板不让改 NVRAM，我们就放弃改它
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    # 这一行是关键！它会生成 /EFI/BOOT/BOOTX64.EFI
    efiInstallAsRemovable = false;

    device = "nodev";
    gfxmodeEfi = "1024x768";
    fontSize = 32; # 3K 屏建议直接 64

    # 既然你根目录下有这两个文件，直接引用它们
    # 如果 NixOS 自动生成的字体不行，我们可以手动指定那个 pf2
    # font = "${/boot/converted-font.pf2}";
  };
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  boot.binfmt.registrations."aarch64-linux" = {
    # 使用静态编译的 QEMU
    interpreter = "${pkgs.pkgsStatic.qemu-user}/bin/qemu-aarch64";
    fixBinary = true;
  };

  networking.networkmanager.enable = true;
  systemd.settings.Manager = {
    DefaultTimeoutStartSec = "10s";
    DefaultTimeoutStopSec = "10s";
  };
  users.users.root = {
    password = "root";
  };
  console = {
    # Nix 会直接将此文件路径转换为 store 路径
    keyMap = ../config/us.map.gz;
  };
  time.timeZone = "Asia/Shanghai";
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
    difftastic
    umoci
    qemu
    nixfmt
    lsof
    home-manager
    file
    aria2
    efibootmgr
    pciutils
    rsync
    jq
  ];
  # 模拟标准的FHS文件系统布局
  # services.envfs.enable = true;
  # 1. 禁用默认的 systemd-timesyncd（防止冲突）
  services.timesyncd.enable = false;

  # 2. 开启 Chrony 并注入你的配置
  services.chrony = {
    enable = true;
    extraFlags = [
      "-f"
      "${myChronyConfig}"
    ];
  };
  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";

  # 配置 Docker 镜像加速器
  virtualisation.docker.daemon.settings = {
    registry-mirrors = [
      "https://2a6bf1988cb6428c877f723ec7530dbc.mirror.swr.myhuaweicloud.com"
      "https://d.yydy.link:2023"
      "https://docker.1ms.run"
      "https://docker.etcd.fun"
      "https://docker.m.ixdev.cn"
      "https://hub.mirrorify.net"
      "https://hub3.nat.tf"
      "https://proxy.vvvv.ee"
      "https://dockerproxy.net"
      "https://docker.xuanyuan.me"
    ];
  };
}
