{
  pkgs,
  noctalia,
  ...
}:
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
    # 基础工具 vim/git/wget；glib/dconf 提供 gsettings CLI；
    # xwayland-satellite 补 niri 缺失的 XWayland；最后是 Noctalia 桌面 Shell 本体
    systemPackages = with pkgs; [
      vim
      git
      wget
      xwayland-satellite
      glib
      dconf
      noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
  # 系统模块自动放行端口
  programs.kdeconnect.enable = true;
  programs.niri.enable = true;
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
  # 分工：gnome=截图/录屏/外观，gtk=文件选择器，Secret=gnome-keyring
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
