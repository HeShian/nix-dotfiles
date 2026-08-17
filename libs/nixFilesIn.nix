# 列出目录下的 .nix 文件路径（排除 default.nix、子目录与符号链接），供自动导入/聚合
{ lib }:
dir:
lib.pipe dir [
  builtins.readDir
  (lib.filterAttrs (
    name: type: type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix"
  ))
  (lib.mapAttrsToList (name: _: dir + "/${name}"))
]
