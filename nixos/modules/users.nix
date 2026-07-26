{ pkgs, userName, ... }:
{
    programs.zsh.enable = true;
    security.sudo.wheelNeedsPassword = false;
    # 用户
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
      # SSH 登录公钥（本机 ~/.ssh/id_ed25519.pub）；后续其他设备需连入时在此追加公钥
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFRoL7nbbokjssmkeAjrXIQrz5mp5mgd1mZMP6g2UaE3 claudia@westwood"
      ];
      shell = pkgs.zsh;
    };
  }