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
    # 引导加载器与内核
    boot = {
      # 静默启动（抑制内核与 initrd 日志输出）
      consoleLogLevel = 0;
      initrd.verbose = false;
      kernelPackages = pkgs.linuxPackages_latest;
      # 跟踪最新主线内核
      loader = {
        # efiInstallAsRemovable 与 canTouchEfiVariables 互斥（nixpkgs 断言）
        efi.canTouchEfiVariables = false;
        grub = {
          default = "saved";
          device = "nodev";
          # UEFI 安装：不写入物理设备 MBR
          efiInstallAsRemovable = true;
          # 安装到 ESP 回退路径 EFI/BOOT/BOOTX64.EFI
          efiSupport = true;
          enable = true;
          # 自定义菜单条目：Reboot / Poweroff
          extraEntries = ''
          menuentry "Reboot" {
            reboot
          }
          menuentry "Poweroff" {
            halt
          }
        '';
          # 放 NixOS 条目之后：saved 模式下 grubenv 缺失时 GRUB 回退到菜单第 0 条，
          # 若自定义条目置顶，第 0 条就是 Reboot，超时自动选中会无限重启
          extraEntriesBeforeNixOS = false;
          # GRUB 主题（激活时复制到 /boot/grub/themes/nixos）
          theme = crossgrub;
          # 探测其他操作系统（os-prober）
          useOSProber = true;
        };
        systemd-boot.enable = false;
      };
    };
  }