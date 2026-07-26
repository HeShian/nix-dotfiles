{ pkgs, userName, ... }:
{
    programs.zsh.enable = true;
    # 登录 shell 用 zsh 需先启用系统模块
    # wheel 组 sudo 免密（有意的个人配置）
    security.sudo.wheelNeedsPassword = false;
    # 用户账号
    users.users.${userName} = {
      # wheel：sudo；networkmanager：网络管理；video/audio/render：显示与音视频设备访问；libvirtd：虚拟机管理
      extraGroups = [
        "wheel"
        "networkmanager"
        "video"
        "audio"
        "render"
        "libvirtd"
      ];
      isNormalUser = true;
      # SSH 登录公钥（本机 ~/.ssh/id_ed25519.pub）；后续其他设备需连入时在此追加公钥
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFRoL7nbbokjssmkeAjrXIQrz5mp5mgd1mZMP6g2UaE3 claudia@westwood"
      ];
      shell = pkgs.zsh;
    };
  }