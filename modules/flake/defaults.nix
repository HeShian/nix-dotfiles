# den 全局默认：作用于所有主机与用户（含 -install 变体）
# - 用户默认类 homeManager（den 据此自动导入 HM OS 模块并转发用户 aspect）
# - 外部 OS 模块（disko/agenix/nix-flatpak/noctalia-greeter/mango）全主机挂载
# - 自定义 overlay（见 overlays/）注入 nixpkgs
# - flake 输入与自定义函数库（见 libs/）经 _module.args 注入对应类
#   （机器参数不走这里，由 den.schema 元数据承载，见 schema.nix）
{
  inputs,
  lib,
  ...
}:
let
  mylib = import ../../libs { inherit lib; };
in
{
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  den.default.nixos = {
    imports = [
      inputs.disko.nixosModules.disko
      inputs.noctalia-greeter.nixosModules.default
      inputs.mangowm.nixosModules.mango
      inputs.agenix.nixosModules.default
      inputs.nix-flatpak.nixosModules.nix-flatpak
    ];
    nixpkgs.overlays = import ../../overlays { inherit lib; };
    _module.args = {
      inherit mylib;
      inherit (inputs) noctalia;
    };
  };

  den.default.homeManager = {
    imports = [
      inputs.codex-desktop-linux.homeManagerModules.default
      inputs.mangowm.hmModules.mango
    ];
    _module.args = {
      inherit mylib;
      inherit (inputs)
        kimi-code
        nixkits
        zen-browser
        ;
    };
  };
}
