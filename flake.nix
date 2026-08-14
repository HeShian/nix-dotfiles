{
  description = "NixOS with Niri + Noctalia";
  inputs = {
    agenix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:ryantm/agenix";
    };
    disko = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/disko";
    };
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager";
    };
    kimi-code = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:MoonshotAI/kimi-code";
    };
    # 跟随最新 stable tag
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    # nixpkgs.follows 避免重复下载 nixpkgs 源码；代价：kitsfmt 无法命中上游 cachix，需本地编译
    nixkits = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:Kihara777/NixKits";
    };
    nixpkgs.url = "nixpkgs/nixos-unstable";
    noctalia-greeter = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:noctalia-dev/noctalia-greeter";
    };
    # 锁定 cachix 分支（命中二进制缓存）
    noctalia.url = "github:noctalia-dev/noctalia/cachix";
    zen-browser = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:0xc000022070/zen-browser-flake";
    };
  };
  outputs =   {
    nixpkgs,
    home-manager,
    disko,
    noctalia,
    noctalia-greeter,
    zen-browser,
    kimi-code,
    nixkits,
    agenix,
    nix-flatpak,
    ...
  }:
let
      inherit (nixpkgs) lib;
      system = "x86_64-linux";
      # 自定义函数库与 overlay（见 libs/、overlays/），mylib 经 specialArgs 注入所有模块
      mylib = import ./libs {
        inherit lib;
      };
      # 自动发现 hosts/*：目录名即 hostName，机器参数读自各目录的 host.nix
      hostDirs = lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./hosts);
      hosts = lib.mapAttrs (name: _: import (./hosts + "/${name}/host.nix") // {
      hostName = name;
    }) hostDirs;
      # installMode：新机无 host key，排除 secrets 以免中断安装
      mkHost =       name: cfg: installMode: lib.nixosSystem {
              inherit system;
              modules = [
                ./hosts/${name}
                disko.nixosModules.disko
                noctalia-greeter.nixosModules.default
                agenix.nixosModules.default
                nix-flatpak.nixosModules.nix-flatpak
                {
                  nixpkgs.overlays = import ./overlays {
                    inherit lib;
                  };
                }
              ] ++ lib.optionals (!installMode) [
                home-manager.nixosModules.home-manager
                {
                  home-manager = {
                    backupFileExtension = "backup";
                    extraSpecialArgs = cfg // {
                      inherit noctalia zen-browser kimi-code nixkits mylib;
                    };
                    useGlobalPkgs = true;
                    useUserPackages = true;
                    # 只挂载存在 home/<user>/ 目录的用户
                    users = lib.genAttrs (builtins.filter (u: builtins.pathExists (./home + "/${u}")) cfg.users) (u: import (./home + "/${u}"));
                  };
                }
              ];
              specialArgs = cfg // {
                inherit noctalia zen-browser kimi-code nixkits mylib installMode;
              };
            };
in
    {
      nixosConfigurations = lib.concatMapAttrs (name: cfg:
      {
            "${name}-install" = mkHost name cfg true;
            ${name} = mkHost name cfg false;
          }) hosts;
    };
}
