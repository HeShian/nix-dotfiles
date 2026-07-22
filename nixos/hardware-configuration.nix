{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
    boot.extraModulePackages = [];
    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "nvme"
      "usbhid"
      "uas"
      "sd_mod"
    ];
    boot.initrd.kernelModules = [];
    boot.kernelModules = [
      "kvm-intel"
    ];
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  }