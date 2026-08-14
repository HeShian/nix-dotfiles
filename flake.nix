{
  description = "NixOS with Niri + Noctalia";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # 锁定 cachix 分支（命中二进制缓存）
    noctalia.url = "github:noctalia-dev/noctalia/cachix";
    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kimi-code = {
      url = "github:MoonshotAI/kimi-code";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nixpkgs.follows 避免重复下载 nixpkgs 源码；代价：kitsfmt 无法命中上游 cachix，需本地编译
    nixkits = {
      url = "github:Kihara777/NixKits";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # 跟随最新 stable tag
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
  };

  outputs =
    {
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
      host = import ./host.nix;
      system = "x86_64-linux";
      specialArgs = host // {
        inherit noctalia zen-browser kimi-code nixkits;
      };
      # installMode：新机无 host key，排除 secrets 以免中断安装
      mkSystem =
        installMode: modules:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = specialArgs // {
            inherit installMode;
          };
          modules = [
            ./hosts/${host.hostName}
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
            users.${host.userName} = import ./modules/home;
          };
        }
      ];
    in
    {
      nixosConfigurations."${host.hostName}-install" = mkSystem true [ ];
      nixosConfigurations.${host.hostName} = mkSystem false homeManagerModules;
    };
}
