{ pkgs, ... }:
{
    fonts = {
      # 兼容按传统路径查找字体的应用
      fontDir.enable = true;
      fontconfig = {
        defaultFonts = {
          emoji = [
            "Noto Color Emoji"
          ];
          monospace = [
            "JetBrainsMono Nerd Font"
            "Noto Sans Mono CJK SC"
          ];
          sansSerif = [
            "Inter"
            "Noto Sans CJK SC"
            "Noto Sans CJK TC"
          ];
          serif = [
            "Noto Serif"
            "Noto Serif CJK SC"
            "Noto Serif CJK TC"
          ];
        };
        enable = true;
      };
      # UI：inter、nerd-fonts.symbols-only（图标）
      # 终端/代码：nerd-fonts.jetbrains-mono
      # 中文：noto-fonts-cjk-sans（思源黑体）、noto-fonts-cjk-serif（思源宋体）
      # Emoji：noto-fonts-color-emoji
      packages = with pkgs;
      [
              inter
              nerd-fonts.symbols-only
              nerd-fonts.jetbrains-mono
              noto-fonts-cjk-sans
              noto-fonts-cjk-serif
              noto-fonts-color-emoji
            ];
    };
    i18n = {
      defaultLocale = "zh_CN.UTF-8";
      inputMethod = {
        enable = true;
        fcitx5 = {
          addons = with pkgs;
          [
                      # 附加 rime-ice 雾凇拼音词库
                      (fcitx5-rime.override {
            rimeDataPkgs = [
              rime-data
              rime-ice
            ];
          })
                    ];
          waylandFrontend = true;
        };
        type = "fcitx5";
      };
    };
    time.timeZone = "Asia/Shanghai";
  }
