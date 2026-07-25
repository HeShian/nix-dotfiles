{
  pkgs,
  lib,
  zen-browser,
  kimi-code,
  nixkits,
  ...
}:
{
    # Steam 客户端 UI 运行在 pressure-vessel 容器内，容器只挂载了 FHS 环境自带的 DejaVu 字体，
    # 看不到系统字体目录（Nix store 未挂载进容器，符号链接无效），导致中文全部显示为方框。
    # 容器与宿主机共享 HOME，其 fontconfig 会扫描 <dir prefix="xdg">fonts</dir>，
    # 因此把 CJK 字体以真实文件形式复制到 ~/.local/share/fonts 供容器使用。
    home.activation.steamCjkFonts = lib.hm.dag.entryAfter [
      "writeBoundary"
    ] ''
    fontsDir="$HOME/.local/share/fonts"
    mkdir -p "$fontsDir"
    cp -f ${pkgs.noto-fonts-cjk-sans}/share/fonts/opentype/noto-cjk/NotoSansCJK-VF.otf.ttc "$fontsDir/"
    chmod u+w "$fontsDir/NotoSansCJK-VF.otf.ttc"
  '';
    home.packages = with pkgs;
    [
          # 浏览器
          brave
          zen-browser.packages.x86_64-linux.twilight
          pywalfox-native
          # Pywalfox 扩展的本地通信宿主（zen 浏览器主题跟随配色）
          # 聊天通讯
          telegram-desktop
          discord
          qq
          wechat
          wemeet
          # 创作工具
          obsidian
          obs-studio
          krita
          # 阅读
          z-library-desktop
          # 开发工具
          vscode
          opencode
          pi-coding-agent
          # pi 编码代理 CLI（badlogic/pi-mono）
          kimi-code.packages.x86_64-linux.default
          nixkits.packages.x86_64-linux.kitsfmt
          # Nix 格式化器（AST 排序 + best-practice 修正）
          uv
          python3
          # 下载工具
          gopeed
          # 文件传输
          localsend
          kdePackages.kdeconnect-kde
          # 音乐
          go-musicfox
          # 远程桌面
          remmina
          # 游戏平台
          steam
          gamescope
          prismlauncher
          # Minecraft 启动器
          protonplus
          # Proton/Wine runner 下载管理
          lutris
          heroic
          # Epic/GOG 启动器
          # Wine（wow64 64+32 位 + gecko + mono，一个包全覆盖）
          wineWow64Packages.stableFull
          winetricks
          # 安卓容器辅助
          waydroid-helper
        ];
  }