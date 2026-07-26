{
  config,
  lib,
  pkgs,
  cpu,
  gpu,
  ...
}:
{
    # NVIDIA 环境变量（Wayland 下的硬件加速）
    environment.sessionVariables = lib.optionalAttrs (gpu == "nvidia") {
      GBM_BACKEND = "nvidia-drm";
      LIBVA_DRIVER_NAME = "nvidia";
      NVD_BACKEND = "direct";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    };
    hardware = {
      # 蓝牙；Experimental 开启电池电量等实验性接口
      bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings = {
          General.Experimental = true;
        };
      };
      # CPU 微码更新（按 host.nix 的 cpu 参数二选一）
      cpu.amd.updateMicrocode = cpu == "amd";
      cpu.intel.updateMicrocode = cpu == "intel";
      enableRedistributableFirmware = true;
      graphics = {
        # 图形加速（含 32 位库，Steam/Wine 需要）
        enable = true;
        enable32Bit = true;
        # VA-API 驱动按 GPU 条件化：nvidia 用 nvidia-vaapi-driver、intel 用 intel-media-driver；
        # amd 的 mesa 默认已含 VA-API 驱动（radeonsi），无需额外包
        extraPackages = lib.optionals (gpu == "nvidia") [
                  pkgs.nvidia-vaapi-driver
                ] ++ lib.optionals (gpu == "intel") [
                  pkgs.intel-media-driver
                ];
      };
      nvidia = lib.mkIf (gpu == "nvidia") {
        modesetting.enable = true;
        nvidiaPersistenced = true;
        # 持久守护进程：驱动常驻，减少重复初始化
        nvidiaSettings = true;
        open = true;
        # 开源内核模块（RTX 50/Blackwell 必须）
        package = config.boot.kernelPackages.nvidiaPackages.latest;
        powerManagement.enable = true;
      };
      # OpenTabletDriver（数位板驱动，含 udev 规则与守护进程）
      opentabletdriver.enable = true;
    };
    # 显卡驱动选择（按 host.nix 的 gpu 参数）
    services.xserver.videoDrivers = if gpu == "nvidia" then
          [
            "nvidia"
          ] else
          if gpu == "amd" then
            [
              "amdgpu"
            ] else
            if gpu == "intel" then
              [
                "modesetting"
              ] else
              [];
  }