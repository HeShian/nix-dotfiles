# Niri 会话：合成器、会话 portal 与所有 Niri 专属用户配置。
_: {
  den.aspects.niri = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.xwayland-satellite ];
        programs.niri.enable = true;
        # 分工保持原行为：gnome 负责截图/录屏/外观，gtk 负责文件选择，keyring 提供 Secret。
        xdg.portal.config.niri = {
          "org.freedesktop.impl.portal.Access" = [ "gtk" ];
          "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
          "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
          default = [
            "gnome"
            "gtk"
          ];
        };
      };

    provides.to-users.homeManager =
      {
        config,
        lib,
        mylib,
        ...
      }:
      let
        dotfiles = "${config.home.homeDirectory}/Documents/nix-dotfiles/dotfiles";
        link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
        niriDir = ../../dotfiles/niri;
        inherit (mylib) regularFilesIn;
        niriFiles =
          regularFilesIn niriDir ++ map (file: "scripts/${file}") (regularFilesIn (niriDir + "/scripts"));
      in
      {
        # 动态主题首次生成前必须存在空文件，否则 Niri 会因 include 目标缺失拒绝启动。
        home.activation.niriFallback = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          niriKdl="$HOME/.config/niri/noctalia.kdl"
          if [ ! -f "$niriKdl" ]; then
            mkdir -p "$HOME/.config/niri" || exit 1
            touch "$niriKdl" || exit 1
          fi
        '';
        xdg.configFile = builtins.listToAttrs (
          map (file: {
            name = "niri/${file}";
            value.source = link "niri/${file}";
          }) niriFiles
        );
      };
  };
}
