# 仓库级检查：安装变体契约、双合成器配置、Shell、静态格式及双语文档。
{
  inputs,
  lib,
  self,
  ...
}:
let
  hostsDir = ../../hosts;
  hostDirs = lib.filterAttrs (_: type: type == "directory") (builtins.readDir hostsDir);
  hostNames = builtins.attrNames hostDirs;
  hostParams = lib.mapAttrs (name: _: import (hostsDir + "/${name}/host.nix")) hostDirs;

  hostContractHolds =
    name:
    let
      normal = self.nixosConfigurations.${name}.config;
      install = self.nixosConfigurations."${name}-install".config;
      params = hostParams.${name};
      proxy = params.proxy or null;
      userNames = builtins.attrNames params.users;
      legacyMangoServices = [
        "mango-audio-idle-inhibitor"
        "mango-bluetooth-applet"
        "mango-network-applet"
        "mango-polkit-agent"
        "mango-swayidle"
        "mango-swaync"
        "mango-swayosd"
        "mango-wallpaper"
        "mango-waybar"
        "mango-wlsunset"
      ];
      requiredMangoServices = [
        "mango-clip-persist"
        "mango-cliphist-image"
        "mango-cliphist-text"
        "mango-fcitx5"
        "mango-gopeed"
        "mango-noctalia"
        "mango-portal-watcher"
        "mango-screenshot-sound"
        "mango-session-guard"
        "mango-udiskie"
        "mango-wallpaper-random"
        "mango-xsettingsd"
        "mango-xwayland-dpi"
      ];
    in
    normal.networking.hostName == name
    && install.networking.hostName == name
    && normal.nix.settings.sandbox
    && install.nix.settings.sandbox
    && normal.services.flatpak.enable
    && !install.services.flatpak.enable
    && normal.age.secrets != { }
    && install.age.secrets == { }
    && builtins.hasAttr "home-manager" normal
    && !(builtins.hasAttr "home-manager" install)
    && normal.programs.niri.enable
    && normal.programs.mango.enable
    && install.programs.niri.enable
    && !install.programs.mango.enable
    && (normal.programs.noctalia-greeter.greeter-args or "") == ""
    && (install.programs.noctalia-greeter.greeter-args or "") == ""
    && (normal.programs.noctalia-greeter.settings.session.default or null) == null
    && (install.programs.noctalia-greeter.settings.session.default or null) == null
    && lib.all (user: builtins.hasAttr user normal."home-manager".users) userNames
    && lib.all (user: normal."home-manager".users.${user}.wayland.windowManager.mango.enable) userNames
    && lib.all (
      user:
      let
        services = normal."home-manager".users.${user}.systemd.user.services;
      in
      lib.all (service: builtins.hasAttr service services) requiredMangoServices
      && lib.all (service: !(builtins.hasAttr service services)) legacyMangoServices
      && builtins.hasAttr "fcitx5RimeProfile" normal."home-manager".users.${user}.home.activation
      &&
        builtins.elem "/run/current-system/sw/bin/fcitx5 --replace"
          services."mango-fcitx5".Service.ExecStart
      && lib.hasInfix "ensure-fcitx5-rime" services."mango-fcitx5".Service.ExecStartPre
      && lib.any (
        value: lib.hasInfix "/etc/profiles/per-user/${user}/bin" value
      ) services."mango-noctalia".Service.Environment
      && lib.any (
        value: lib.hasInfix "/run/current-system/sw/bin" value
      ) services."mango-noctalia".Service.Environment
    ) userNames
    && lib.all (
      user:
      builtins.elem "wheel" normal.users.users.${user}.extraGroups
      == (params.users.${user}.isAdmin or false)
      &&
        normal.users.users.${user}.openssh.authorizedKeys.keys
        == (params.users.${user}.sshAuthorizedKeys or [ ])
    ) userNames
    && normal.systemd.services.v2raya.environment.V2RAYA_ADDRESS == "127.0.0.1:2017"
    && (
      proxy == null
      || (
        normal.networking.proxy.default == proxy.default
        && normal.networking.proxy.noProxy == (proxy.noProxy or null)
      )
    );
  failedContractHosts = lib.filter (name: !(hostContractHolds name)) hostNames;
  noctaliaIdleSources = lib.concatMap (
    name:
    let
      normal = self.nixosConfigurations.${name}.config;
      userNames = builtins.attrNames hostParams.${name}.users;
    in
    map (user: normal."home-manager".users.${user}.xdg.configFile."noctalia/idle.toml".source) userNames
  ) hostNames;
