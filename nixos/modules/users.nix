{ pkgs, userName, ... }:
{
  # 用户
  users.users.${userName} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
      "render"
      "libvirtd"
    ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;

  security.sudo.wheelNeedsPassword = false;
}
