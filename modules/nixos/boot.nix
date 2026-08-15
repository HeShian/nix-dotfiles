{ pkgs, ... }:
let
  # Crossgrub GRUB 主题
  crossgrub = pkgs.fetchzip {
    hash = "sha256-91HejF6/Vt8iX1fm7xi+FY/AKlPL5TJpIFCfGzGDTWw=";
    url = "https://github.com/krypciak/crossgrub/releases/download/1.0.0/crossgrub.tar.gz";
  };
in
{
  boot = {
    # 静默启动
    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      # 与 efiInstallAsRemovable 互斥（nixpkgs 断言）
      efi.canTouchEfiVariables = false;
      grub = {
        default = "saved";
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
        # 置顶会在 saved 模式下无限重启，必须放最后
        extraEntriesBeforeNixOS = false;
        theme = crossgrub;
        useOSProber = true;
      };
      systemd-boot.enable = false;
    };
  };
}
