# 主机/用户声明与 den aspect 装配
#
# 约定（与原 mkHost 一致）：
# - hosts/ 下每个目录即一台主机，目录名即主机名（den host 名与 networking.hostName）
# - 机器参数读自各目录的 host.nix（cpu/gpu/disk/users/userName/userEmail）
# - 每台主机产出两个 nixosConfigurations：<name> 与 <name>-install
#   （installMode：新机无 host key，排除 secrets/flatpak，且不挂 Home Manager）
# - HM 只挂载 home/<user>/ 目录存在的用户
{
  inputs,
  lib,
  ...
}:
let
  hostsDir = ../../hosts;
  homeDir = ../../home;
  # 自定义函数库（见 libs/），经 _module.args 注入所有 NixOS/HM 模块
  mylib = import ../../libs { inherit lib; };

  hostDirs = lib.filterAttrs (_: type: type == "directory") (builtins.readDir hostsDir);
  hostParams = lib.mapAttrs (name: _: import (hostsDir + "/${name}/host.nix")) hostDirs;
  hostNames = builtins.attrNames hostDirs;

  # 注入 NixOS/HM 模块的参数集：host.nix 机器参数 + flake 输入与 mylib
  moduleArgs =
    name:
    hostParams.${name}
    // {
      inherit mylib;
      inherit (inputs) noctalia zen-browser kimi-code nixkits;
    };

  # home-manager 全局行为（HM OS 模块由 den 在用户声明时自动导入；
  # installMode 主机无用户、无 HM 模块，引用 home-manager.* 选项会报“选项不存在”，
  # 故只在非 installMode 主机的 imports 里出现）
  hmGlobal = {
    home-manager = {
      backupFileExtension = "backup";
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };

  # 单台主机的 aspect：nixos 类引用 hosts/<name> 与共享模块层，并注入参数。
  # 注意：imports 不能依赖 _module.args（它是 config 的一部分，会引发无限递归），
  # 因此 installMode 的 secrets/flatpak 排除在此以纯数据完成，不经模块参数。
  nixosModuleFiles =
    installMode:
    lib.pipe ../../modules/nixos [
      builtins.readDir
      (lib.filterAttrs (
        name: type:
        type == "regular"
        && lib.hasSuffix ".nix" name
        && name != "default.nix"
        && !(installMode && builtins.elem name [
          "secrets.nix"
          "flatpak.nix"
        ])
      ))
      (lib.mapAttrsToList (name: _: ../../modules/nixos + "/${name}"))
    ];

  mkHostAspect =
    name: installMode:
    { lib, ... }:
    {
      imports =
        [ (hostsDir + "/${name}") ]
        ++ nixosModuleFiles installMode
        ++ lib.optionals (!installMode) [ hmGlobal ];
      networking.hostName = name;
      _module.args = moduleArgs name;
    };

  # 有 home/<user>/ 目录的用户才生成 HM aspect（homeManager 类由 den 转发给 home-manager.users.<user>）
  hmUsers = lib.unique (lib.concatMap (name: hostParams.${name}.users) hostNames);
  hmUsersWithDir = builtins.filter (u: builtins.pathExists (homeDir + "/${u}")) hmUsers;
  # 用户机器参数取自其所在的第一个主机（单主机场景即该主机）
  userHost = user: lib.findFirst (name: builtins.elem user hostParams.${name}.users) null hostNames;
in
{
  den.hosts.x86_64-linux = lib.concatMapAttrs (name: _: {
    ${name}.users = lib.genAttrs hostParams.${name}.users (_: { });
    "${name}-install" = { };
  }) hostDirs;

  den.aspects =
    lib.concatMapAttrs (name: _: {
      ${name}.nixos = mkHostAspect name false;
      "${name}-install".nixos = mkHostAspect name true;
    }) hostDirs
    // lib.genAttrs hmUsersWithDir (user: {
      homeManager = {
        imports = [ (homeDir + "/${user}") ];
        _module.args = moduleArgs (userHost user);
      };
    });
}
