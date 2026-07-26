{
  config,
  pkgs,
  lib,
  ...
}:
{
    # foot 配色兜底：main.include 指向的文件由 Noctalia 运行时生成，缺失时 foot 会报错退出；
    # 仅在缺失时从仓库种子一份最小配色（install -m 644：store 文件只读，拷贝需恢复可写）
    home.activation.footThemeFallback = lib.hm.dag.entryAfter [
      "writeBoundary"
    ] ''
    footThemeDir="$HOME/.config/foot/themes"
    if [ ! -f "$footThemeDir/noctalia" ]; then
      mkdir -p "$footThemeDir" || exit 1
      install -m 644 ${../dotfiles/foot/themes/noctalia} "$footThemeDir/noctalia" || exit 1
    fi
  '';
    # Xfce 默认终端（Thunar 内置“在此打开终端”等动作使用）
    home.file.".config/xfce4/helpers.rc".text = ''
    TerminalEmulator=foot
  '';
    # Thunar 右键「创建文档」菜单模板：Office 模板二进制存于 dotfiles/Templates/，文本类直接写空文件
    home.file."Templates/Excel 工作簿.xlsx".source = ../dotfiles/Templates + "/Excel 工作簿.xlsx";
    home.file."Templates/Markdown 文档.md".text = "";
    home.file."Templates/PowerPoint 演示文稿.pptx".source = ../dotfiles/Templates + "/PowerPoint 演示文稿.pptx";
    home.file."Templates/Word 文档.docx".source = ../dotfiles/Templates + "/Word 文档.docx";
    home.file."Templates/文本文档.txt".text = "";
    # 非显然包用途（逐条注释集中在列表上方，与 home/app.nix 同约定）：
    # niri 脚本依赖 xprop/file；satty 截图标注；sound-theme-freedesktop 快门声；sunsetr 夜间色温；
    # adw-gtk3/adwaita-icon-theme/gsettings-desktop-schemas 是 Noctalia gtk 模板的主题与 schema 依赖
    home.packages = builtins.attrValues {
      inherit (pkgs) brightnessctl imv mpv mpvpaper wf-recorder grim slurp cliphist wl-clipboard wl-clip-persist pwvucontrol udiskie cava playerctl xsettingsd fuzzel libnotify xprop sound-theme-freedesktop satty imagemagick file sunsetr file-roller adwaita-icon-theme adw-gtk3 gsettings-desktop-schemas;
    };
    # 光标主题；GTK/Qt 颜色由 Noctalia 模板接管，不用 gtk 模块避免争夺 ~/.config/gtk-*/
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
          # 配色由 Noctalia 模板生成（~/.config/foot/themes/noctalia），此处只引入
          include = "~/.config/foot/themes/noctalia";
          pad = "10x10 center";
        };
      };
    };
  }