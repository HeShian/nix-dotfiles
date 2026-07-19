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
    noctalia = {
      url = "github:noctalia-dev/noctalia/cachix";
    };
    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    kimi-code = {
      url = "github:MoonshotAI/kimi-code";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, disko, noctalia, noctalia-greeter, zen-browser, kimi-code, agenix, ... }:
  let
    host = import ./nixos/host.nix;
    system = "x86_64-linux";
    specialArgs = host // { inherit noctalia zen-browser kimi-code; };
    mkSystem = modules: nixpkgs.lib.nixosSystem {
      inherit system;
      inherit specialArgs;
      modules = [
        ./nixos/configuration.nix
        disko.nixosModules.disko
        noctalia-greeter.nixosModules.default
        agenix.nixosModules.default
      ] ++ modules;
    };
    homeManagerModules = [
      home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.${host.userName} = import ./home;
          backupFileExtension = "backup";
          extraSpecialArgs = specialArgs;
        };
      }
    ];
  in
  {
    nixosConfigurations.${host.hostName} = mkSystem homeManagerModules;
    nixosConfigurations."${host.hostName}-install" = mkSystem [ ];
  };
}
