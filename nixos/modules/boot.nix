{ pkgs, ... }:
let
    # Crossgrub 主题（CrossCode 标题画面风格，https://github.com/krypciak/crossgrub）
    # 发布包解压后 theme.txt 直接在根目录；已预取进 nix store（GitHub 直连不可达，fetch 走本地代理）
    crossgrub = pkgs.fetchzip {
      hash = "sha256-91HejF6/Vt8iX1fm7xi+FY/AKlPL5TJpIFCfGzGDTWw=";
      url = "https://github.com/krypciak/crossgrub/releases/download/1.0.0/crossgrub.tar.gz";
    };
in
  {
    # 引导加载器
    boot = {
      # 静默启动
      consoleLogLevel = 0;
      initrd.verbose = false;
      kernelPackages = pkgs.linuxPackages_latest;
      loader = {
        # efiInstallAsRemovable 与 canTouchEfiVariables 互斥（nixpkgs 断言）
        efi.canTouchEfiVariables = false;
        grub = {
          default = "saved";
          # UEFI 模式，不安装到物理设备
          device = "nodev";
          # 安装到 ESP 回退路径 EFI/BOOT/BOOTX64.EFI
          efiInstallAsRemovable = true;
          efiSupport = true;
          enable = true;
          extraEntries = ''
          menuentry "Reboot" {
            reboot
          }
          menuentry "Poweroff" {
            halt
          }
        '';
          # 自定义条目放在 NixOS 条目之前（需 default = "saved" 才生效）
          extraEntriesBeforeNixOS = true;
          # GRUB 主题（激活时复制到 /boot/grub/themes/nixos）
          theme = crossgrub;
          # 探测其他操作系统（自动加入 os-prober）
          useOSProber = true;
        };
        systemd-boot.enable = false;
      };
    };
  }