# 字体、中文 locale、fcitx5 输入法与时区
_: {
  den.aspects.locale.nixos =
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
        # 办公兼容：corefonts（Arial/Times New Roman 等）、vista-fonts（Calibri 等），供 WPS/Office 文档
        packages = with pkgs; [
          inter
          nerd-fonts.symbols-only
          nerd-fonts.jetbrains-mono
          noto-fonts-cjk-sans
          noto-fonts-cjk-serif
          noto-fonts-color-emoji
          corefonts
          vista-fonts
        ];
      };
      i18n = {
        defaultLocale = "zh_CN.UTF-8";
        inputMethod = {
          enable = true;
          fcitx5 = {
            # fcitx5-rime 的词库定制（rime-ice）在 overlays/fcitx5-rime.nix
            addons = [ pkgs.fcitx5-rime ];
            waylandFrontend = true;
          };
          type = "fcitx5";
        };
      };
      time.timeZone = "Asia/Shanghai";
    };

  den.aspects.locale.provides.to-users.homeManager =
    { lib, ... }:
    {
      # Fcitx 安装 addon 不会自动把 Rime 加入用户组；只在缺失时播种或追加，保留配置工具维护的其他输入法。
      home.activation.fcitx5RimeProfile = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${../../dotfiles/noctalia/scripts/ensure-fcitx5-rime} ${../../dotfiles/fcitx5/profile}
      '';
    };
}
