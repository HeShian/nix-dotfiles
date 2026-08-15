{
  pkgs,
  lib,
  userName,
  users,
  ...
}:
{
  # 登录 shell 用 zsh 需先启用系统模块
  programs.zsh.enable = true;
  # 有意的个人配置
  security.sudo.wheelNeedsPassword = false;
  # 按 host.nix 的 users 列表生成账号；SSH 公钥只给主用户（其他设备公钥在此追加）
  users.users = lib.genAttrs users (
    user:
    {
      extraGroups = [
        "wheel"
        "networkmanager"
        "video"
        "audio"
        "render"
        "libvirtd"
      ];
      isNormalUser = true;
      shell = pkgs.zsh;
    }
    // lib.optionalAttrs (user == userName) {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFRoL7nbbokjssmkeAjrXIQrz5mp5mgd1mZMP6g2UaE3 claudia@westwood"
      ];
    }
  );
}
