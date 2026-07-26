{ ... }:
{
    # 系统配置按主题拆分到 modules/ 下，由 modules/default.nix 聚合导入
    imports = [
      ./hardware-configuration.nix
      ./disko.nix
      ./modules
    ];
    # stateVersion 记录首次安装的 NixOS 版本，决定有状态数据的兼容默认值；升级系统时不要改动
    system.stateVersion = "25.05";
  }