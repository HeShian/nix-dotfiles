{ ... }:
{
    imports = [
      ./hardware-configuration.nix
      ./disko.nix
      ./modules
    ];
    # 勿随系统升级改动
    system.stateVersion = "25.05";
  }
