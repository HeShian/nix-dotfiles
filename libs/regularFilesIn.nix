# 列出目录下的常规文件名（过滤子目录与符号链接）
{ lib }:
dir:
lib.mapAttrsToList (name: _: name) (
  lib.filterAttrs (_: type: type == "regular") (builtins.readDir dir)
)
