let
  # 主机 host key（重装后需 agenix -r 重加密）
  westwood = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID0r8ojOXN2n9Ufqn6owjKu1twZndbyvrJ9tsnxTByYO";
  # 用户密钥（本机 agenix CLI 查看/编辑用）
  claudia = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFRoL7nbbokjssmkeAjrXIQrz5mp5mgd1mZMP6g2UaE3";
in
{
  # DeepSeek API key（VSCode Copilot）
  "deepseek_api_copilot.age".publicKeys = [
    westwood
    claudia
  ];
  # DeepSeek API key（opencode）
  "deepseek_api_opencode.age".publicKeys = [
    westwood
    claudia
  ];
  # GitHub PAT（ghp_ 前缀）
  "github_token_codeberg.age".publicKeys = [
    westwood
    claudia
  ];
}
