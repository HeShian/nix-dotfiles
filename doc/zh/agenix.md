中文 | [English](../en/agenix.md)

# agenix

密钥管理：密文（`.age`）提交进仓库 `secrets/`，明文只在激活时解密到 `/run/agenix/`（tmpfs），不落盘。

## 工作方式

| 项目 | 说明 |
|------|------|
| 解密私钥 | 主机 SSH host key `/etc/ssh/ssh_host_ed25519_key`（`age.identityPaths` 指定） |
| 接收方 | `secrets/secrets.nix` 登记：`westwood`（host key，系统激活用）、`claudia`（用户 `~/.ssh/id_ed25519`，CLI 查看/编辑用） |
| 声明 | `nixos/modules/secrets.nix` 的 `lib.genAttrs` 列表，新增密钥加一行 |
| 读取 | `owner = userName`，用户可直接读 `/run/agenix/<name>` |

## 现有密钥

| 密钥 | 用途 |
|------|------|
| `deepseek_api_copilot` | VSCode Copilot 自定义端点 |
| `deepseek_api_opencode` | opencode |
| `deepseek_api_pi` | pi-coding-agent |
| `github_token_codeberg` | GitHub PAT（ghp_ 前缀） |

## 常用命令

工作目录必须是 `secrets/`（agenix 读同目录 `secrets.nix` 的规则）：

```bash
cd ~/Documents/nix-dotfiles/secrets

# 查看明文
nix run github:ryantm/agenix -- -d <name>.age

# 编辑（打开 $EDITOR，保存即重新加密）
nix run github:ryantm/agenix -- -e <name>.age

# 非交互写入
echo -n "新值" | nix run github:ryantm/agenix -- -e <name>.age

# 新增密钥：先在 secrets.nix 登记 "<name>.age".publicKeys，再执行上面这条

# host key 变更后（重装系统），用新公钥重加密全部密钥
nix run github:ryantm/agenix -- -r
```

改完 `.age` 后需 `nh os switch` 才刷新 `/run/agenix/` 明文。

## 重装后

1. 优先从备份恢复旧机器的 host key 到 `/etc/ssh/`（密钥无需重加密）；
2. 否则生成新 host key，把新公钥加进 `secrets/secrets.nix`，`agenix -r` 重加密全部；
3. 用户私钥 `~/.ssh/id_ed25519` 从备份恢复后即可在任何机器上解密。

## 离线加密

`nix run github:ryantm/agenix` 需要下载 agenix。网络不通时可用 store 里已有的 `age` 二进制直接加密（效果等价，agenix 密文就是标准 age 格式）：

```bash
printf '%s\n%s\n' "<westwood 公钥>" "<claudia 公钥>" > /tmp/recipients.txt
echo -n "明文" | /nix/store/*-age-*/bin/age -R /tmp/recipients.txt -o <name>.age
rm /tmp/recipients.txt
```
