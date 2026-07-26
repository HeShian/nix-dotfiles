{ userName, ... }:
{
    # agenix 密钥：密文存于仓库 secrets/，激活时用主机 host key 解密到 /run/agenix/（tmpfs）；
    # owner = userName 使本机用户可直接读取明文
    age.identityPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
    ];
    # git 推送本仓库 codeberg 远端（credential.helper 运行时读取，不落盘）
    age.secrets.codeberg_token_nix_dotfiles = {
      file = ../../secrets/codeberg_token_nix_dotfiles.age;
      owner = userName;
    };
    # git 推送 ~/Documents/Secret 私有仓库
    age.secrets.codeberg_token_secret = {
      file = ../../secrets/codeberg_token_secret.age;
      owner = userName;
    };
    # VSCode Copilot 自定义端点
    age.secrets.deepseek_api_copilot = {
      file = ../../secrets/deepseek_api_copilot.age;
      owner = userName;
    };
    # opencode 自定义端点
    age.secrets.deepseek_api_opencode = {
      file = ../../secrets/deepseek_api_opencode.age;
      owner = userName;
    };
    # GitHub PAT（ghp_ 前缀）
    age.secrets.github_token_codeberg = {
      file = ../../secrets/github_token_codeberg.age;
      owner = userName;
    };
  }