# agenix 密钥分发：激活时用主机 SSH host key 解密到 /run/agenix/（tmpfs），属主为主用户
_: {
  den.aspects.secrets.nixos =
    { host, lib, ... }:
    {
      age.identityPaths = [
        "/etc/ssh/ssh_host_ed25519_key"
      ];
      # 各密钥用途：deepseek_api_copilot=VSCode Copilot、deepseek_api_opencode=opencode、deepseek_api_pi=pi-coding-agent、deepseek_api_dsh=deepseek-harness（dsh）、github_token_codeberg=GitHub PAT
      age.secrets =
        lib.genAttrs
          [
            "deepseek_api_copilot"
            "deepseek_api_opencode"
            "deepseek_api_pi"
            "deepseek_api_dsh"
            "github_token_codeberg"
          ]
          (name: {
            file = ../../secrets/${name}.age;
            owner = host.primaryUser;
          });
    };
}