in
{
  perSystem =
    { pkgs, system, ... }:
    {
      checks = {
        install-contract =
          assert lib.assertMsg (failedContractHosts == [ ])
            "normal/install configuration contract failed for: ${lib.concatStringsSep ", " failedContractHosts}";
          pkgs.runCommand "install-contract" { } ''
            test -x ${inputs.disko.packages.${system}.disko}/bin/disko
            touch "$out"
          '';

        shellcheck = pkgs.runCommand "shellcheck" { nativeBuildInputs = [ pkgs.shellcheck ]; } ''
          cd ${self}
          shellcheck --severity=warning \
            init.sh \
            dotfiles/mango/autostart.sh \
            dotfiles/mango/scripts/* \
            dotfiles/niri/scripts/* \
            dotfiles/noctalia/scripts/*

          # 两套会话会启动相同 watcher：必须单实例、绑定 Wayland 生命周期，且扳机按用户隔离。
          grep -q 'flock 9' dotfiles/noctalia/scripts/portal-watcher.sh
          grep -q 'WAYLAND_SOCKET' dotfiles/noctalia/scripts/portal-watcher.sh
          grep -q 'flock 9' dotfiles/noctalia/scripts/screenshot-sound.sh
          grep -q 'XDG_RUNTIME_DIR' dotfiles/noctalia/scripts/screenshot-sound.sh
          grep -q 'WAYLAND_SOCKET' dotfiles/noctalia/scripts/screenshot-sound.sh
          ! grep -q '/dev/shm/noctalia_screenshot_armed' dotfiles/noctalia/scripts/screenshot-sound.sh
          ! grep -q 'sleep infinity' dotfiles/noctalia/scripts/screenshot-sound.sh
          touch "$out"
        '';

        niri-config = pkgs.runCommand "niri-config" { nativeBuildInputs = [ pkgs.niri ]; } ''
          cp -R ${self}/dotfiles/niri "$TMPDIR/niri"
          chmod -R u+w "$TMPDIR/niri"
          touch "$TMPDIR/niri/noctalia.kdl"
          niri validate --config "$TMPDIR/niri/config.kdl"
          touch "$out"
        '';

        mango-config =
          pkgs.runCommand "mango-config"
            {
              nativeBuildInputs = [ inputs.mangowm.packages.${system}.mango ];
            }
            ''
                  export HOME="$TMPDIR/home"
                  mkdir -p "$HOME/.config"
                  cp -R ${self}/dotfiles/mango "$HOME/.config/mango"
                  chmod -R u+w "$HOME/.config/mango"
                  touch "$HOME/.config/mango/noctalia.conf"

                  mango -c "$HOME/.config/mango/config.conf" -p
                  grep -q 'noctalia msg panel-toggle launcher' "$HOME/.config/mango/binds.conf"
                  grep -q 'env -u GTK_IM_MODULE fcitx5 -r' "$HOME/.config/mango/binds.conf"
                  grep -q 'mango-session.target' "$HOME/.config/mango/autostart.sh"
                  grep -q 'QT_IM_MODULE' "$HOME/.config/mango/autostart.sh"
                  ! grep -q '^env=GTK_IM_MODULE' "$HOME/.config/mango/environment.conf"
                  grep -Fxq 'Name=rime' ${self}/dotfiles/fcitx5/profile
                  ! grep -Eiq 'waybar|swaync|rofi|wlogout|swayosd|swayidle|swaybg|wlsunset' "$HOME/.config/mango"/*.conf
              ${lib.concatMapStringsSep "\n" (source: "test -s ${source}") noctaliaIdleSources}
                  touch "$out"
            '';

        static-syntax =
          pkgs.runCommand "static-syntax"
            {
              nativeBuildInputs = with pkgs; [
                jq
                libxml2
                lua
                taplo
                yq-go
              ];
            }
            ''
              cd ${self}

              find dotfiles/nvim -type f -name '*.lua' -print0 | xargs -0 -n1 luac -p

              for file in \
                dotfiles/nvim/lazy-lock.json \
                pkgs/dsh/package.json \
                pkgs/dsh/package-lock.json; do
                jq empty "$file"
              done
              sed '/^[[:space:]]*\/\//d' dotfiles/fastfetch/config.jsonc | jq empty

              taplo check \
                dotfiles/noctalia/config.toml \
                dotfiles/noctalia/idle.toml \
                dotfiles/noctalia/settings.toml
              yq eval '.' .github/workflows/check.yml dotfiles/rime/default.custom.yaml >/dev/null
              xmllint --noout dotfiles/Thunar/uca.xml
              touch "$out"
            '';

        docs =
          pkgs.runCommand "docs"
            {
              nativeBuildInputs = [
                pkgs.cacert
                pkgs.lychee
              ];
            }
            ''
              cd ${self}
              export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
              lychee --offline --no-progress README.md README_EN.md doc/zh/*.md doc/en/*.md

              for base in README architecture maintenance agenix software shortcuts theming; do
                if [ "$base" = README ]; then
                  zh=README.md
                  en=README_EN.md
                else
                  zh="doc/zh/$base.md"
                  en="doc/en/$base.md"
                fi
                test "$(grep -c '^#{1,6} ' "$zh")" = "$(grep -c '^#{1,6} ' "$en")"
              done
              touch "$out"
            '';
      };
    };
}
