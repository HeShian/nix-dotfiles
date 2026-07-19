let
  # agenix 解密公钥
  # westwood 主机的 SSH host key（/etc/ssh/ssh_host_ed25519_key.pub）：系统激活时解密
  # 重装系统后 host key 会变化，需用新公钥重跑 agenix -r 重新加密
  westwood = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID0r8ojOXN2n9Ufqn6owjKu1twZndbyvrJ9tsnxTByYO";
  # claudia 用户密钥（~/.ssh/id_ed25519.pub）：本机用 agenix 命令查看/编辑密钥
  claudia = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFRoL7nbbokjssmkeAjrXIQrz5mp5mgd1mZMP6g2UaE3";
in
{
  # Codeberg access token（nix-dotfiles 仓库推送用）
  "codeberg_token_nix_dotfiles.age".publicKeys = [ westwood claudia ];
  # DeepSeek API key（opencode 用）
  "deepseek_api_opencode.age".publicKeys = [ westwood claudia ];
  # DeepSeek API key（VSCode Copilot 自定义端点用）
  "deepseek_api_copilot.age".publicKeys = [ westwood claudia ];
  # GitHub PAT（ghp_ 前缀，名称为 github_token_codeberg）
  "github_token_codeberg.age".publicKeys = [ westwood claudia ];
}
