{ ... }:
{
    # libvirt 网桥加入防火墙信任接口：否则防火墙 drop 掉 VM 的 DHCP/DNS 请求，
    # VM 拿不到 IP（virt-manager 显示 IP 未知）；与 waydroid 模块自动信任 waydroid0 同理
    networking.firewall.trustedInterfaces = [
      "virbr0"
    ];
    # 虚拟化：libvirtd + KVM + virt-manager，spiceUSBRedirection 提供 USB 直通
    programs.virt-manager.enable = true;
    virtualisation.libvirtd.enable = true;
    virtualisation.spiceUSBRedirection.enable = true;
    # Waydroid（Android 容器）
    virtualisation.waydroid.enable = true;
  }