{
  cpu = "intel";
  disk = "/dev/nvme0n1";
  gpu = "nvidia";
  primaryUser = "claudia";
  proxy = {
    default = "http://127.0.0.1:7890";
    noProxy = "127.0.0.1,::1,localhost";
  };
  # 用户元数据同时驱动账号权限、SSH 公钥和 Home Manager Git 身份。
  users.claudia = {
    email = "3453289292@qq.com";
    isAdmin = true;
    sshAuthorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFRoL7nbbokjssmkeAjrXIQrz5mp5mgd1mZMP6g2UaE3 claudia@aspire-a715"
    ];
  };
}
