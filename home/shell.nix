{ config, pkgs, userName, userEmail, hostName, ... }:

{
  home.packages = with pkgs; [
    yazi
    neovim
    lazygit
    fastfetch
    btop
    go-musicfox
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  programs.git = {
    enable = true;
    settings.user = {
      name = userName;
      email = userEmail;
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # nh：nix 命令助手（os switch/home switch 的友好封装）
  programs.nh = {
    enable = true;
    flake = "${config.home.homeDirectory}/Documents/nix-dotfiles";
    # 自动清理：每日执行 nh clean
    # --keep 3：无论多旧都保留最近 3 个世代
    # --keep-since 7d：另外保留 7 天内的所有世代
    clean = {
      enable = true;
      dates = "daily";
      extraArgs = "--keep 3 --keep-since 7d";
    };
  };

  programs.zsh = {
    enable = true;
    defaultKeymap = "viins";
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      c = "clear";
      ll = "ls -l";
      la = "ls -la";
      lg = "lazygit";
      ff = "fastfetch";
      vim = "nvim";
      nrs = "sudo nixos-rebuild switch --flake ~/Documents/nix-dotfiles#${hostName}";
    };

    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };

    initContent = ''
      PS1="%F{blue}%~%f"$'\n'"%F{green}➜ %f"

      function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
          builtin cd -- "$cwd"
        fi
        rm -f -- "$tmp"
      }
    '';

    profileExtra = ''
    '';
  };
}
