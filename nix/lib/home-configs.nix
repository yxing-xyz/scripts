{
  inputs,
  projectRoot,
  stateVersion,
}:
# 接收由外层传进来的静态 system 字符串
system:
let
  specialArgs = {
    inherit inputs projectRoot;
    dms = inputs.dms;
  };
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true; # 允许非自由软件
  };

  baseModules = username: homeDirectory: [
    ../home-cli.nix
    {
      home = { inherit username homeDirectory stateVersion; };
      targets.genericLinux.enable = true; # 确保非 NixOS 开发环境正常挂载
    }
  ];
in
{
  root = inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs = specialArgs;
    modules = baseModules "root" "/root";
  };

  x = inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs = specialArgs;
    modules = (baseModules "x" "/home/x") ++ [
      ../home-gui.nix
      { settings.enableGui = true; }
    ];
  };

  code = inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs = specialArgs;
    modules = baseModules "x" "/home/x";
  };
}
