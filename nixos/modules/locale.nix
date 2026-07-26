{ pkgs, ... }:
{
    # 字体
    fonts = {
      fontDir.enable = true;
      fontconfig = {
        defaultFonts = {
          emoji = [
            "Noto Color Emoji"
          ];
          # 等宽字体 (终端, 代码)
          monospace = [
            "JetBrainsMono Nerd Font"
            "Noto Sans Mono CJK SC"
          ];
          # 无衬线字体 (UI, 网页)
          sansSerif = [
            "Inter"
            "Noto Sans CJK SC"
            "Noto Sans CJK TC"
          ];
          # 衬线字体 (文档阅读)
          serif = [
            "Noto Serif"
            "Noto Serif CJK SC"
            "Noto Serif CJK TC"
          ];
        };
        enable = true;
      };
      packages = with pkgs;
      [
              # UI字体
              inter
              # UI图标
              nerd-fonts.symbols-only
              # 终端/代码字体
              nerd-fonts.jetbrains-mono
              # 核心中文黑体 (思源黑体)
              noto-fonts-cjk-sans
              # 核心中文宋体 (思源宋体)
              noto-fonts-cjk-serif
              # 彩色Emoji
              noto-fonts-color-emoji
            ];
    };
    # 语言与输入法
    i18n = {
      defaultLocale = "zh_CN.UTF-8";
      inputMethod = {
        enable = true;
        fcitx5 = {
          addons = with pkgs;
          [
                      # Rime输入法
                      (fcitx5-rime.override {
            rimeDataPkgs = [
              rime-data
              rime-ice
            ];
          })
                      # 皮肤
                      fcitx5-nord
                      catppuccin-fcitx5
                    ];
          waylandFrontend = true;
        };
        type = "fcitx5";
      };
    };
    # 时区
    time.timeZone = "Asia/Shanghai";
  }