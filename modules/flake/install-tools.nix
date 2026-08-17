# 安装工具导出：为 Live ISO 脚本提供由 flake.lock 锁定的稳定 Disko 入口
{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    {
      apps.disko = {
        meta.description = "Partition and mount the target disk with the locked Disko input";
        type = "app";
        program = "${inputs.disko.packages.${system}.disko}/bin/disko";
      };
    };
}
