{
  config,
  pkgs,
  lib,
  userName,
  nixkits,
  ...
}:
let
    dotfiles = "${config.home.homeDirectory}/Documents/nix-dotfiles/dotfiles";
    link =     path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
    configs = {
      Thunar = "Thunar";
      fastfetch = "fastfetch";
      nvim = "nvim";
      xsettingsd = "xsettingsd";
    };
    # niri 逐文件链接（而非整目录链接）：~/.config/niri 是真实目录，
    # 让 Noctalia 主题模板生成的 noctalia.kdl 落在 git 仓库之外。
    # 文件清单由 readDir 自动枚举（顶层常规文件 + scripts/ 下的常规文件），
    # 新增 .kdl 或脚本无需再手工登记
    niriDir = ../dotfiles/niri;
    regularFilesIn =     dir: lib.mapAttrsToList (name: _: name) (lib.filterAttrs (_: type: type == "regular") (builtins.readDir dir));
    niriFiles = regularFilesIn niriDir ++ map (file: "scripts/${file}") (regularFilesIn (niriDir + "/scripts"));
in
  {
    # Noctalia 初始配置种子：仅当目标文件不存在时从仓库拷贝，之后由 Noctalia 运行时维护/覆写。
    # config.toml 的 @REPO@ 与 settings.toml 的 @HOME@ 在种子时替换为实际路径（适配 userName 变化）；
    # state/ 下的社区调色板/模板缓存一并种子，保证重装后主题离线可用
    # （--no-preserve=mode：nix store 文件只读，拷贝后必须恢复可写，否则 Noctalia 无法更新缓存）。
    home.activation.noctaliaSeed = lib.hm.dag.entryAfter [
      "writeBoundary"
    ] ''
    repo="$HOME/Documents/nix-dotfiles"
    cfgDir="$HOME/.config/noctalia"
    stateDir="$HOME/.local/state/noctalia"
    if [ ! -f "$cfgDir/config.toml" ]; then
      mkdir -p "$cfgDir"
      sed "s|@REPO@|$repo|g" ${../dotfiles/noctalia/config.toml} > "$cfgDir/config.toml"
    fi
    if [ ! -f "$stateDir/settings.toml" ]; then
      mkdir -p "$stateDir"
      sed "s|@HOME@|$HOME|g" ${../dotfiles/noctalia/settings.toml} > "$stateDir/settings.toml"
      cp -r --no-preserve=mode ${../dotfiles/noctalia/state}/. "$stateDir/"
      touch "$stateDir/.setup-complete"
    fi
  '';
    home.file = {
      ".local/share/fcitx5/rime/default.custom.yaml".source = link "rime/default.custom.yaml";
    } // lib.mapAttrs' (name: _:
{
      name = ".agents/skills/${name}";
      value.source = "${nixkits}/skills/${name}";
    }) (lib.filterAttrs (_: type: type == "directory") (builtins.readDir "${nixkits}/skills"));
    home.homeDirectory = "/home/${userName}";
    home.stateVersion = "25.05";
    home.username = userName;
    imports = [
      ./desktop.nix
      ./shell.nix
      ./app.nix
    ];
    # 配置文件
    xdg.configFile = builtins.mapAttrs (name: value:
    {
          source = link value;
        }) configs // builtins.listToAttrs (map (file:
    {
        name = "niri/${file}";
        value.source = link "niri/${file}";
      }) niriFiles);
    # XDG 用户目录固定为英文（默认即 Downloads/Documents/Pictures/Videos/Music/Desktop/Templates），
    # 并自动创建缺失目录，防止应用各自创建中文目录
    xdg.userDirs = {
      createDirectories = true;
      enable = true;
    };
  }