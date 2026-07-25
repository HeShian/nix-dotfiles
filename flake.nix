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
      url = "github:MoonshotAI/kimi-code";
    };
    # follows nixpkgs：避免重复下载一份 nixpkgs 源码（且本机网络拉取 GitHub 大 tarball 不稳定）。
    # 代价：与 NixKits 上游锁定的 nixpkgs 不同，kitsfmt 无法命中其 cachix，需本地从源码编译（Rust）。
    nixkits = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:Kihara777/NixKits";
    };
    nixpkgs.url = "nixpkgs/nixos-unstable";
    # 跟随最新 stable tag（main 为不稳定分支，不用）
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    noctalia = {
      # 有意锁定 cachix 分支而非主线：该分支用于命中其 cachix 二进制缓存，
      # nix flake update 会跟随该分支更新
      url = "github:noctalia-dev/noctalia/cachix";
    };
    noctalia-greeter = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:noctalia-dev/noctalia-greeter";
    };
    zen-browser = {
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
      url = "github:0xc000022070/zen-browser-flake";
    };
  };
  outputs =   {
    self,
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
      host = import ./nixos/host.nix;
      system = "x86_64-linux";
      specialArgs = host // {
        inherit noctalia zen-browser kimi-code nixkits;
      };
      mkSystem =       modules: nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          inherit system;
          modules = [
            ./nixos/configuration.nix
            disko.nixosModules.disko
            noctalia-greeter.nixosModules.default
            agenix.nixosModules.default
            nix-flatpak.nixosModules.nix-flatpak
          ] ++ modules;
        };
      homeManagerModules = [
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            backupFileExtension = "backup";
            extraSpecialArgs = specialArgs;
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${host.userName} = import ./home;
          };
        }
      ];
in
    {
      nixosConfigurations."${host.hostName}-install" = mkSystem [];
      nixosConfigurations.${host.hostName} = mkSystem homeManagerModules;
    };
}