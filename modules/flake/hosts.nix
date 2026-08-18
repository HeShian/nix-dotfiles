# 主机/用户声明与 den aspect 装配
#
# 约定：
# - hosts/ 下每个目录即一台主机，目录名即主机名（den host 名与 networking.hostName）
# - 机器参数读自各目录的 host.nix（cpu/gpu/disk/primaryUser/proxy/users），
#   类型声明见 schema.nix（拼写/缺漏在声明处即报错），
#   feature aspect 以 parametric 形式（{ host, ... } / { user, ... }）读取
# - 每台主机产出两个 nixosConfigurations：<name> 与 <name>-install
#   （install 变体：新机无 host key，includes 排除 secrets/flatpak/hm-global/mango，
#   用户 classes 覆盖为 [ "user" ] 从而不挂 Home Manager）
# - host.nix users 清单中的用户即 HM 用户（homeManager 类由 den 转发给 home-manager.users.<user>）
{
  lib,
  den,
  ...
}:
let
  hostsDir = ../../hosts;

  hostDirs = lib.filterAttrs (_: type: type == "directory") (builtins.readDir hostsDir);
  hostParams = lib.mapAttrs (name: _: import (hostsDir + "/${name}/host.nix")) hostDirs;
  hostNames = builtins.attrNames hostDirs;

  # feature 只在这里以名字分类；具体 aspect 仍由 ../features/ 自动聚合。
  hostFeatureNames = [
    "boot"
    "desktop"
    "flatpak"
    "hardware"
    "hm-global"
    "locale"
    "mango"
    "networking"
    "niri"
    "nix"
    "secrets"
    "users"
    "virtualisation"
  ];
  userFeatureNames = [
    "apps"
    "dotfiles"
    "shell"
  ];
  # install 变体排除 secrets（新机无 host key，解密必失败）、flatpak（装机阶段不预装应用）和
  # mango（其完整会话依赖 HM 用户服务）；hm-global 引用 home-manager.* 选项，无 HM 模块时不可用。
  installExcludedFeatureNames = [
    "flatpak"
    "hm-global"
    "mango"
    "secrets"
  ];
  installFeatureNames = lib.filter (
    name: !(builtins.elem name installExcludedFeatureNames)
  ) hostFeatureNames;

  selectFeatures =
    names:
    map (
      name:
      if builtins.hasAttr name den.aspects then
        den.aspects.${name}
      else
        throw "feature '${name}' is selected in modules/flake/hosts.nix but no den aspect defines it"
    ) names;

  hostFeatures = selectFeatures hostFeatureNames;
  installFeatures = selectFeatures installFeatureNames;
  userFeatures = selectFeatures userFeatureNames;

  # host.nix users 清单中的所有用户生成 user aspect
  hmUsers = lib.unique (lib.concatMap (name: builtins.attrNames hostParams.${name}.users) hostNames);

  # den.aspects 是共享命名空间：主机、install 变体、用户、feature 任意重名都会覆盖或混用。
  aspectNames =
    hostFeatureNames
    ++ userFeatureNames
    ++ hostNames
    ++ map (name: "${name}-install") hostNames
    ++ hmUsers;
  aspectNameCounts = lib.foldl' (
    counts: name: counts // { ${name} = (counts.${name} or 0) + 1; }
  ) { } aspectNames;
  aspectNameCollisions = builtins.attrNames (lib.filterAttrs (_: count: count > 1) aspectNameCounts);
  invalidPrimaryUsers = lib.filter (
    name: !(builtins.hasAttr hostParams.${name}.primaryUser hostParams.${name}.users)
  ) hostNames;

  # 主机实体：机器参数 + 用户清单；extraUser 给 install 变体追加 classes 覆盖
  mkHostEntity = name: extraUser: {
    inherit (hostParams.${name})
      cpu
      disk
      gpu
      primaryUser
      ;
    proxy = hostParams.${name}.proxy or null;
    waydroidDrmDevice = hostParams.${name}.waydroidDrmDevice or null;
    users = lib.mapAttrs (_: metadata: metadata // extraUser) hostParams.${name}.users;
  };

  # 主机 aspect：挂 hosts/<name>/ 机器文件并按变体挑选 feature aspects
  mkHostAspect =
    name: features:
    { host, ... }:
    {
      nixos = {
        imports = [ (hostsDir + "/${name}") ];
        networking.hostName = host.hostName;
      };
      includes = features;
    };
in
{
  den.hosts.x86_64-linux = lib.concatMapAttrs (name: _: {
    ${name} = mkHostEntity name { };
    # hostName 默认取实体名，install 变体显式指回常规主机名
    "${name}-install" = mkHostEntity name { classes = [ "user" ]; } // {
      hostName = name;
    };
  }) hostDirs;

  den.aspects =
    lib.concatMapAttrs (name: _: {
      ${name} = mkHostAspect name hostFeatures;
      "${name}-install" = mkHostAspect name installFeatures;
    }) hostDirs
    // lib.genAttrs hmUsers (
      _u:
      { user, ... }:
      {
        includes = userFeatures;
        homeManager = {
          # 用户身份（git 提交署名）取自 host.nix 的逐用户元数据。
          programs.git = {
            enable = true;
            settings.user = {
              name = user.userName;
              inherit (user) email;
            };
          };
        };
      }
    )
    // lib.optionalAttrs (invalidPrimaryUsers != [ ]) (
      throw "primaryUser is absent from users on host(s): ${lib.concatStringsSep ", " invalidPrimaryUsers}"
    )
    // lib.optionalAttrs (aspectNameCollisions != [ ]) (
      throw "den aspect name collision(s): ${lib.concatStringsSep ", " aspectNameCollisions}"
    );
}
