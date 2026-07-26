{
  disk ? (import ./host.nix).disk,
  ...
}:
{
    disko.devices = {
      disk = {
        # 主磁盘：设备路径取 host.nix 的 disk 参数
        main = {
          content = {
            partitions = {
              # EFI 系统分区（ESP）：GRUB 安装于此
              boot = {
                content = {
                  format = "vfat";
                  mountOptions = [
                    "umask=0077"
                  ];
                  mountpoint = "/boot";
                  type = "filesystem";
                };
                priority = 1;
                size = "1G";
                type = "EF00";
              };
              # btrfs 根分区（占剩余全部空间），按用途拆分子卷
              root = {
                content = {
                  # -f：强制格式化，重复使用同一块盘时忽略已有文件系统签名
                  extraArgs = [
                    "-f"
                  ];
                  # 各子卷统一 zstd 压缩 + noatime
                  subvolumes = {
                    # Home 子卷：数据与系统分离，便于独立快照
                    "/home" = {
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                      mountpoint = "/home";
                    };
                    # Nix store 子卷：store 可由声明式配置重建，无需纳入根卷快照
                    "/nix" = {
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                      mountpoint = "/nix";
                    };
                    # 根目录子卷
                    "/root" = {
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                      mountpoint = "/";
                    };
                  };
                  type = "btrfs";
                };
                priority = 3;
                size = "100%";
              };
              # 交换分区：16G，resumeDevice 标记为休眠恢复设备
              swap = {
                content = {
                  resumeDevice = true;
                  type = "swap";
                };
                priority = 2;
                size = "16G";
              };
            };
            type = "gpt";
          };
          device = disk;
          type = "disk";
        };
      };
    };
  }