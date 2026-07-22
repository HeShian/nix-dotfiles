{ ... }:
{
  # 聚合导入本目录全部主题模块
  imports = [
    ./secrets.nix
    ./boot.nix
    ./hardware.nix
    ./locale.nix
    ./networking.nix
    ./nix.nix
    ./desktop.nix
    ./flatpak.nix
    ./virtualisation.nix
    ./users.nix
  ];
}
