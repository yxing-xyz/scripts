{
  inputs,
  projectRoot,
  stateVersion,
}:
let

  # 统一的 Home Manager 配置模块
  homeManagerCommon = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "nixbak";
    home-manager.extraSpecialArgs = {
      inherit inputs projectRoot;
      dms = inputs.dms;
    };

    # 自动定义用户配置
    home-manager.users = {
      x = {
        imports = [
          ../home-cli.nix
          ../home-gui.nix
        ];
        home = {
          username = "x";
          homeDirectory = "/home/x";
          inherit stateVersion;
        };
      };
      root = {
        imports = [
          ../home-cli.nix
        ];
        home = {
          username = "root";
          homeDirectory = "/root";
          inherit stateVersion;
        };
      };
    };
  };
  commonModules = [
    ../configuration.nix
    ../graphical.nix
    inputs.home-manager.nixosModules.home-manager
    homeManagerCommon
    {
      nixpkgs.config.allowUnfree = true;
      _module.args = {
        inherit inputs projectRoot stateVersion;
      };
    }
  ];
in
{
  x = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = commonModules ++ [
      ../hardware-configuration.nix
      {
        networking.hostName = "x";
        boot.loader.grub.enable = inputs.nixpkgs.lib.mkForce true; # 强制物理机启用 GRUB
      }
    ];
  };

  test = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = commonModules ++ [
      {
        networking.hostName = "test";
        hardware.graphics.enable = true;
        virtualisation.vmVariant = {
          virtualisation = {
            memorySize = 4096;
            cores = 4;
            qemu.options = [
              "-device virtio-vga-gl"
              "-display gtk,gl=on"
            ];
            sharedDirectories.config_repo = {
              source = projectRoot;
              target = projectRoot;
            };
          };
        };
      }
    ];
  };

}
