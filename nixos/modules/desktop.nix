{
  lib,
  pkgs,
  noctalia,
  ...
}:
{
  # 合成器
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
  services.greetd = {
    enable = true;
    settings = {
      default_session.user = "greeter";
    };
  };

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
    systemPackages = with pkgs; [
      vim
      git
      wget
      xwayland-satellite
      glib
      # gsettings/dconf CLI：Noctalia gtk 模板同步深色模式、portal 调试用
      dconf
      # Noctalia 桌面 Shell 本体
      noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };

  # XDG Desktop Portal：显式声明 Niri 下的后端
  # gnome 后端负责截图/录屏/外观（color-scheme 深浅色，供 Noctalia 与 GTK 同步）
  # gtk 后端负责文件选择器等；Secret 走 gnome-keyring
  xdg.portal = {
    enable = true;
    config.niri = {
      default = [
        "gnome"
        "gtk"
      ];
      "org.freedesktop.impl.portal.Access" = [ "gtk" ];
      "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
      "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
    };
    extraPortals = builtins.attrValues {
      inherit (pkgs) xdg-desktop-portal-gnome xdg-desktop-portal-gtk;
    };
  };

  # Thunar 文件管理器（NixOS 模块：xfconf/插件/gvfs 回收站与网络挂载/tumbler 缩略图）
  programs.thunar = {
    enable = true;
    plugins = builtins.attrValues {
      inherit (pkgs.xfce) thunar-archive-plugin thunar-volman;
    };
  };
  services.gvfs.enable = true;
  # 缩略图
  services.tumbler.enable = true;
  # 磁盘
  services.udisks2.enable = true;

  # 音视频
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  # gnome-keyring: Electron 应用（WeChat 等）需要
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = lib.mkForce false;

  # 电源
  services.power-profiles-daemon.enable = true;
}
