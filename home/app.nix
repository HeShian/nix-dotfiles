{ pkgs, zen-browser, kimi-code, ... }:

{
  home.packages = with pkgs; [
    # 浏览器
    brave
    zen-browser.packages.x86_64-linux.twilight
    pywalfox-native # Pywalfox 扩展的本地通信宿主（zen 浏览器主题跟随配色）

    # 聊天通讯
    telegram-desktop
    discord
    qq
    wechat

    # 创作工具
    obsidian
    obs-studio
    krita

    # 开发工具
    vscode
    opencode
    kimi-code.packages.x86_64-linux.default
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
    bottles # Wine 容器管理
    protonplus # Proton/Wine runner 下载管理
    lutris
    heroic # Epic/GOG 启动器

    # Wine（wow64 64+32 位 + gecko + mono，一个包全覆盖）
    wineWow64Packages.stableFull
    winetricks

    # 安卓容器辅助
    waydroid-helper
  ];
}
