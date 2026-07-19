{ config, lib, pkgs, noctalia, userName, hostName, cpu, gpu, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  # 引导加载器
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  # 网络
  networking = {
    hostName = hostName;
    networkmanager.enable = true;
    # proxy.default = "http://192.168.8.236:7890";
    # proxy.default = "http://127.0.0.1:7897";
  };
  services.v2raya.enable = true;

  # 时区
  time.timeZone = "Asia/Shanghai";

  # 语言与输入法
  i18n = {
    defaultLocale = "zh_CN.UTF-8";
    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        waylandFrontend = true;
        addons = with pkgs; [
          (fcitx5-rime.override { # Rime输入法
            rimeDataPkgs = [ rime-data rime-ice ]; # 拼音词库
          })
          fcitx5-nord # 皮肤
          catppuccin-fcitx5
        ];
      };
    };
  };

  # 字体
  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      inter # UI字体
      nerd-fonts.symbols-only # UI图标
      nerd-fonts.jetbrains-mono # 终端/代码字体
      noto-fonts-cjk-sans # 核心中文黑体 (思源黑体)
      noto-fonts-cjk-serif # 核心中文宋体 (思源宋体)
      noto-fonts-color-emoji # 彩色Emoji
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        sansSerif = [ "Inter" "Noto Sans CJK SC" "Noto Sans CJK TC" ]; # 无衬线字体 (UI, 网页)
        serif = [ "Noto Serif" "Noto Serif CJK SC" "Noto Serif CJK TC" ]; # 衬线字体 (文档阅读)
        monospace = [ "JetBrainsMono Nerd Font" "Noto Sans Mono CJK SC" ]; # 等宽字体 (终端, 代码)
        emoji = [ "Noto Color Emoji" ]; # Emoji
      };
    };
  };
  
  # 音视频
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };

  # gnome-keyring: Electron 应用（WeChat 等）需要
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = lib.mkForce false;

  # 蓝牙
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General.Experimental = true;
    };
  };

  # OpenTabletDriver（数位板驱动，含 udev 规则与守护进程）
  hardware.opentabletdriver.enable = true;

  # OpenSSH 服务端（host key 复用已有的 ed25519 主机密钥，与 agenix 一致）
  services.openssh.enable = true;

  # agenix 密钥：密文存于仓库 secrets/，激活时用主机 SSH host key 解密到 /run/agenix/
  # 未启用 openssh（host key 是手工生成的），需显式指定解密私钥路径
  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  age.secrets.codeberg_token_nix_dotfiles = {
    file = ../secrets/codeberg_token_nix_dotfiles.age;
    owner = userName; # 允许用户直接读取（用于 git 推送 codeberg）
  };
  age.secrets.deepseek_api_opencode = {
    file = ../secrets/deepseek_api_opencode.age;
    owner = userName;
  };
  age.secrets.deepseek_api_copilot = {
    file = ../secrets/deepseek_api_copilot.age;
    owner = userName;
  };
  age.secrets.github_token_codeberg = {
    file = ../secrets/github_token_codeberg.age;
    owner = userName;
  };

  # 磁盘
  services.udisks2.enable = true;

  # Flatpak：flathub 国内镜像（中科大主用 + 上交大备用）+ 声明式安装应用
  services.flatpak.enable = true;
  # 安装服务由定时器触发（开机 1 分钟后 + 每天），避免大体积下载阻塞 nixos-rebuild
  systemd.services.flatpak-setup = {
    description = "Flathub 国内镜像配置与声明式应用安装";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = [ pkgs.flatpak ];
    serviceConfig.Type = "oneshot";
    script = ''
      set -e
      # 中科大镜像（主）
      flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
      flatpak remote-modify flathub --url=https://mirrors.ustc.edu.cn/flathub
      # 上交大镜像（备）
      flatpak remote-add --if-not-exists flathub-sjtu https://dl.flathub.org/repo/flathub.flatpakrepo || true
      flatpak remote-modify flathub-sjtu --url=https://mirror.sjtu.edu.cn/flathub
      # 声明式安装（已安装则为快速 no-op）
      for app in com.github.tchx84.Flatseal cn.wps.wps_365 eu.betterbird.Betterbird; do
        flatpak install -y --noninteractive flathub "$app" || echo "install failed: $app"
      done
    '';
  };
  systemd.timers.flatpak-setup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "1d";
    };
  };

  # 电源
  services.power-profiles-daemon.enable = true;

  # 虚拟化：libvirt + KVM + virt-manager（USB 直通支持）
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  programs.virt-manager.enable = true;

  # Waydroid（Android 容器；nftables 后端 — 模块自动选用 waydroid-nftables）
  networking.nftables.enable = true;
  virtualisation.waydroid.enable = true;

  # CPU/GPU
  services.xserver.videoDrivers =
    if gpu == "nvidia" then [ "nvidia" ]
    else if gpu == "amd" then [ "amdgpu" ]
    else if gpu == "intel" then [ "modesetting" ]
    else [ ];

  hardware = {
    enableRedistributableFirmware = true;
    graphics = { # 图形加速库
      enable = true;
      enable32Bit = true;
      extraPackages = lib.optionals (gpu == "nvidia") [ pkgs.nvidia-vaapi-driver ];
    };
    cpu.amd.updateMicrocode = cpu == "amd";
    cpu.intel.updateMicrocode = cpu == "intel";
    nvidia = lib.mkIf (gpu == "nvidia") {
      modesetting.enable = true;
      open = true; # RTX 50/Blackwell 需要开源内核模块
      nvidiaSettings = true;
      nvidiaPersistenced = true; # 启用持久守护进程，减少显卡初始化时间
      package = config.boot.kernelPackages.nvidiaPackages.latest;
      powerManagement.enable = true;
    };
  };

  # 合成器
  programs.niri.enable = true;

  # Thunar 文件管理器（NixOS 模块：xfconf/插件/gvfs 回收站与网络挂载/tumbler 缩略图）
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin # 右键压缩/解压（需 file-roller）
      thunar-volman # 可移动设备管理
    ];
  };
  services.gvfs.enable = true; # 回收站、网络挂载
  services.tumbler.enable = true; # 缩略图

  # XDG Desktop Portal：显式声明 Niri 下的后端
  # gnome 后端负责截图/录屏/外观（color-scheme 深浅色，供 Noctalia 与 GTK 同步）
  # gtk 后端负责文件选择器等；Secret 走 gnome-keyring
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    config.niri = {
      default = [ "gnome" "gtk" ];
      "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      "org.freedesktop.impl.portal.Access" = [ "gtk" ];
      "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
      "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
    };
  };

  # 显示管理器 - greetd + noctalia-greeter（替代自动登录）
  # services.getty.autologinUser = userName;

  services.greetd = {
    enable = true;
    settings = {
      default_session.user = "greeter";
    };
  };

  programs.noctalia-greeter = {
    enable = true;
    greeter-args = "--session niri";
    settings = {
      session.default = "niri";
      cursor = {
        theme = "Bibata-Modern-Classic";
        size = 24;
      };
      keyboard.layout = "us";
      keyboard.numlock = true;
      idle.timeout = 300;
    };
  };

  # 用户
  programs.zsh.enable = true;
  users.users.${userName} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "render" "libvirtd" ];
    shell = pkgs.zsh;
  };

  # 系统软件包与环境变量
  nixpkgs.config.allowUnfree = true; # 允许闭源软件
  programs.nix-ld.enable = true; # FHS兼容
  environment = {
    systemPackages = with pkgs; [
      vim
      git
      wget
      xwayland-satellite
      glib # gsettings：Noctalia gtk 模板同步深色模式、portal 调试用
      dconf # dconf CLI：gsettings 缺省时的回退写入
    ] ++ [ noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default ];
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      XDG_SESSION_TYPE = "wayland";
      # gsettings schema 路径（Noctalia GTK 模板/图标重着色脚本依赖 gsettings）
      XDG_DATA_DIRS = [ "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}" ];
    } // lib.optionalAttrs (gpu == "nvidia") {
      NVD_BACKEND = "direct";
      LIBVA_DRIVER_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    };
  };

  # nix设置
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    sandbox = false;
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ] ++ [ "https://noctalia.cachix.org" ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ] ++ [ "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=" ];
  };
  security.sudo.wheelNeedsPassword = false;

  # 系统版本（首次安装）
  system.stateVersion = "25.05";
}
