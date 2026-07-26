{
  pkgs,
  lib,
  zen-browser,
  kimi-code,
  nixkits,
  ...
}:
{
    # Steam 客户端 UI 在 pressure-vessel 容器内看不到系统字体（符号链接无效），
    # 把 CJK 字体以真实文件复制到 xdg fonts 目录，否则 Steam 中文显示方框
    home.activation.steamCjkFonts = lib.hm.dag.entryAfter [
      "writeBoundary"
    ] ''
    fontsDir="$HOME/.local/share/fonts"
    fontSrc="${pkgs.noto-fonts-cjk-sans}/share/fonts/opentype/noto-cjk/NotoSansCJK-VF.otf.ttc"
    mkdir -p "$fontsDir"
    # 内容一致则跳过，避免每次激活都重写约 32MB 的字体文件
    if ! cmp -s "$fontSrc" "$fontsDir/NotoSansCJK-VF.otf.ttc"; then
      cp -f "$fontSrc" "$fontsDir/"
      chmod u+w "$fontsDir/NotoSansCJK-VF.otf.ttc"
    fi
  '';
    # 包分组说明（逐条注释集中在列表上方，与 home/desktop.nix 同约定）：
    # 浏览器 brave/zen-twilight/pywalfox-native（zen 主题跟随调色板）
    # 开发：pi-coding-agent/kimi-code/kitsfmt 均来自 flake 输入
    # 游戏：steam 与 KDE Connect 由系统模块提供（见 nixos/modules/desktop.nix）
    # Wine：stableFull 单包覆盖 wow64+gecko+mono；waydroid-helper 是安卓容器辅助
    home.packages = builtins.attrValues {
      inherit (pkgs) brave pywalfox-native telegram-desktop discord qq wechat wemeet obsidian obs-studio krita z-library-desktop readest vscode opencode pi-coding-agent uv python3 gopeed localsend go-musicfox remmina gamescope prismlauncher protonplus lutris heroic winetricks waydroid-helper;
      inherit (pkgs.wineWow64Packages) stableFull;
      kimi-code-cli = kimi-code.packages.${pkgs.stdenv.hostPlatform.system}.default;
      kitsfmt = nixkits.packages.${pkgs.stdenv.hostPlatform.system}.kitsfmt;
      zen-twilight = zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.twilight;
    };
  }