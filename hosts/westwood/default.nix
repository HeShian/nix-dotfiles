{ ... }:
{
    # 共享模块层 modules/nixos/ 由 modules/flake/hosts.nix 按 installMode 聚合挂载
    imports = [
      ./hardware-configuration.nix
      ./disko.nix
    ];
    # 勿随系统升级改动
    system.stateVersion = "25.05";
  }
