{
  description = "NixOS desktop with Niri, Noctalia and Mango";

  inputs = {
    agenix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:ryantm/agenix";
    };
    # 非官方 Linux 封装：复用上游 Nix/HM 模块，避免在不可变系统上运行发行版安装脚本
    codex-desktop-linux = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:distsystem/codex-desktop-linux";
    };
    # 主机/用户 aspect 装配框架（flake-parts 模块；den 无 flake 输入，依赖在求值期内置拉取）
    den.url = "github:denful/den";
    disko = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/disko";
    };
    flake-parts = {
      inputs.nixpkgs-lib.follows = "nixpkgs";
      url = "github:hercules-ci/flake-parts";
    };
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager";
    };
    kimi-code = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:MoonshotAI/kimi-code";
    };
    mangowm = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:mangowm/mango";
    };
    # 跟随最新 stable tag
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    # nixpkgs.follows 避免重复下载 nixpkgs 源码（nixkits 仅以源码形式引用 skills，无构建）
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
    # nix fmt 统一格式化（nixfmt/stylua/shfmt + deadnix/statix）
    treefmt-nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:numtide/treefmt-nix";
    };
    zen-browser = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:0xc000022070/zen-browser-flake";
    };
  };

  # 装配层在 modules/flake/（flake-parts 模块）：
  # hosts/ 自动发现 + den 主机/用户装配（hosts.nix）、元数据类型声明（schema.nix）、
  # 全局默认（defaults.nix）、格式化（formatting.nix）；feature aspects 在 modules/features/（自动聚合）
  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [
        inputs.den.flakeModule
        inputs.treefmt-nix.flakeModule
        ./modules/flake
      ];
    };
}
