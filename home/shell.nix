{
  config,
  pkgs,
  userName,
  userEmail,
  hostName,
  ...
}:
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
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    programs.git = {
      enable = true;
      settings.user = {
        email = userEmail;
        name = userName;
      };
    };
    # nh：nix 命令助手（os switch/home switch 的友好封装）
    programs.nh = {
      # 自动清理：每日执行 nh clean
      # --keep 3：无论多旧都保留最近 3 个世代
      # --keep-since 7d：另外保留 7 天内的所有世代
      clean = {
        dates = "daily";
        enable = true;
        extraArgs = "--keep 3 --keep-since 7d";
      };
      enable = true;
      flake = "${config.home.homeDirectory}/Documents/nix-dotfiles";
    };
    programs.zsh = {
      autosuggestion.enable = true;
      defaultKeymap = "viins";
      enable = true;
      enableCompletion = true;
      history = {
        path = "${config.xdg.dataHome}/zsh/history";
        size = 10000;
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
      shellAliases = {
        c = "clear";
        ff = "fastfetch";
        la = "ls -la";
        lg = "lazygit";
        ll = "ls -l";
        nrs = "sudo nixos-rebuild switch --flake ~/Documents/nix-dotfiles#${hostName}";
        vim = "nvim";
      };
      syntaxHighlighting.enable = true;
    };
  }