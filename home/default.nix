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
    # 仓库根目录（dotfiles 的上一级），从 dotfiles 派生，避免多处硬编码同一路径
    repo = builtins.dirOf dotfiles;
    # mkOutOfStoreSymlink：生成指回仓库本身的活链接（不复制进 nix store）
    link =     path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
    # 整目录链接清单：dotfiles/<name> → ~/.config/<name>
    configs = {
      Thunar = "Thunar";
      fastfetch = "fastfetch";
      nvim = "nvim";
      xsettingsd = "xsettingsd";
    };
    # niri 逐文件链接（~/.config/niri 需是真实目录，Noctalia 运行时生成的 noctalia.kdl 不入库）；
    # 清单由 readDir 自动枚举，新增文件需先 git add 才会被 flake 看到
    niriDir = ../dotfiles/niri;
    # 枚举目录下的常规文件（readDir 返回 name→type 表，过滤 regular）
    regularFilesIn =     dir: lib.mapAttrsToList (name: _: name) (lib.filterAttrs (_: type: type == "regular") (builtins.readDir dir));
    niriFiles = regularFilesIn niriDir ++ map (file: "scripts/${file}") (regularFilesIn (niriDir + "/scripts"));
in
  {
    # Noctalia 配置种子：仅在目标缺失时从仓库拷贝，之后由 Noctalia 运行时维护/覆写；
    # @REPO@/@HOME@ 占位符在种子时替换；--no-preserve=mode 因为 store 文件只读，拷贝需恢复可写
    home.activation.noctaliaSeed = lib.hm.dag.entryAfter [
      "writeBoundary"
    ] ''
    repo="${repo}"
    cfgDir="$HOME/.config/noctalia"
    stateDir="$HOME/.local/state/noctalia"
    if [ ! -f "$cfgDir/config.toml" ]; then
      mkdir -p "$cfgDir" || exit 1
      sed "s|@REPO@|$repo|g" ${../dotfiles/noctalia/config.toml} > "$cfgDir/config.toml" || exit 1
    fi
    if [ ! -f "$stateDir/settings.toml" ]; then
      mkdir -p "$stateDir" || exit 1
      sed "s|@HOME@|$HOME|g" ${../dotfiles/noctalia/settings.toml} > "$stateDir/settings.toml" || exit 1
      touch "$stateDir/.setup-complete" || exit 1
    fi
    # state/ 缓存（社区调色板/模板）缺失时同样补种子，保证主题离线可用
    if [ ! -d "$stateDir/community-palettes" ]; then
      mkdir -p "$stateDir" || exit 1
      cp -r --no-preserve=mode ${../dotfiles/noctalia/state}/. "$stateDir/" || exit 1
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
    # dotfiles/ 以活链接挂到 ~/.config/（改配置无需 rebuild）：configs 整目录链接，niri 逐文件链接
    xdg.configFile = builtins.mapAttrs (name: value:
    {
          source = link value;
        }) configs // builtins.listToAttrs (map (file:
    {
        name = "niri/${file}";
        value.source = link "niri/${file}";
      }) niriFiles);
    # XDG 用户目录固定英文并自动创建，防止应用各自创建中文目录
    xdg.userDirs = {
      createDirectories = true;
      enable = true;
    };
  }