{ ... }:
{
    # Nix 设置：国内镜像 substituters + noctalia/nixkits cachix
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      sandbox = false;
      # 有意关闭构建沙箱（个人配置）
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
    # 允许闭源软件（NVIDIA 驱动、Steam 等）
    nixpkgs.config.allowUnfree = true;
    # FHS 兼容层：运行未按 Nix 打包的动态链接二进制
    programs.nix-ld.enable = true;
  }