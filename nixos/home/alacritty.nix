{
  config,
  pkgs,
  ...
}:

{
  home.file.".config/alacritty/theme.toml".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/rajasegar/alacritty-themes/master/themes/Tokyonight_Night.toml";
    # 这里需要填入文件的 hash。你可以先填空字符串，运行 nix switch，根据报错提示的 hash 填回来
    sha256 = "sha256-MvQfVo786H1hTVRmvygAoVKel2e8kam2SAc62skd7rc=";
  };
  # 这一行确保 alacritty 软件包已安装
  home.packages = [ pkgs.alacritty ];

  # 直接把字符串写入 ~/.config/alacritty/alacritty.toml
  # xdg.configFile."alacritty/alacritty.toml".source = config.lib.file.mkOutOfStoreSymlink "${projectRoot}/home/.config/alacritty/alacritty.toml";
  xdg.configFile."alacritty/alacritty.toml".source = config.lib.file.mkOutOfStoreSymlink ../../home/.config/alacritty/alacritty.toml;
}
