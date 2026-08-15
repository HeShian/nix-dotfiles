# flake-parts 装配层入口：聚合本目录的 flake 模块
# hosts.nix = 主机/用户声明与 aspect 装配；defaults.nix = 全局默认；formatting.nix = nix fmt 配置
{
  imports = [
    ./hosts.nix
    ./defaults.nix
    ./formatting.nix
  ];
}
