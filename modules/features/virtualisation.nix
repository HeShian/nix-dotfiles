# 虚拟化：libvirtd/virt-manager/waydroid 与 SPICE USB 重定向
_: {
  den.aspects.virtualisation.nixos = { pkgs, ... }: {
    environment.systemPackages = [
      # libhoudini 等 ARM 翻译层是专有 blob，nixpkgs 不分发；
      # 用这个 GUI 在运行时下载安装（Intel CPU 装 libhoudini，AMD 装 libndk）
      pkgs.waydroid-helper
    ];
    # 信任网桥，否则 VM 拿不到 IP
    networking.firewall.trustedInterfaces = [
      "virbr0"
    ];
    programs.virt-manager.enable = true;
    virtualisation.libvirtd.enable = true;
    virtualisation.spiceUSBRedirection.enable = true;
    virtualisation.waydroid.enable = true;
  };
}
