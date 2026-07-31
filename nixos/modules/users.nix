{ pkgs, userName, ... }:
{
    # 登录 shell 用 zsh 需先启用系统模块
    programs.zsh.enable = true;
    # 有意的个人配置
    security.sudo.wheelNeedsPassword = false;
    users.users.${userName} = {
      extraGroups = [
        "wheel"
        "networkmanager"
        "video"
        "audio"
        "render"
        "libvirtd"
      ];
      isNormalUser = true;
      # 其他设备公钥在此追加
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFRoL7nbbokjssmkeAjrXIQrz5mp5mgd1mZMP6g2UaE3 claudia@westwood"
      ];
      shell = pkgs.zsh;
    };
  }
