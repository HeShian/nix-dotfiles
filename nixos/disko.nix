{
  disk ? (import ./host.nix).disk,
  ...
}:
{
    disko.devices = {
      disk = {
        # 物理磁盘设备
        main = {
          content = {
            partitions = {
              boot = {
                content = {
                  format = "vfat";
                  mountOptions = [
                    "umask=0077"
                  ];
                  mountpoint = "/boot";
                  type = "filesystem";
                };
                # 引导分区
                priority = 1;
                size = "1G";
                type = "EF00";
              };
              root = {
                content = {
                  extraArgs = [
                    "-f"
                  ];
                  # 强制格式化
                  subvolumes = {
                    "/home" = {
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                      # Home 目录子卷 (数据与系统分离，方便快照)
                      mountpoint = "/home";
                    };
                    "/nix" = {
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                      # Nix Store 子卷 (避免 Nix 垃圾占满快照)
                      mountpoint = "/nix";
                    };
                    "/root" = {
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                      # 根目录子卷
                      mountpoint = "/";
                    };
                  };
                  type = "btrfs";
                };
                # 根分区
                priority = 3;
                size = "100%";
              };
              swap = {
                content = {
                  resumeDevice = true;
                  type = "swap";
                };
                # 交换分区
                priority = 2;
                size = "16G";
              };
            };
            type = "gpt";
          };
          # 主磁盘
          device = disk;
          # /dev/sda 或 /dev/nvme0n1 等
          type = "disk";
        };
      };
    };
  }