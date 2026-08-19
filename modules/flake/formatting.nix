# treefmt 配置：`nix fmt` 一键格式化，`nix flake check` 含 formatting 检查
# nixfmt = RFC 166 官方标准；stylua/shfmt/deadnix/statix 由 treefmt-nix 预置
_: {
  perSystem = _: {
    treefmt = {
      projectRootFile = "flake.nix";
      programs = {
        nixfmt.enable = true;
        stylua.enable = true;
        shfmt.enable = true;
        deadnix.enable = true;
        statix.enable = true;
      };
      settings = {
        global.excludes = [
          # matugen 模板（含占位符语法，格式化会破坏）
          "dotfiles/noctalia/templates/*"
          # Noctalia 下载的第三方社区模板/调色板
          "dotfiles/noctalia/state/*"
          # Noctalia 运行时生成，stylua 会改写用户当前调色板文件
          "dotfiles/nvim/lua/matugen.lua"
        ];
        formatter = {
          stylua.options = [
            "--indent-type"
            "Spaces"
            "--indent-width"
            "2"
            "--quote-style"
            "AutoPreferSingle"
          ];
          shfmt = {
            options = [
              "-i"
              "2"
              "-s"
              "-sr"
            ];
            # 三套脚本目录都有无 .sh 扩展名的入口，按路径显式纳入。
            includes = [
              "*.sh"
              "dotfiles/mango/scripts/*"
              "dotfiles/niri/scripts/*"
              "dotfiles/noctalia/scripts/*"
            ];
          };
        };
      };
    };
  };
}
