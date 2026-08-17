# flake-parts 装配层入口
# hosts.nix = 主机/用户声明与 aspect 组合；schema.nix = den 元数据类型声明；
# defaults.nix = 全局默认；install-tools.nix = 安装器工具入口；
# formatting.nix/checks.nix = 格式化与静态检查；
# ../features/ = feature aspects（一个文件一个 feature，自动聚合；挂载清单见 hosts.nix）
{ lib, ... }:
let
  inherit (import ../../libs { inherit lib; }) nixFilesIn;
in
{
  imports = [
    ./hosts.nix
    ./schema.nix
    ./defaults.nix
    ./install-tools.nix
    ./formatting.nix
    ./checks.nix
  ]
  ++ nixFilesIn ../features;
}
