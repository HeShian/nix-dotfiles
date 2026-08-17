# 自定义 overlay：目录下每个 .nix 文件是一个 overlay（final: prev: { ... }），自动聚合成列表
{ lib }:
let
  inherit (import ../libs { inherit lib; }) nixFilesIn;
in
map import (nixFilesIn ./.)
