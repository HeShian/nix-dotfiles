中文 | [English](../en/software.md)

# 软件

已安装软件分类清单。声明位置：`modules/home/app.nix`（日常应用）、`modules/home/desktop.nix`（桌面工具）、`modules/home/shell.nix`（终端工具）、`modules/nixos/desktop.nix`（系统模块）、`modules/nixos/flatpak.nix`（Flatpak）。

## 日常应用

| 分类 | 软件 |
|------|------|
| 浏览器 | zen-twilight（pywalfox-native 主题跟随调色板）、brave |
| IM/会议 | telegram-desktop、discord、qq、wechat、wemeet（走 wemeet-xwayland 包装） |
| 笔记/阅读 | obsidian、z-library-desktop、readest |
| 办公 | wpsoffice-cn（WPS 365，缺字体见下方说明）、onlyoffice-desktopeditors |
| 开发 | vscode、opencode、pi-coding-agent、kimi-code、kitsfmt、uv、python3 |
| 创作 | obs-studio、krita |
| 网络工具 | gopeed（下载）、localsend（局域网传文件）、go-musicfox（网易云）、remmina（远程桌面） |
| 游戏 | gamescope、prismlauncher（MC）、protonplus、lutris、heroic |
| Wine/容器 | wine（stableFull）、winetricks、waydroid-helper |

**WPS 缺字体**：系统已装 corefonts（Arial/Times New Roman/Courier New 等）与 vista-fonts（Calibri 等）；宋体、黑体、Wingdings、Symbol 不可再分发，需从 Windows 的 `C:\Windows\Fonts\` 手工拷贝 `simsun.ttc`、`simhei.ttf`、`wingding.ttf`、`symbol.ttf`（可顺带 `simfang.ttf`/`simkai.ttf`/`msyh.ttc`）到 `~/.local/share/fonts/` 后 `fc-cache -f`。

## 系统模块

| 软件 | 说明 |
|------|------|
| steam | 系统模块提供 udev 规则与 Remote Play 端口 |
| kdeconnect | 系统模块自动放行防火墙端口 |
| Thunar | 文件管理器（含压缩包/可移动卷插件、gvfs 回收站、tumbler 缩略图） |

## Flatpak

| 软件 | 用途 |
|------|------|
| Flatseal | Flatpak 权限管理 |
| Betterbird | 邮件 |
| Bottles | Windows 应用容器 |
| 百度网盘 | 网盘 |

## 桌面工具

| 分类 | 软件 |
|------|------|
| 截图/录屏 | grim、slurp、wf-recorder、satty（标注） |
| 剪贴板 | cliphist、wl-clipboard、wl-clip-persist |
| 媒体 | imv（看图）、mpv、mpvpaper（视频壁纸）、cava、pwvucontrol、playerctl |
| 系统工具 | brightnessctl、udiskie、fuzzel（启动器）、libnotify、file-roller、imagemagick |
| 其他 | xsettingsd、sunsetr（夜间色温）、sound-theme-freedesktop、xprop/file |

## 终端工具

| 软件 | 用途 |
|------|------|
| yazi | 文件管理（`y` 命令退出时跟随目录） |
| neovim | 编辑器（配置在 `dotfiles/nvim/`） |
| lazygit | git TUI |
| fastfetch / btop | 系统信息 / 资源监控 |
