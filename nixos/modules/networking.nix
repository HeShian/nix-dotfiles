{
  hostName,
  lib,
  pkgs,
  ...
}:
{
    # 网络：NetworkManager 管理连接
    networking = {
      hostName = hostName;
      networkmanager.enable = true;
      # Waydroid 需要 nftables 后端（waydroid 模块自动选用 waydroid-nftables）
      nftables.enable = true;
    };
    # OpenSSH 服务端（host key 复用已有的 ed25519 主机密钥，与 agenix 一致）
    services.openssh = {
      enable = true;
      settings = {
        # keyboard-interactive 走 PAM，单独关闭才能真正杜绝密码登录
        KbdInteractiveAuthentication = false;
        # 关闭密码登录（仅密钥登录）：配合 sudo 免密，消除局域网内"密码即 root"的放大面
        PasswordAuthentication = false;
      };
    };
    # v2rayA 代理
    services.v2raya.enable = true;
    # v2rayA 面板默认绑 0.0.0.0:2017，而 trustedInterfaces（virbr0/waydroid0）全端口放行，
    # VM/Waydroid 内可直接访问代理面板；强制只监听回环（保留原有 --log-disable-timestamp）
    systemd.services.v2raya.serviceConfig.ExecStart = lib.mkForce "${lib.getExe' pkgs.v2raya "v2rayA"} --log-disable-timestamp --address 127.0.0.1:2017";
  }