{
  lib,
  installMode ? false,
  ...
}:
{
    # 聚合导入本目录全部主题模块
    # installMode（<host>-install 安装配置）下排除 secrets.nix：新机无 host key 无法解密
    imports = [
      ./boot.nix
      ./hardware.nix
      ./locale.nix
      ./networking.nix
      ./nix.nix
      ./desktop.nix
      ./flatpak.nix
      ./virtualisation.nix
      ./users.nix
    ] ++ lib.optionals (!installMode) [
      ./secrets.nix
    ];
  }