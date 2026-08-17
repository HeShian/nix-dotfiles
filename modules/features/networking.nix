# 网络：NetworkManager/nftables、OpenSSH（禁密码登录）、v2raya（面板限定回环）
_: {
  den.aspects.networking.nixos =
    { host, lib, ... }:
    {
      # networking.hostName 由主机 aspect 按 host.hostName 设置（见 modules/flake/hosts.nix）
      networking = {
        networkmanager.enable = true;
        # Waydroid 需要
        nftables.enable = true;
      }
      // lib.optionalAttrs (host.proxy != null) {
        inherit (host) proxy;
      };
      # host key 与 agenix 复用同一把
      services.openssh = {
        enable = true;
        settings = {
          # 走 PAM，需单独关闭才能杜绝密码登录
          KbdInteractiveAuthentication = false;
          PasswordAuthentication = false;
        };
      };
      services.v2raya.enable = true;
      # v2rayA 默认监听 0.0.0.0:2017；桌面单机使用无需把管理面板暴露到局域网。
      systemd.services.v2raya.environment.V2RAYA_ADDRESS = "127.0.0.1:2017";
    };
}
