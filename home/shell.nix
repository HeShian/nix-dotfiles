{
  config,
  pkgs,
  userName,
  userEmail,
  hostName,
  ...
}:
{
    # 终端工具：yazi 文件管理/lazygit/fastfetch 系统信息/btop 资源监控（neovim 配置见 dotfiles/nvim/）
    home.packages = builtins.attrValues {
      inherit (pkgs) yazi neovim lazygit fastfetch btop;
    };
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
      settings = {
        # codeberg 凭据：git 认证时执行该命令，从 agenix（tmpfs）读 token，避免明文落盘
        credential."https://codeberg.org".helper = "!f() { echo username=claudia010; echo password=$(cat /run/agenix/codeberg_token_nix_dotfiles); }; f";
        user = {
          email = userEmail;
          name = userName;
        };
      };
    };
    # nh：nix 命令助手（flake 已指向本仓库，nh os switch 免 --flake）
    programs.nh = {
      # 每日自动清理：保留最近 3 个世代及 7 天内的世代
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
      shellAliases = {
        c = "clear";
        ff = "fastfetch";
        la = "ls -la";
        lg = "lazygit";
        ll = "ls -l";
        nrs = "nh os switch";
        vim = "nvim";
      };
      syntaxHighlighting.enable = true;
    };
  }