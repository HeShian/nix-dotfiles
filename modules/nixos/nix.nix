_: {
  # 国内镜像 + noctalia/nixkits cachix
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    # 有意关闭（个人配置）
    sandbox = false;
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
      "https://noctalia.cachix.org"
      "https://nixkits.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "nixkits.cachix.org-1:ycmoZnAnvjGsSzIMdGNmFdc65LeRW/GZ7GdN7KkRL8c="
    ];
  };
  nixpkgs.config.allowUnfree = true;
  # FHS 兼容层
  programs.nix-ld.enable = true;
}
