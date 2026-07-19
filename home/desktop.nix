{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    brightnessctl
    imv
    mpv
    mpvpaper
    wf-recorder
    grim
    slurp
    cliphist
    wl-clipboard
    wl-clip-persist
    pwvucontrol
    udiskie
    cava
    playerctl
    xsettingsd
    fuzzel # 启动器回退 + niri 脚本菜单
    libnotify # notify-send（niri 脚本通知）
    xprop # niri-force-kill-window 解析 XWayland PID
    sound-theme-freedesktop # 截图快门声
    satty # 截图标注（Mod+Shift+S）
    imagemagick # 在线壁纸转 PNG
    sunsetr # 蓝光过滤/夜间色温（Rust 版 sunset）
    file-roller # 压缩包管理（thunar-archive-plugin 后端）
    adwaita-icon-theme # 图标主题（Adwaita-Matugen 重着色模板的 Inherits 基础）
    adw-gtk3 # GTK3 版 libadwaita 主题（Noctalia gtk 模板按它设计，配合 noctalia.css 变色）
    gsettings-desktop-schemas # gsettings 的 org.gnome.desktop.* schema（Noctalia 同步深色/图标主题需要）
  ];

  # Xfce 默认终端（Thunar 内置“在此打开终端”等动作使用）
  home.file.".config/xfce4/helpers.rc".text = ''
    TerminalEmulator=foot
  '';

  # Thunar 右键“创建文档”的模板（~/Templates 下的文件会出现在该菜单）
  home.file."Templates/文本文档.txt".text = "";
  home.file."Templates/Markdown 文档.md".text = "";
  # Office 模板（取自 WPS 自带的空白模板，存于仓库 dotfiles/Templates/）
  home.file."Templates/Word 文档.docx".source = ../dotfiles/Templates + "/Word 文档.docx";
  home.file."Templates/Excel 工作簿.xlsx".source = ../dotfiles/Templates + "/Excel 工作簿.xlsx";
  home.file."Templates/PowerPoint 演示文稿.pptx".source = ../dotfiles/Templates + "/PowerPoint 演示文稿.pptx";

  # 光标主题由 HM 声明；GTK/Qt 应用颜色由 Noctalia 主题模板接管，
  # 不再使用 gtk 模块（避免与 Noctalia 写 ~/.config/gtk-*/ 冲突）
  home.pointerCursor = {
    enable = true;
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
  };

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=18";
        pad = "10x10 center";
        # 配色由 Noctalia 模板生成（~/.config/foot/themes/noctalia），此处只引入
        include = "~/.config/foot/themes/noctalia";
      };
      "colors-dark" = {
        alpha = 0.8;
      };
    };
  };
}
