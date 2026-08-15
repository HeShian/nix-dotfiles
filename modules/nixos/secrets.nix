{ lib, userName, ... }:
{
    # 激活时解密到 /run/agenix/（tmpfs）
    age.identityPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
    ];
    # 各密钥用途：deepseek_api_copilot=VSCode Copilot、deepseek_api_opencode=opencode、deepseek_api_pi=pi-coding-agent、deepseek_api_dsh=deepseek-harness（dsh）、github_token_codeberg=GitHub PAT
    age.secrets = lib.genAttrs [
          "deepseek_api_copilot"
          "deepseek_api_opencode"
          "deepseek_api_pi"
          "deepseek_api_dsh"
          "github_token_codeberg"
        ] (name:
    {
        file = ../../secrets/${name}.age;
        owner = userName;
      });
  }
