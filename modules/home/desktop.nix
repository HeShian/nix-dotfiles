{
  config,
  pkgs,
  lib,
  ...
}:
{
    # foot 主题兜底（缺失时 foot 会报错退出）
    home.activation.footThemeFallback = lib.hm.dag.entryAfter [
      "writeBoundary"
    ] ''
    footThemeDir="$HOME/.config/foot/themes"
    if [ ! -f "$footThemeDir/noctalia" ]; then
      mkdir -p "$footThemeDir" || exit 1
      install -m 644 ${../../dotfiles/foot/themes/noctalia} "$footThemeDir/noctalia" || exit 1
    fi
  '';
    # Xfce 默认终端
    home.file.".config/xfce4/helpers.rc".text = ''
    TerminalEmulator=foot
  '';
    # Thunar「创建文档」菜单模板
    home.file."Templates/Excel 工作簿.xlsx".source = ../../dotfiles/Templates + "/Excel 工作簿.xlsx";
    home.file."Templates/Markdown 文档.md".text = "";
    home.file."Templates/PowerPoint 演示文稿.pptx".source = ../../dotfiles/Templates + "/PowerPoint 演示文稿.pptx";
    home.file."Templates/Word 文档.docx".source = ../../dotfiles/Templates + "/Word 文档.docx";
    home.file."Templates/文本文档.txt".text = "";
    # 截图/录屏：grim、slurp、wf-recorder、satty（标注）
    # 剪贴板：cliphist、wl-clipboard、wl-clip-persist
    # 媒体：imv（看图）、mpv、mpvpaper（视频壁纸）、cava（音频可视化）、pwvucontrol（音量）、playerctl
    # 系统工具：brightnessctl、udiskie（自动挂载）、fuzzel（启动器）、libnotify、file-roller（压缩包）、imagemagick
    # 其他：xsettingsd（X11 主题）、sunsetr（夜间色温）、sound-theme-freedesktop（快门声）、xprop/file（niri 脚本依赖）
    # 主题：adw-gtk3、adwaita-icon-theme、gsettings-desktop-schemas（供 Noctalia gtk 模板）
    home.packages = builtins.attrValues {
      inherit (pkgs) brightnessctl imv mpv mpvpaper wf-recorder grim slurp cliphist wl-clipboard wl-clip-persist pwvucontrol udiskie cava playerctl xsettingsd fuzzel libnotify xprop sound-theme-freedesktop satty imagemagick file sunsetr file-roller adwaita-icon-theme adw-gtk3 gsettings-desktop-schemas;
    };
    # GTK/Qt 颜色由 Noctalia 模板接管，不用 HM gtk 模块
    home.pointerCursor = {
      enable = true;
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
    };
    programs.foot = {
      enable = true;
      settings = {
        "colors-dark" = {
          alpha = 0.8;
        };
        main = {
          font = "JetBrainsMono Nerd Font:size=18";
          include = "~/.config/foot/themes/noctalia";
          pad = "10x10 center";
        };
      };
    };
  }
