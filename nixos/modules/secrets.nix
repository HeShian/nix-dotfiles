{ lib, userName, ... }:
{
    # 激活时解密到 /run/agenix/（tmpfs）
    age.identityPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
    ];
    # 各密钥用途：codeberg_token_nix_dotfiles=本仓库推送、codeberg_token_secret=Secret 仓库推送、
    # deepseek_api_copilot=VSCode Copilot、deepseek_api_opencode=opencode、github_token_codeberg=GitHub PAT
    age.secrets = lib.genAttrs [
          "codeberg_token_nix_dotfiles"
          "codeberg_token_secret"
          "deepseek_api_copilot"
          "deepseek_api_opencode"
          "github_token_codeberg"
        ] (name:
    {
        file = ../../secrets/${name}.age;
        owner = userName;
      });
  }
