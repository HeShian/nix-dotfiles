# 桌面基础：两套 Wayland 会话共享的 Noctalia、greeter、portal、音频、文件管理、游戏与用户工具。
# 用户侧经 provides.to-users 投递给主机上所有用户（install 变体的非 HM 用户不受影响）
_: {
  den.aspects.desktop = {
    nixos =
      { noctalia, pkgs, ... }:
      {
        environment = {
          sessionVariables = {
            NIXOS_OZONE_WL = "1";
            # Noctalia gtk 模板依赖的 schema 路径
            XDG_DATA_DIRS = [
              "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
            ];
            XDG_SESSION_TYPE = "wayland";
          };
          # 基础工具 vim/git/wget；glib/dconf 提供 gsettings CLI。
          systemPackages = with pkgs; [
            vim
            git
            wget
            glib
            dconf
            noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
          ];
        };
        # 系统模块自动放行端口
        programs.kdeconnect.enable = true;
        programs.noctalia-greeter = {
          enable = true;
          settings = {
            cursor = {
              size = 24;
              theme = "Bibata-Modern-Classic";
            };
            idle.timeout = 300;
            keyboard.layout = "us";
            keyboard.numlock = true;
          };
        };
        # 系统模块提供 udev 规则与端口
        programs.steam.enable = true;
        programs.thunar = {
          enable = true;
          # 插件：压缩包集成、可移动卷管理
          plugins = builtins.attrValues {
            inherit (pkgs) thunar-archive-plugin thunar-volman;
          };
        };
        # 随登录密码解锁 keyring（否则 Electron 应用开机弹密码框）；greetd 的 PAM 全部
        # substack 到 login（其模块 useDefaultRules=false，greetd 服务上的同名选项无效）
        security.pam.services.login.enableGnomeKeyring = true;
        # Pipewire 实时调度
        security.rtkit.enable = true;
        # Secret Service 后端（Electron 应用需要）
        services.gnome.gnome-keyring.enable = true;
        services.greetd = {
          enable = true;
          settings = {
            default_session.user = "greeter";
          };
        };
        # Thunar 回收站与网络挂载
        services.gvfs.enable = true;
        services.pipewire = {
          alsa = {
            enable = true;
            support32Bit = true;
          };
          enable = true;
          pulse.enable = true;
        };
        services.power-profiles-daemon.enable = true;
        # Thunar 缩略图
        services.tumbler.enable = true;
        # Thunar 侧边栏挂载
        services.udisks2.enable = true;
        # 会话各自声明 portal 路由；这里只提供共享后端。
        xdg.portal = {
          enable = true;
          extraPortals = builtins.attrValues {
            inherit (pkgs) xdg-desktop-portal-gnome xdg-desktop-portal-gtk;
          };
        };
      };

    provides.to-users.homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        dotfiles = "${config.home.homeDirectory}/Documents/nix-dotfiles/dotfiles";
        link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
        repo = builtins.dirOf dotfiles;
      in
      {
        # Noctalia 的运行时配置由其 GUI 维护；这里只在首次登录时播种，避免 rebuild 覆盖用户选择。
        home.activation.noctaliaSeeds = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
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
          # 旧进程会把已删除的 GTK_IM_MODULE 继续传给主题钩子；只迁移这一条已知旧值，不覆盖 GUI 配置。
          if grep -Fq 'post_hook   = "(fcitx5 -r >/dev/null 2>&1 &)"' "$cfgDir/config.toml"; then
            sed -i 's|post_hook   = "(fcitx5 -r >/dev/null 2>\&1 \&)"|post_hook   = "(~/.config/noctalia/scripts/restart-fcitx5 >/dev/null 2>\&1 \&)"|' "$cfgDir/config.toml"
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
        '';
        # Xfce 默认终端
        home.file.".config/xfce4/helpers.rc".text = ''
          TerminalEmulator=foot
        '';
        # Thunar「创建文档」菜单模板
        home.file."Templates/Excel 工作簿.xlsx".source = ../../dotfiles/Templates + "/Excel 工作簿.xlsx";
        home.file."Templates/Markdown 文档.md".text = "";
        home.file."Templates/PowerPoint 演示文稿.pptx".source =
          ../../dotfiles/Templates + "/PowerPoint 演示文稿.pptx";
        home.file."Templates/Word 文档.docx".source = ../../dotfiles/Templates + "/Word 文档.docx";
        home.file."Templates/文本文档.txt".text = "";
        # 截图/录屏：grim、slurp、wf-recorder、satty（标注）
        # 剪贴板：cliphist、wl-clipboard、wl-clip-persist
        # 媒体：imv（看图）、mpv、mpvpaper（视频壁纸）、cava（音频可视化）、pwvucontrol（音量）、playerctl
        # 系统工具：brightnessctl、udiskie（自动挂载）、fuzzel（启动器）、libnotify、file-roller（压缩包）、curl/jq/imagemagick
        # 其他：xsettingsd（X11 主题）、sunsetr（夜间色温）、sound-theme-freedesktop（快门声）、xprop/file（niri 脚本依赖）
        # 主题：adw-gtk3、adwaita-icon-theme、gsettings-desktop-schemas（供 Noctalia gtk 模板）
        home.packages = builtins.attrValues {
          inherit (pkgs)
            brightnessctl
            curl
            imv
            mpv
            mpvpaper
            wf-recorder
            grim
            slurp
            cliphist
            wl-clipboard
            wl-clip-persist
            pwvucontrol
            udiskie
            cava
            playerctl
            xsettingsd
            fuzzel
            libnotify
            xprop
            sound-theme-freedesktop
            satty
            imagemagick
            jq
            file
            sunsetr
            file-roller
            adwaita-icon-theme
            adw-gtk3
            gsettings-desktop-schemas
            ;
        };
        # GTK/Qt 颜色由 Noctalia 模板接管，不用 HM gtk 模块
        home.pointerCursor = {
          enable = true;
          name = "Bibata-Modern-Classic";
          package = pkgs.bibata-cursors;
          size = 24;
        };
        programs.foot = {
          enable = true;
          settings = {
            "colors-dark" = {
              alpha = 0.8;
            };
            main = {
              font = "JetBrainsMono Nerd Font:size=18";
              include = "~/.config/foot/themes/noctalia";
              pad = "10x10 center";
            };
          };
        };
        xdg.configFile = {
          # 独立片段确保现有用户也获得共享策略；settings.toml 仍按 Noctalia 规则最后加载并可覆盖。
          "noctalia/idle.toml".source = ../../dotfiles/noctalia/idle.toml;
          # 合成器无关脚本由两套会话共用；活链接便于直接修正 portal、截图音效和壁纸下载逻辑。
          "noctalia/scripts/portal-watcher.sh".source = link "noctalia/scripts/portal-watcher.sh";
          "noctalia/scripts/random-anime-wallpaper".source = link "noctalia/scripts/random-anime-wallpaper";
          "noctalia/scripts/ensure-fcitx5-rime".source = link "noctalia/scripts/ensure-fcitx5-rime";
          "noctalia/scripts/restart-fcitx5".source = link "noctalia/scripts/restart-fcitx5";
          "noctalia/scripts/screenshot-sound.sh".source = link "noctalia/scripts/screenshot-sound.sh";
        };
      };
  };
}
