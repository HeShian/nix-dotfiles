# 第三方软件自打包，经 overlays/pkgs.nix 注入包集（pkgs.<name> 直接引用）
{ pkgs }:
{
    mazi51 = pkgs.callPackage ./51mazi.nix {};
  }
