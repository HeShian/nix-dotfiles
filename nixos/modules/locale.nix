{ pkgs, ... }:
{
    # 字体：fontconfig 默认字族 + 字体包
    fonts = {
      # 把字体链接到 /run/current-system/sw/share/X11/fonts（兼容按传统路径查找字体的应用）
      fontDir.enable = true;
      fontconfig = {
        defaultFonts = {
          emoji = [
            "Noto Color Emoji"
          ];
          # 等宽字体（终端、代码）
          monospace = [
            "JetBrainsMono Nerd Font"
            "Noto Sans Mono CJK SC"
          ];
          # 无衬线字体（UI、网页）
          sansSerif = [
            "Inter"
            "Noto Sans CJK SC"
            "Noto Sans CJK TC"
          ];
          # 衬线字体（文档阅读）
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
              # UI 字体
              inter
              # UI 图标
              nerd-fonts.symbols-only
              # 终端/代码字体
              nerd-fonts.jetbrains-mono
              # 核心中文黑体（思源黑体）
              noto-fonts-cjk-sans
              # 核心中文宋体（思源宋体）
              noto-fonts-cjk-serif
              # 彩色 Emoji
              noto-fonts-color-emoji
            ];
    };
    # 语言与输入法：fcitx5 + Rime
    i18n = {
      defaultLocale = "zh_CN.UTF-8";
      inputMethod = {
        enable = true;
        fcitx5 = {
          addons = with pkgs;
          [
                      # Rime 输入法，附加 rime-ice 雾凇拼音词库
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