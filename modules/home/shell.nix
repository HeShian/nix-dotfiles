{ config, pkgs, ... }:
{
    # 终端工具：yazi（文件管理）、neovim、lazygit、fastfetch（系统信息）、btop（资源监控）；
    # rtk：代理命令行输出的 token 压缩工具（配合 pi/opencode 等 agent 使用，rtk init 安装 hook）；
    # codegraph：代码知识图谱（codegraph init 建索引，MCP 服务经项目 .mcp.json 接入 pi）；
    # nodejs：npm/npx 运行时（pi 扩展安装器、codegraph 等 npm 工具依赖）
    home.packages = builtins.attrValues {
      inherit (pkgs) yazi neovim lazygit fastfetch btop rtk codegraph nodejs;
    };
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    # programs.git 身份（name/email）在 home/<user>/default.nix 按用户定义
    programs.nh = {
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
