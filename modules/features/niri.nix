# Niri 会话：合成器、Noctalia Shell、会话 portal 与所有 Niri 专属用户配置。
_: {
  den.aspects.niri = {
    nixos =
      { pkgs, noctalia, ... }:
      {
        environment.systemPackages = [
          pkgs.xwayland-satellite
          noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];
        programs.niri.enable = true;
        # 默认会话属于合成器 feature；移除 Niri 时不会在共享桌面层留下失效会话名。
        programs.noctalia-greeter = {
          greeter-args = "--session niri";
          settings.session.default = "niri";
        };
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
        repo = builtins.dirOf dotfiles;
        link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
        niriDir = ../../dotfiles/niri;
        inherit (mylib) regularFilesIn;
        niriFiles =
          regularFilesIn niriDir ++ map (file: "scripts/${file}") (regularFilesIn (niriDir + "/scripts"));
      in
      {
        # 两个兜底都必须先于会话首次启动生成，避免 Foot 或 Niri 因动态主题尚不存在而退出。
        home.activation.niriSeeds = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          footThemeDir="$HOME/.config/foot/themes"
          if [ ! -f "$footThemeDir/noctalia" ]; then
            mkdir -p "$footThemeDir" || exit 1
            install -m 644 ${../../dotfiles/foot/themes/noctalia} "$footThemeDir/noctalia" || exit 1
          fi

          repo="${repo}"
          cfgDir="$HOME/.config/noctalia"
          stateDir="$HOME/.local/state/noctalia"
          if [ ! -f "$cfgDir/config.toml" ]; then
            mkdir -p "$cfgDir" || exit 1
            sed "s|@REPO@|$repo|g" ${../../dotfiles/noctalia/config.toml} > "$cfgDir/config.toml" || exit 1
          fi
          if [ ! -f "$stateDir/settings.toml" ]; then
            mkdir -p "$stateDir" || exit 1
            sed "s|@HOME@|$HOME|g" ${../../dotfiles/noctalia/settings.toml} > "$stateDir/settings.toml" || exit 1
            touch "$stateDir/.setup-complete" || exit 1
          fi
          if [ ! -d "$stateDir/community-palettes" ]; then
            mkdir -p "$stateDir" || exit 1
            cp -r --no-preserve=mode ${../../dotfiles/noctalia/state}/. "$stateDir/" || exit 1
          fi

          niriKdl="$HOME/.config/niri/noctalia.kdl"
          if [ ! -f "$niriKdl" ]; then
            mkdir -p "$HOME/.config/niri" || exit 1
            touch "$niriKdl" || exit 1
          fi
        '';
        programs.foot.settings.main.include = "~/.config/foot/themes/noctalia";
        xdg.configFile = builtins.listToAttrs (
          map (file: {
            name = "niri/${file}";
            value.source = link "niri/${file}";
          }) niriFiles
        );
      };
  };
}
