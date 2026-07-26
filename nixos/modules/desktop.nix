{
  lib,
  pkgs,
  noctalia,
  ...
}:
{
    # 系统软件包与环境变量
    environment = {
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        # gsettings schema 路径（Noctalia GTK 模板/图标重着色脚本依赖 gsettings）
        XDG_DATA_DIRS = [
          "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
        ];
        XDG_SESSION_TYPE = "wayland";
      };
      systemPackages = with pkgs;
      [
              vim
              git
              wget
              # niri 无内置 XWayland，X11 应用经它运行
              xwayland-satellite
              glib
              # gsettings/dconf CLI：Noctalia gtk 模板同步深色模式、portal 调试用
              dconf
              # Noctalia 桌面 Shell 本体
              noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
            ];
    };
    # KDE Connect（系统模块自动放行防火墙 1714-1764；只装包不开端口会配对失败）
    programs.kdeconnect.enable = true;
    # Niri 合成器（Wayland 滚动平铺）
    programs.niri.enable = true;
    # 登录界面：greetd + noctalia-greeter
    programs.noctalia-greeter = {
      enable = true;
      greeter-args = "--session niri";
      settings = {
        cursor = {
          size = 24;
          theme = "Bibata-Modern-Classic";
        };
        idle.timeout = 300;
        keyboard.layout = "us";
        keyboard.numlock = true;
        session.default = "niri";
      };
    };
    # Steam 系统模块（udev 规则与 Remote Play 端口；steam 包不再装到 home/app.nix）
    programs.steam.enable = true;
    # Thunar 文件管理器（NixOS 模块：xfconf/插件/gvfs 回收站与网络挂载/tumbler 缩略图）
    programs.thunar = {
      enable = true;
      plugins = builtins.attrValues {
        inherit (pkgs.xfce) thunar-archive-plugin thunar-volman;
      };
    };
    # 图形登录时随密码解锁 gnome-keyring，否则走 Secret portal 的 Electron 应用每次开机弹密码框
    security.pam.services.greetd.enableGnomeKeyring = true;
    # 控制台 TTY 不启用（图形登录走 greetd）
    security.pam.services.login.enableGnomeKeyring = lib.mkForce false;
    security.rtkit.enable = true;
    # 为 Pipewire 提供实时调度优先级
    # gnome-keyring：Secret Service 后端，Electron 应用（WeChat 等）需要
    services.gnome.gnome-keyring.enable = true;
    services.greetd = {
      enable = true;
      settings = {
        default_session.user = "greeter";
      };
    };
    services.gvfs.enable = true;
    # Thunar 的回收站与网络挂载后端
    # 音频（Pipewire + ALSA/PulseAudio 兼容层）
    services.pipewire = {
      alsa = {
        enable = true;
        support32Bit = true;
      };
      enable = true;
      pulse.enable = true;
    };
    # 电源档位（性能/平衡/省电）
    services.power-profiles-daemon.enable = true;
    # 文件缩略图服务（Thunar）
    services.tumbler.enable = true;
    # 磁盘与移动介质挂载（Thunar 侧边栏挂载 U 盘等）
    services.udisks2.enable = true;
    # XDG Desktop Portal 后端分工：gnome 负责截图/录屏/外观（深浅色同步），
    # gtk 负责文件选择器等，Secret 走 gnome-keyring
    xdg.portal = {
      config.niri = {
        "org.freedesktop.impl.portal.Access" = [
          "gtk"
        ];
        "org.freedesktop.impl.portal.FileChooser" = [
          "gtk"
        ];
        "org.freedesktop.impl.portal.Notification" = [
          "gtk"
        ];
        "org.freedesktop.impl.portal.Secret" = [
          "gnome-keyring"
        ];
        default = [
          "gnome"
          "gtk"
        ];
      };
      enable = true;
      extraPortals = builtins.attrValues {
        inherit (pkgs) xdg-desktop-portal-gnome xdg-desktop-portal-gtk;
      };
    };
  }