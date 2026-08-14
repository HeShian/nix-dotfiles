{
  disk ? (import ../../host.nix).disk,
  ...
}:
let
    # 各子卷统一 zstd 压缩 + noatime
    commonOpts = [
      "compress=zstd"
      "noatime"
    ];
in
  {
    disko.devices = {
      disk = {
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
                priority = 1;
                size = "1G";
                type = "EF00";
              };
              root = {
                content = {
                  # -f：忽略已有文件系统签名（重复用盘时）
                  extraArgs = [
                    "-f"
                  ];
                  subvolumes = {
                    "/home" = {
                      mountOptions = commonOpts;
                      mountpoint = "/home";
                    };
                    "/nix" = {
                      mountOptions = commonOpts;
                      mountpoint = "/nix";
                    };
                    "/root" = {
                      mountOptions = commonOpts;
                      mountpoint = "/";
                    };
                  };
                  type = "btrfs";
                };
                priority = 3;
                size = "100%";
              };
              # 支持休眠
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
