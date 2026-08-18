# 用户基础环境：通用 dotfiles 活链接、.agents skills、Rime 与英文用户目录。
_: {
  den.aspects.dotfiles.homeManager =
    {
      config,
      lib,
      nixkits,
      ...
    }:
    let
      dotfiles = "${config.home.homeDirectory}/Documents/nix-dotfiles/dotfiles";
      # 活链接（指向仓库本身）
      link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
      # 整目录链接：dotfiles/<name> → ~/.config/<name>
      configs = [
        "Thunar"
        "fastfetch"
        "nvim"
        "xsettingsd"
      ];
    in
    {
      home.file = {
        ".local/share/fcitx5/rime/default.custom.yaml".source = link "rime/default.custom.yaml";
      }
      // lib.mapAttrs' (name: _: {
        name = ".agents/skills/${name}";
        value.source = "${nixkits}/skills/${name}";
      }) (lib.filterAttrs (_: type: type == "directory") (builtins.readDir "${nixkits}/skills"));
      # username/homeDirectory 由 HM NixOS 模块按系统用户配置推断（多用户自动正确）
      home.stateVersion = "25.05";
      xdg.configFile = lib.genAttrs configs (name: {
        source = link name;
      });
      # 固定英文目录名，防止应用创建中文目录
      xdg.userDirs = {
        createDirectories = true;
        enable = true;
        # 显式固定现状（home.stateVersion < 26.05 的旧默认），消除求值警告
        setSessionVariables = true;
      };
    };
}
