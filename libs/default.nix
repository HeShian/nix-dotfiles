# 自定义函数库：目录下每个 .nix 文件按文件名聚合（libs/foo.nix → mylib.foo）
# 文件形式为 { lib }: <函数或属性集>
{ lib }:
lib.pipe ./. [
  builtins.readDir
  (lib.filterAttrs (
    name: type: type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix"
  ))
  (lib.mapAttrs (name: _: import (./. + "/${name}") { inherit lib; }))
]
