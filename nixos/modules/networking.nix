{ hostName, ... }:
{
  # 网络
  networking = {
    hostName = hostName;
    networkmanager.enable = true;
    # Waydroid（Android 容器；nftables 后端 — 模块自动选用 waydroid-nftables）
    nftables.enable = true;
  };

  # 代理
  services.v2raya.enable = true;

  # OpenSSH 服务端（host key 复用已有的 ed25519 主机密钥，与 agenix 一致）
  services.openssh = {
    enable = true;
    # 关闭密码登录（仅密钥登录）：配合 sudo 免密，消除局域网内"密码即 root"的放大面
    settings.PasswordAuthentication = false;
  };
}
