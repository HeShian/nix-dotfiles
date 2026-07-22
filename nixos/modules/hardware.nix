{
  config,
  lib,
  pkgs,
  cpu,
  gpu,
  ...
}:
{
  hardware = {
    # CPU 微码
    cpu.amd.updateMicrocode = cpu == "amd";
    cpu.intel.updateMicrocode = cpu == "intel";
    enableRedistributableFirmware = true;
    graphics = {
      # 图形加速库
      enable = true;
      enable32Bit = true;
      extraPackages = lib.optionals (gpu == "nvidia") [
        pkgs.nvidia-vaapi-driver
      ];
    };
    nvidia = lib.mkIf (gpu == "nvidia") {
      modesetting.enable = true;
      nvidiaPersistenced = true;
      # RTX 50/Blackwell 需要开源内核模块
      nvidiaSettings = true;
      open = true;
      # 启用持久守护进程，减少显卡初始化时间
      package = config.boot.kernelPackages.nvidiaPackages.latest;
      powerManagement.enable = true;
    };
    # 蓝牙
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General.Experimental = true;
      };
    };
    # OpenTabletDriver（数位板驱动，含 udev 规则与守护进程）
    opentabletdriver.enable = true;
  };

  # NVIDIA 环境变量（Wayland 下的硬件加速）
  environment.sessionVariables = lib.optionalAttrs (gpu == "nvidia") {
    GBM_BACKEND = "nvidia-drm";
    LIBVA_DRIVER_NAME = "nvidia";
    NVD_BACKEND = "direct";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  # CPU/GPU 驱动选择
  services.xserver.videoDrivers =
    if gpu == "nvidia" then
      [ "nvidia" ]
    else if gpu == "amd" then
      [ "amdgpu" ]
    else if gpu == "intel" then
      [ "modesetting" ]
    else
      [ ];
}
