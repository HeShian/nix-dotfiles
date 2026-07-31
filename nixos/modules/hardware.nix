{
  config,
  lib,
  pkgs,
  cpu,
  gpu,
  ...
}:
{
    # NVIDIA Wayland 硬件加速
    environment.sessionVariables = lib.optionalAttrs (gpu == "nvidia") {
      GBM_BACKEND = "nvidia-drm";
      LIBVA_DRIVER_NAME = "nvidia";
      NVD_BACKEND = "direct";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    };
    hardware = {
      bluetooth = {
        enable = true;
        powerOnBoot = true;
        # 电池电量等实验性接口
        settings = {
          General.Experimental = true;
        };
      };
      cpu.amd.updateMicrocode = cpu == "amd";
      cpu.intel.updateMicrocode = cpu == "intel";
      enableRedistributableFirmware = true;
      graphics = {
        # 含 32 位库（Steam/Wine 需要）
        enable = true;
        enable32Bit = true;
        # VA-API 驱动：nvidia→nvidia-vaapi-driver、intel→intel-media-driver（amd 的 mesa 已自带）
        extraPackages = lib.optionals (gpu == "nvidia") [
                  pkgs.nvidia-vaapi-driver
                ] ++ lib.optionals (gpu == "intel") [
                  pkgs.intel-media-driver
                ];
      };
      nvidia = lib.mkIf (gpu == "nvidia") {
        modesetting.enable = true;
        # 驱动常驻
        nvidiaPersistenced = true;
        nvidiaSettings = true;
        # 开源内核模块（RTX 50/Blackwell 必须）
        open = true;
        package = config.boot.kernelPackages.nvidiaPackages.latest;
        powerManagement.enable = true;
      };
      opentabletdriver.enable = true;
    };
    services.xserver.videoDrivers = {
      amd = [
        "amdgpu"
      ];
      intel = [
        "modesetting"
      ];
      nvidia = [
        "nvidia"
      ];
    }.${gpu} or [];
  }
