{
  config,
  pkgs,
  lib,
  userName,
  nixkits,
  ...
}:
let
    dotfiles = "${config.home.homeDirectory}/Documents/nix-dotfiles/dotfiles";
    repo = builtins.dirOf dotfiles;
    # 活链接（指向仓库本身）
    link =     path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
    # 整目录链接：dotfiles/<name> → ~/.config/<name>
    configs = [
      "Thunar"
      "fastfetch"
      "nvim"
      "xsettingsd"
    ];
    # 逐文件链接（~/.config/niri 需是真实目录）
    niriDir = ../dotfiles/niri;
    regularFilesIn =     dir: lib.mapAttrsToList (name: _: name) (lib.filterAttrs (_: type: type == "regular") (builtins.readDir dir));
    niriFiles = regularFilesIn niriDir ++ map (file: "scripts/${file}") (regularFilesIn (niriDir + "/scripts"));
in
  {
    # Noctalia 配置种子（仅目标缺失时拷贝）
    home.activation.noctaliaSeed = lib.hm.dag.entryAfter [
      "writeBoundary"
    ] ''
    repo="${repo}"
    cfgDir="$HOME/.config/noctalia"
    stateDir="$HOME/.local/state/noctalia"
    if [ ! -f "$cfgDir/config.toml" ]; then
      mkdir -p "$cfgDir" || exit 1
      sed "s|@REPO@|$repo|g" ${../dotfiles/noctalia/config.toml} > "$cfgDir/config.toml" || exit 1
    fi
    if [ ! -f "$stateDir/settings.toml" ]; then
      mkdir -p "$stateDir" || exit 1
      sed "s|@HOME@|$HOME|g" ${../dotfiles/noctalia/settings.toml} > "$stateDir/settings.toml" || exit 1
      touch "$stateDir/.setup-complete" || exit 1
    fi
    if [ ! -d "$stateDir/community-palettes" ]; then
      mkdir -p "$stateDir" || exit 1
      cp -r --no-preserve=mode ${../dotfiles/noctalia/state}/. "$stateDir/" || exit 1
    fi
  '';
    home.file = {
      ".local/share/fcitx5/rime/default.custom.yaml".source = link "rime/default.custom.yaml";
    } // lib.mapAttrs' (name: _:
{
      name = ".agents/skills/${name}";
      value.source = "${nixkits}/skills/${name}";
    }) (lib.filterAttrs (_: type: type == "directory") (builtins.readDir "${nixkits}/skills"));
    home.homeDirectory = "/home/${userName}";
    home.stateVersion = "25.05";
    home.username = userName;
    imports = [
      ./desktop.nix
      ./shell.nix
      ./app.nix
    ];
    xdg.configFile = lib.genAttrs configs (name:
    {
        source = link name;
      }) // builtins.listToAttrs (map (file:
    {
        name = "niri/${file}";
        value.source = link "niri/${file}";
      }) niriFiles);
    # 固定英文目录名，防止应用创建中文目录
    xdg.userDirs = {
      createDirectories = true;
      enable = true;
      # 显式固定现状（home.stateVersion < 26.05 的旧默认），消除求值警告
      setSessionVariables = true;
    };
  }
