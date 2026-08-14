{
  cpu = "intel";
  disk = "/dev/nvme0n1";
  gpu = "nvidia";
  # 与目录名保持一致（flake 以目录名为准）
  hostName = "westwood";
  userEmail = "3453289292@qq.com";
  userName = "claudia";
  # Home Manager 挂载的用户清单（对应 home/<user>/ 目录）
  users = [
    "claudia"
  ];
}
