# 自定义 overlay：目录下每个 .nix 文件是一个 overlay（final: prev: { ... }），自动聚合成列表
{ lib }:
lib.pipe ./. [
  builtins.readDir
  builtins.attrNames
  (builtins.filter (name: lib.hasSuffix ".nix" name && name != "default.nix"))
  (map (name: import (./. + "/${name}")))
]
