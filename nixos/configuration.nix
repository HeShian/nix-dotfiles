{ ... }:
{
    # 系统配置按主题拆分到 modules/ 下，由 modules/default.nix 聚合导入
    imports = [
      ./hardware-configuration.nix
      ./disko.nix
      ./modules
    ];
    # 系统版本（首次安装）
    system.stateVersion = "25.05";
  }