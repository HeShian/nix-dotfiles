# Noctalia 自定义模板

主题色不在 home-manager 中管理，全部由 Noctalia 的主题系统（`[theme]` + 模板）在运行时生成。
本目录只存放 Noctalia 没有内置模板的应用的**自定义模板源文件**。

## templates/neovim.lua

Neovim 的 base16 配色模板。Noctalia 没有内置 nvim 模板，需要在 Noctalia 配置中手动登记一次
（设置界面 → Theme → Templates → 自定义模板，或直接编辑 `~/.config/noctalia/config.toml`）：

```toml
[theme.templates.user.neovim]
input_path  = "/home/<userName>/Documents/nix-dotfiles/dotfiles/noctalia/templates/neovim.lua"
output_path = "~/.local/share/nvim/noctalia/colors.lua"
post_hook   = "pkill -USR1 nvim || true"
```

- 输出路径在 nvim 配置目录之外（`~/.config/nvim` 是本仓库的活链接，生成物不写进 git）。
- nvim 侧由 `dotfiles/nvim/lua/noctalia.lua` 加载该文件，收到 SIGUSR1 后热重载；
  文件不存在时回退到内置的 Catppuccin Mocha 配色。

## 内置模板

niri / gtk3 / gtk4 / foot / qt 等配色使用 Noctalia 内置模板，在 Noctalia 设置界面启用即可
（`noctalia theme --list-templates` 可列出全部内置模板 id）：

- niri → 生成 `~/.config/niri/noctalia.kdl`（`config.kdl` 已 include；该路径是真实目录，不进 git）
- foot → 生成 `~/.config/foot/themes/noctalia`（`home/desktop.nix` 的 foot 配置已 include）
- gtk3/gtk4 → 生成 `~/.config/gtk-*/noctalia.css` 并维护 `gtk.css` 的 `@import`

## templates/gtk-folder/（图标重着色）

把 Adwaita 图标按当前调色板重着色（文件夹、网络、垃圾桶、mimetypes 等约 30 个 SVG），
生成 `~/.local/share/icons/Adwaita-Matugen-{A,B}` 双主题并通过 gsettings 翻转，强制应用刷新图标。

- 需要 `adwaita-icon-theme`（Inherits 基础）与 `gsettings-desktop-schemas`（gsettings schema），
  均已在 `home/desktop.nix` 安装；`configuration.nix` 的 `sessionVariables.XDG_DATA_DIRS`
  已追加 schema 路径（改动后需重新登录）。
- `xsettingsd.conf` 的 `Net/IconThemeName` 静态指向 `Adwaita-Matugen-B`，
  GTK3 应用在 A/B 翻转时可能滞后一代换色（与参考仓库一致的行为）。
- 已在 `~/.config/noctalia/config.toml` 登记（input 用仓库绝对路径）：

```toml
[theme.templates.user.gtk-folder]
input_path  = "/home/<userName>/Documents/nix-dotfiles/dotfiles/noctalia/templates/gtk-folder/recolor.sh"
output_path = "~/.cache/noctalia/recoloricons.sh"
post_hook   = "bash ~/.cache/noctalia/recoloricons.sh &"
```

