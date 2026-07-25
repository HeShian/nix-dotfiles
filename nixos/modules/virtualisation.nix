{ ... }:
{
  # 虚拟化：libvirt + KVM + virt-manager（USB 直通支持）
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  programs.virt-manager.enable = true;

  # libvirt 默认 NAT 网络的网桥加入防火墙信任接口：
  # 否则 nixos-fw input 链（policy drop）会丢弃 VM 发到宿主机的 DHCP/DNS 请求，
  # dnsmasq 收不到 DHCPDISCOVER → VM 拿不到 IP（virt-manager 显示 IP 未知）、无网络。
  # 与 waydroid 模块自动信任 waydroid0 同理；转发/NAT 由 libvirt 自己的 nftables 表负责。
  networking.firewall.trustedInterfaces = [ "virbr0" ];

  # Waydroid（Android 容器）
  virtualisation.waydroid.enable = true;
}
