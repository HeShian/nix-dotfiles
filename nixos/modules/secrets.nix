{ userName, ... }:
{
    # agenix 密钥：密文存于仓库 secrets/，激活时用主机 SSH host key 解密到 /run/agenix/
    # OpenSSH 服务端已启用并复用同一把 host key（见 networking.nix），需显式指定解密私钥路径
    age.identityPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
    ];
    age.secrets.codeberg_token_nix_dotfiles = {
      file = ../../secrets/codeberg_token_nix_dotfiles.age;
      owner = userName;
    };
    age.secrets.codeberg_token_secret = {
      file = ../../secrets/codeberg_token_secret.age;
      owner = userName;
    };
    age.secrets.deepseek_api_copilot = {
      file = ../../secrets/deepseek_api_copilot.age;
      owner = userName;
    };
    age.secrets.deepseek_api_opencode = {
      file = ../../secrets/deepseek_api_opencode.age;
      owner = userName;
    };
    age.secrets.github_token_codeberg = {
      file = ../../secrets/github_token_codeberg.age;
      owner = userName;
    };
  }