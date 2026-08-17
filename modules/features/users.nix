# 用户账号与 sudo（flat-form，按 host 实体的逐用户元数据分配权限与 SSH 公钥）
_: {
  den.aspects.users.nixos =
    {
      host,
      lib,
      pkgs,
      ...
    }:
    let
      userNames = lib.attrNames host.users;
    in
    {
      # 登录 shell 用 zsh 需先启用系统模块
      programs.zsh.enable = true;
      # wheel 用户仍需登录密码；需要免密的单条维护命令应另加精确 sudo rule。
      security.sudo.wheelNeedsPassword = true;
      users.users = lib.genAttrs userNames (
        user:
        let
          metadata = host.users.${user};
        in
        {
          extraGroups = [
            "networkmanager"
            "video"
            "audio"
            "render"
          ]
          ++ lib.optionals metadata.isAdmin [
            "wheel"
            "libvirtd"
          ];
          isNormalUser = true;
          openssh.authorizedKeys.keys = metadata.sshAuthorizedKeys;
          shell = pkgs.zsh;
        }
      );
    };
}
