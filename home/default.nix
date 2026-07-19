{ config, pkgs, userName, ... }:

let
  dotfiles = "${config.home.homeDirectory}/Documents/nix-dotfiles/dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";

  configs = {
    fastfetch = "fastfetch";
    nvim = "nvim";
    Thunar = "Thunar";
    xsettingsd = "xsettingsd";
    yazi = "yazi";
  };

  # niri 逐文件链接（而非整目录链接）：~/.config/niri 是真实目录，
  # 让 Noctalia 主题模板生成的 noctalia.kdl 落在 git 仓库之外
  niriFiles = [
    "animations.kdl"
    "binds.kdl"
    "blur.kdl"
    "config.kdl"
    "cursor.kdl"
    "layout.kdl"
    "outputs.kdl"
    "windowrules.kdl"
    "scripts/niri-binds"
    "scripts/niri-force-kill-window"
    "scripts/niri-pick"
    "scripts/portal-watcher.sh"
    "scripts/random-anime-wallpaper"
    "scripts/screenshot-edit.sh"
    "scripts/screenshot-sound.sh"
  ];
in
{
  imports = [
    ./desktop.nix
    ./shell.nix
    ./app.nix
  ];

  home.username = userName;
  home.homeDirectory = "/home/${userName}";
  home.stateVersion = "25.05";

  home.file.".local/share/fcitx5/rime/default.custom.yaml".source = link "rime/default.custom.yaml";

  # 配置文件
  xdg.configFile = builtins.mapAttrs (name: value: {
    source = link value;
  }) configs // builtins.listToAttrs (map (file: {
    name = "niri/${file}";
    value.source = link "niri/${file}";
  }) niriFiles);
}
