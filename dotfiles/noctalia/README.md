# Noctalia 自定义模板

主题色不在 home-manager 中管理，全部由 Noctalia 的主题系统（`[theme]` + 模板）在运行时生成。
本目录只存放 Noctalia 没有内置模板的应用的**自定义模板源文件**。

## 初始配置种子（重装自动恢复）

- `config.toml`：`~/.config/noctalia/config.toml` 的副本（自定义模板登记），仓库路径写成 `@REPO@` 占位符。
- `settings.toml`：`~/.local/state/noctalia/settings.toml` 的副本（v5 全部设置：bar 布局、桌面/锁屏小组件、主题选择、壁纸、overview backdrop），家目录写成 `@HOME@` 占位符。
- `state/`：社区调色板（community-palettes）与社区模板（community-templates）的缓存副本，保证重装后主题离线可用。

`modules/features/dotfiles.nix` 的 `home.activation.noctaliaSeed` 在每次 rebuild 时检查：**目标文件不存在才拷贝**（之后由 Noctalia 运行时维护/覆写），拷贝时把占位符替换为实际路径。

**当前配置调整满意后想更新种子**，手动同步回来（占位符替换不可少）：

```bash
cd ~/Documents/nix-dotfiles/dotfiles/noctalia
sed 's|/home/$USER/Documents/nix-dotfiles|@REPO@|g' ~/.config/noctalia/config.toml > config.toml
sed 's|/home/$USER|@HOME@|g' ~/.local/state/noctalia/settings.toml > settings.toml
rm -rf state && mkdir state
cp -r ~/.local/state/noctalia/community-palettes ~/.local/state/noctalia/community-templates state/
```

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

## templates/fcitx5-theme.conf

fcitx5 候选词框主题模板，生成 `~/.local/share/fcitx5/themes/noctalia/theme.conf`，
深浅色与壁纸取色均跟随当前 Noctalia 调色板。已在 `~/.config/noctalia/config.toml` 登记：

```toml
[theme.templates.user.fcitx5]
input_path  = "/home/<userName>/Documents/nix-dotfiles/dotfiles/noctalia/templates/fcitx5-theme.conf"
output_path = "~/.local/share/fcitx5/themes/noctalia/theme.conf"
post_hook   = "(fcitx5 -r >/dev/null 2>&1 &)"
```

- 需要把 fcitx5 切到该主题（`~/.config/fcitx5/conf/classicui.conf`，该文件由 fcitx5 运行时维护、不入库）：
  `Theme=noctalia`、`UseDarkTheme=False`（始终用模板主题，深浅色由模板本身反映）、
  `UseAccentColor=False`（否则系统重点色会覆盖主题高亮色）。
- **热重载必须用 `fcitx5 -r`（替换实例）而非 `fcitx5-remote -r`**：后者只重读配置、
  不会重读主题文件本身（参考 shorin-arch-setup 的做法）。`fcitx5 -r` 无缝替换进程，
  输入仅瞬断，新实例自动接管 DBus 与 Wayland 连接。
- `modules/features/locale.nix` 安装的 `fcitx5-nord` / `catppuccin-fcitx5` 皮肤包仍保留作备选，
  在 fcitx5 配置工具里随时可切回。

## 内置模板

niri / gtk3 / gtk4 / foot / qt 等配色使用 Noctalia 内置模板，在 Noctalia 设置界面启用即可
（`noctalia theme --list-templates` 可列出全部内置模板 id）：

- niri → 生成 `~/.config/niri/noctalia.kdl`（`config.kdl` 已 include；该路径是真实目录，不进 git）
- foot → 生成 `~/.config/foot/themes/noctalia`（`modules/features/desktop.nix` 的 foot 配置已 include）
- gtk3/gtk4 → 生成 `~/.config/gtk-*/noctalia.css` 并维护 `gtk.css` 的 `@import`

## 社区模板（含 VSCode）

settings.toml 的 `[theme.templates].community_ids` 已启用一批社区模板（pywalfox、zen-browser、
neovim、obsidian、vscode、discord、obs、opencode、prismlauncher、steam、telegram、yazi、zathura），
模板文件缓存在 `state/community-templates/`，随种子恢复，无需在 config.toml 登记。

其中 **vscode** 模板生成 `~/.vscode/extensions/noctalia.noctaliatheme-0.0.5/themes/NoctaliaTheme-color-theme.json`，
需要两个手动前提：

1. 在 VSCode 扩展市场安装 `noctalia.noctaliatheme` 扩展（版本号变化时需同步模板输出路径，
   以社区模板 `template.toml` 为准）；
2. 把 `~/.config/Code/User/settings.json` 的 `workbench.colorTheme` 设为 `NoctaliaTheme`。

扩展声明了 `_watch`，Noctalia 换壁纸/换色重写主题 JSON 时 VSCode 热重载，无需重启。
注意该模板只有 dark 变体，浅色模式下 VSCode 不会跟着变浅。

## templates/gtk-folder/（图标重着色）

把 Adwaita 图标按当前调色板重着色（文件夹、网络、垃圾桶、mimetypes 等约 30 个 SVG），
生成 `~/.local/share/icons/Adwaita-Matugen-{A,B}` 双主题并通过 gsettings 翻转，强制应用刷新图标。

- 需要 `adwaita-icon-theme`（Inherits 基础）与 `gsettings-desktop-schemas`（gsettings schema），
  均已在 `modules/features/desktop.nix` 安装；同文件系统侧的 `sessionVariables.XDG_DATA_DIRS`
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

