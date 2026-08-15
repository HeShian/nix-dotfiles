# den 全局默认：作用于所有主机（含 -install 变体）
# - 用户默认类 homeManager（den 据此自动导入 HM OS 模块并转发用户 aspect）
# - 外部 OS 模块（disko/agenix/nix-flatpak/noctalia-greeter）与原 mkHost 一致全主机挂载
# - 自定义 overlay（见 overlays/）注入 nixpkgs
{
  inputs,
  lib,
  ...
}:
{
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  den.default.nixos = {
    imports = [
      inputs.disko.nixosModules.disko
      inputs.noctalia-greeter.nixosModules.default
      inputs.agenix.nixosModules.default
      inputs.nix-flatpak.nixosModules.nix-flatpak
    ];
    nixpkgs.overlays = import ../../overlays { inherit lib; };
  };
}
