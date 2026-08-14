{
  hostName,
  lib,
  pkgs,
  ...
}:
{
    networking = {
      inherit hostName;
      networkmanager.enable = true;
      # Waydroid 需要
      nftables.enable = true;
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
    # 面板默认绑 0.0.0.0，强制只监听回环
    systemd.services.v2raya.serviceConfig.ExecStart = lib.mkForce "${lib.getExe' pkgs.v2raya "v2rayA"} --log-disable-timestamp --address 127.0.0.1:2017";
  }
