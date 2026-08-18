中文 | [English](../en/architecture.md)

# 架构（den 装配）

本仓库用 [den](https://github.com/denful/den)（flake-parts 模块）做主机/用户装配。核心思想：**配置按 feature 组织，主机只挑选 feature**，而不是每台主机堆一摞模块。

## 概念对照

| 概念 | 含义 | 本仓库位置 |
|------|------|-----------|
| Entity（实体） | 一台主机或一个用户 | `den.hosts.x86_64-linux.<name>`（hosts.nix 生成） |
| Aspect | 一个 feature，可同时携带 nixos/homeManager 两类配置 | `den.aspects.<feature>`（`modules/features/<feature>.nix`，文件名即 aspect 名，目录自动聚合） |
| `includes` | aspect 组合：主机/用户 aspect 用它挑 feature | hosts.nix 的 `hostFeatureNames`/`userFeatureNames` |
| `den.schema` | 实体的类型化元数据声明（host.nix 拼错即报错） | schema.nix 的 `den.schema.host`/`den.schema.user` |
| `den.default` | 对所有实体生效的配置（外部 OS 模块、overlays、`_module.args`） | defaults.nix |
| class | 配置类别：`nixos` / `homeManager` | 各模块文件 |
| `provides.to-users` | aspect 随主机挂载、但把 homeManager 内容投递给其用户 | `features/desktop.nix`、`niri.nix`、`mango.nix` |

## 数据流

```
hosts/<name>/host.nix (机器参数)
        ├─ modules/flake/schema.nix 类型化元数据（cpu/gpu/disk/primaryUser/proxy、逐用户属性）
        └─ modules/flake/hosts.nix
              ├─ den.hosts          主机实体 + <name>-install 变体 + 用户实体
              └─ den.aspects.<name> 主机 aspect：imports hosts/<name>/，includes 挑 feature
modules/features/<feature>.nix
        └─ den.aspects.<feature>    feature aspect（目录自动聚合进 flake-parts）
```

- 主机 aspect 与目录同名自动绑定到主机实体；用户 aspect 与用户名同理。
- HM 转发：用户实体的 `homeManager` 类内容由 den 自动写入 `home-manager.users.<user>`（此时才自动导入 HM 的 NixOS 模块）。
- 参数化：需要机器参数的模块用 flat-form（`{ host, ... }: ...`，读 `host.cpu` 等）；需要用户元数据的 user aspect 用 `{ user, ... }:`。flake 输入与 `mylib` 例外，经 defaults.nix 的 `_module.args` 注入。

## feature aspects 清单

| aspect | 类 | 源文件 | 说明 |
|--------|-----|--------|------|
| `boot` | nixos | `modules/features/boot.nix` | GRUB/内核/静默启动 |
| `desktop` | nixos + homeManager | `modules/features/desktop.nix` | 双会话共享的 greeter/portal/音频/文件管理与用户工具 |
| `flatpak` | nixos | `modules/features/flatpak.nix` | Flatpak 应用与镜像 |
| `hardware` | nixos | `modules/features/hardware.nix` | flat-form，读 `host.cpu`/`host.gpu` |
| `hm-global` | nixos | `modules/features/hm-global.nix` | home-manager 全局行为；仅常规主机 |
| `locale` | nixos | `modules/features/locale.nix` | 字体/输入法/时区 |
| `mango` | nixos + homeManager | `modules/features/mango.nix` | Mango + Waybar/SwayNC/Rofi；仅常规主机 |
| `networking` | nixos | `modules/features/networking.nix` | 网络/SSH/v2raya |
| `niri` | nixos + homeManager | `modules/features/niri.nix` | Niri + Noctalia；决定 greeter 默认会话 |
| `nix` | nixos | `modules/features/nix.nix` | nix 设置/缓存/nix-ld |
| `secrets` | nixos | `modules/features/secrets.nix` | agenix；仅常规主机 |
| `users` | nixos | `modules/features/users.nix` | flat-form，读 `host.users`/`host.primaryUser` |
| `virtualisation` | nixos | `modules/features/virtualisation.nix` | libvirtd/waydroid |
| `apps` | homeManager | `modules/features/apps.nix` | 应用程序清单 |
| `dotfiles` | homeManager | `modules/features/dotfiles.nix` | 与合成器无关的通用 dotfiles 活链接 |
| `shell` | homeManager | `modules/features/shell.nix` | zsh/CLI 工具 |

## install 变体

每台主机另有 `<name>-install` 配置（新机安装用，`init.sh` 的第一阶段）：

| 差异 | 实现 |
|------|------|
| 不含 secrets/flatpak/mango | 从 `hostFeatureNames` 派生时由 `installExcludedFeatureNames` 排除；Mango 依赖完整 HM 用户服务，避免构建半成品会话 |
| 不挂 Home Manager | 用户 `classes = [ "user" ]`（覆盖 schema 默认的 `homeManager`） |
| 无 hm-global | 无 HM 模块时引用 `home-manager.*` 选项会报「选项不存在」 |
| 同一网络名 | 实体 `hostName` 显式指回常规主机名 |

常规主机同时包含 `desktop`、`niri`、`mango`；install 变体保留 `desktop` + `niri`，因此安装环境仍有当前稳定的默认 Niri 会话。三个名字也进入共享 aspect 名称冲突检查，无需增加 host schema 字段。

## 约束

- 主机名、`<host>-install`、用户名、feature 名共享 `den.aspects` 命名空间；装配层会统计并拒绝重名。
- 主机必须把 `primaryUser` 同时定义在 `users.<name>`；装配层会在生成配置前拒绝悬空引用。
- `cpu`/`gpu`/`disk`/`primaryUser` 与用户邮箱无默认值（刻意）；`proxy` 可为 `null`，用户管理权与 SSH 公钥默认关闭/为空。
