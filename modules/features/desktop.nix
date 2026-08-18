# 桌面基础：两套 Wayland 会话共享的 greeter、portal、音频、文件管理、游戏与用户工具。
# 用户侧经 provides.to-users 投递给主机上所有用户（install 变体的非 HM 用户不受影响）
_: {
  den.aspects.desktop = {
    nixos =
      { pkgs, ... }:
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
      { pkgs, ... }:
      {
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
        # 系统工具：brightnessctl、udiskie（自动挂载）、fuzzel（启动器）、libnotify、file-roller（压缩包）、imagemagick
        # 其他：xsettingsd（X11 主题）、sunsetr（夜间色温）、sound-theme-freedesktop（快门声）、xprop/file（niri 脚本依赖）
        # 主题：adw-gtk3、adwaita-icon-theme、gsettings-desktop-schemas（供 Noctalia gtk 模板）
        home.packages = builtins.attrValues {
          inherit (pkgs)
            brightnessctl
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
              pad = "10x10 center";
            };
          };
        };
      };
  };
}
