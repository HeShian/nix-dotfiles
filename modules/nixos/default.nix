{
  lib,
  installMode ? false,
  ...
}:
{
    # installMode 下排除：secrets.nix（新机无 host key）、flatpak.nix（避免大体积下载）
    imports = [
      ./boot.nix
      ./hardware.nix
      ./locale.nix
      ./networking.nix
      ./nix.nix
      ./desktop.nix
      ./virtualisation.nix
      ./users.nix
    ] ++ lib.optionals (!installMode) [
      ./secrets.nix
      ./flatpak.nix
    ];
  }
