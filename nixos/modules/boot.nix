{ pkgs, ... }:
{
  # 引导加载器
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    # 静默启动
    consoleLogLevel = 0;
    initrd.verbose = false;
    loader = {
      # efiInstallAsRemovable 与 canTouchEfiVariables 互斥（nixpkgs 断言）
      efi.canTouchEfiVariables = false;
      systemd-boot.enable = false;
      grub = {
        enable = true;
        # UEFI 模式，不安装到物理设备
        device = "nodev";
        # 探测其他操作系统（自动加入 os-prober）
        useOSProber = true;
        efiSupport = true;
        # 安装到 ESP 回退路径 EFI/BOOT/BOOTX64.EFI
        efiInstallAsRemovable = true;
        # 自定义条目放在 NixOS 条目之前（需 default = "saved" 才生效）
        extraEntriesBeforeNixOS = true;
        extraEntries = ''
          menuentry "Reboot" {
            reboot
          }
          menuentry "Poweroff" {
            halt
          }
        '';
        default = "saved";
      };
    };
  };
}
