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
    # 代价：kitsfmt 无法命中上游 cachix，需本地编译
    nixkits = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:Kihara777/NixKits";
    };
    nixpkgs.url = "nixpkgs/nixos-unstable";
    noctalia = {
      # 锁定 cachix 分支（命中二进制缓存）
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
      host = import ./host.nix;
      system = "x86_64-linux";
      specialArgs = host // {
        inherit noctalia zen-browser kimi-code nixkits;
      };
      # installMode：新机无 host key，排除 secrets 以免中断安装
      mkSystem =       installMode: modules: nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              ./hosts/${host.hostName}
              disko.nixosModules.disko
              noctalia-greeter.nixosModules.default
              agenix.nixosModules.default
              nix-flatpak.nixosModules.nix-flatpak
            ] ++ modules;
            specialArgs = specialArgs // {
              inherit installMode;
            };
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
      nixosConfigurations."${host.hostName}-install" = mkSystem true [];
      nixosConfigurations.${host.hostName} = mkSystem false homeManagerModules;
    };
}
