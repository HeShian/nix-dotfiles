# Mango 会话：官方 NixOS/HM 模块、仓库活链接配置与 Noctalia 会话服务。
_: {
  den.aspects.mango = {
    nixos = {
      # 上游模块同时提供登录会话、XWayland、Polkit 与 Mango 专用 portal；共享层不重复接管。
      programs.mango = {
        addLoginEntry = true;
        enable = true;
      };
    };

    provides.to-users.homeManager =
      {
        config,
        lib,
        mylib,
        pkgs,
        ...
      }:
      let
        dotfiles = "${config.home.homeDirectory}/Documents/nix-dotfiles/dotfiles";
        link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
        mangoDir = ../../dotfiles/mango;
        inherit (mylib) regularFilesIn;
        mangoFiles =
          regularFilesIn mangoDir ++ map (file: "scripts/${file}") (regularFilesIn (mangoDir + "/scripts"));

        mangoPackage = config.wayland.windowManager.mango.package;
        mangoServicePath = lib.makeBinPath (
          [
            mangoPackage
            pkgs.systemd
          ]
          ++ builtins.attrValues {
            inherit (pkgs)
              bash
              coreutils
              dbus
              file
              gawk
              gnugrep
              gnused
              imagemagick
              libnotify
              pipewire
              procps
              wl-clipboard
              ;
          }
        );
        # 用户服务显式设置 PATH 后不会继承 user manager 的搜索路径；Noctalia 启动器必须同时看见
        # 用户 profile、系统 profile、Flatpak 导出与受控的服务依赖，否则菜单能索引 .desktop 却无法执行。
        mangoSessionPath = lib.concatStringsSep ":" [
          "/run/wrappers/bin"
          "${config.home.homeDirectory}/.local/share/flatpak/exports/bin"
          "/var/lib/flatpak/exports/bin"
          "${config.home.homeDirectory}/.nix-profile/bin"
          "/nix/profile/bin"
          "${config.home.homeDirectory}/.local/state/nix/profile/bin"
          "/etc/profiles/per-user/${config.home.username}/bin"
          "/nix/var/nix/profiles/default/bin"
          "/run/current-system/sw/bin"
          mangoServicePath
        ];

        mkMangoService =
          {
            description,
            execStart,
            after ? [ ],
            serviceConfig ? { },
          }:
          {
            Unit = {
              Description = description;
              After = [ "mango-session.target" ] ++ after;
              PartOf = [ "mango-session.target" ];
            };
            Service = {
              Environment = [ "PATH=${mangoSessionPath}" ];
              ExecStart = execStart;
              Restart = "on-failure";
              RestartSec = 2;
            }
            // serviceConfig;
            Install.WantedBy = [ "mango-session.target" ];
          };
      in
      {
        # XWayland DPI 合并仍由 Mango 会话单独使用，其余依赖由共享桌面层提供。
        home.packages = [ pkgs.xrdb ];

        # 上游模块只负责安装 Mango 与声明 session target；配置文件改由下方仓库活链接拥有。
        wayland.windowManager.mango = {
          enable = true;
          systemd = {
            enable = true;
            # guard、Noctalia 后端和所有 systemd 服务都依赖实例 socket 与当前 Wayland 环境。
            variables = [
              "DISPLAY"
              "WAYLAND_DISPLAY"
              "XDG_CURRENT_DESKTOP"
              "XDG_SESSION_TYPE"
              "NIXOS_OZONE_WL"
              "XCURSOR_THEME"
              "XCURSOR_SIZE"
              "MANGO_INSTANCE_SIGNATURE"
            ];
          };
        };

        # Noctalia 首次生成主题前必须有可读取的文件；运行时文件不能链接进只读仓库。
        home.activation.mangoFallback = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          mangoTheme="$HOME/.config/mango/noctalia.conf"
          if [ ! -f "$mangoTheme" ]; then
            mkdir -p "$HOME/.config/mango" || exit 1
            touch "$mangoTheme" || exit 1
          fi
        '';

        xdg.configFile = builtins.listToAttrs (
          map (file: {
            name = "mango/${file}";
            value.source = link "mango/${file}";
          }) mangoFiles
        );

        systemd.user.services = {
          mango-session-guard = mkMangoService {
            description = "Mango session lifetime guard";
            execStart = "%h/.config/mango/scripts/session-guard";
            # 脚本区分 compositor 退出与 generation 切换，避免更新用户服务时误停整个会话 target。
            serviceConfig = {
              Restart = "no";
            };
          };
          mango-noctalia = mkMangoService {
            description = "Mango Noctalia shell";
            # 系统 profile 是跨 generation 的稳定入口，避免把临时 Nix store 路径写入用户服务。
            execStart = "/run/current-system/sw/bin/noctalia";
          };
          mango-fcitx5 = mkMangoService {
            description = "Mango input method";
            # 必须使用 NixOS i18n 生成的 with-addons 包；直接用 pkgs.fcitx5 会丢失 Rime。
            execStart = "/run/current-system/sw/bin/fcitx5 --replace";
            # F1/主题钩子替换实例后由 systemd 重新接管；同时防御旧用户管理器残留 GTK 变量。
            serviceConfig = {
              ExecStartPre = "%h/.config/noctalia/scripts/ensure-fcitx5-rime ${../../dotfiles/fcitx5/profile}";
              Restart = "always";
              UnsetEnvironment = "GTK_IM_MODULE";
            };
          };
          mango-udiskie = mkMangoService {
            description = "Mango removable media automounter";
            execStart = "${lib.getExe pkgs.udiskie} --automount --tray";
          };
          mango-xsettingsd = mkMangoService {
            description = "Mango XSettings bridge";
            execStart = lib.getExe pkgs.xsettingsd;
          };
          mango-portal-watcher = mkMangoService {
            description = "Mango portal color scheme watcher";
            after = [
              "mango-xsettingsd.service"
              "xdg-desktop-portal.service"
            ];
            execStart = "${pkgs.bash}/bin/bash %h/.config/noctalia/scripts/portal-watcher.sh";
          };
          mango-screenshot-sound = mkMangoService {
            description = "Mango screenshot sound watcher";
            execStart = "${pkgs.bash}/bin/bash %h/.config/noctalia/scripts/screenshot-sound.sh";
          };
          mango-clip-persist = mkMangoService {
            description = "Mango persistent clipboard";
            execStart = "${lib.getExe pkgs.wl-clip-persist} --clipboard regular --reconnect-tries 0";
          };
          mango-cliphist-text = mkMangoService {
            description = "Mango text clipboard history";
            execStart = "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${lib.getExe pkgs.cliphist} store";
          };
          mango-cliphist-image = mkMangoService {
            description = "Mango image clipboard history";
            execStart = "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${lib.getExe pkgs.cliphist} store";
          };
          mango-gopeed = mkMangoService {
            description = "Mango Gopeed download manager";
            execStart = "${lib.getExe pkgs.gopeed} --hidden";
          };
          mango-wallpaper-random = mkMangoService {
            description = "Mango initial random wallpaper";
            after = [ "mango-noctalia.service" ];
            execStart = "${pkgs.bash}/bin/bash -c '${pkgs.coreutils}/bin/sleep 5; /run/current-system/sw/bin/noctalia msg wallpaper-random'";
            serviceConfig = {
              RemainAfterExit = true;
              Restart = "no";
              Type = "oneshot";
            };
          };
          mango-xwayland-dpi = mkMangoService {
            description = "Mango XWayland DPI";
            after = [ "mango-xsettingsd.service" ];
            execStart = "${lib.getExe pkgs.xrdb} -merge %h/.config/mango/Xresources";
            serviceConfig = {
              RemainAfterExit = true;
              Restart = "no";
              Type = "oneshot";
            };
          };
        };
      };
  };
}
