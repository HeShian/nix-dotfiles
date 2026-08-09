# 第三方软件自打包，由 home/app.nix 等处 import 引入
{ pkgs }:
{
  mazi51 = pkgs.callPackage ./51mazi.nix { };
}
