{
  pkgs,
  lib,
  zen-browser,
  kimi-code,
  nixkits,
  ...
}:
{
    # Steam 容器看不到系统字体，复制真实文件否则中文方框
    home.activation.steamCjkFonts = lib.hm.dag.entryAfter [
      "writeBoundary"
    ] ''
    fontsDir="$HOME/.local/share/fonts"
    fontSrc="${pkgs.noto-fonts-cjk-sans}/share/fonts/opentype/noto-cjk/NotoSansCJK-VF.otf.ttc"
    mkdir -p "$fontsDir"
    if ! cmp -s "$fontSrc" "$fontsDir/NotoSansCJK-VF.otf.ttc"; then
      cp -f "$fontSrc" "$fontsDir/"
      chmod u+w "$fontsDir/NotoSansCJK-VF.otf.ttc"
    fi
  '';
    # 浏览器：brave、zen-twilight（pywalfox-native 让 zen 主题跟随调色板）
    # IM/会议：telegram、discord、qq、wechat、wemeet（见下方绿屏方案）
    # 笔记/阅读：obsidian、z-library、readest、onlyoffice-desktopeditors
    # 办公：wpsoffice-cn（WPS 365）
    # 开发：vscode、opencode、pi-coding-agent、kimi-code、kitsfmt（后三个来自 flake 输入）、uv、python3
    # 创作：obs-studio、krita、mazi51（51mazi 小说写作，pkgs/ 自打包 AppImage）
    # 网络工具：gopeed（下载）、localsend（局域网传文件）、go-musicfox（网易云）、remmina（远程桌面）
    # 游戏：gamescope、prismlauncher（MC）、protonplus、lutris、heroic（steam/KDE Connect 由系统模块提供）
    # Wine/容器：wine stableFull（单包覆盖 wow64+gecko+mono）、winetricks、waydroid-helper
    home.packages = builtins.attrValues {
      inherit (pkgs) brave pywalfox-native telegram-desktop discord qq wechat obsidian obs-studio krita z-library-desktop readest onlyoffice-desktopeditors wpsoffice-cn vscode opencode pi-coding-agent uv python3 gopeed localsend go-musicfox remmina gamescope prismlauncher protonplus lutris heroic winetricks waydroid-helper;
      inherit (pkgs.wineWow64Packages) stableFull;
      mazi51 = (import ../pkgs { inherit pkgs; }).mazi51;
      kimi-code-cli = kimi-code.packages.${pkgs.stdenv.hostPlatform.system}.default;
      kitsfmt = nixkits.packages.${pkgs.stdenv.hostPlatform.system}.kitsfmt;
      # wemeet 绿屏方案：Exec 改走 wemeet-xwayland 包装（x11/xcb），原生 Wayland 版勿用
      wemeet = pkgs.wemeet.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          substituteInPlace $out/share/applications/wemeetapp.desktop \
            --replace-fail "Exec=wemeet %u" "Exec=wemeet-xwayland %u"
        '';
      });
      zen-twilight = zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.twilight;
    };
  }
