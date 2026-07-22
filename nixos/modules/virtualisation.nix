{ ... }:
{
  # 虚拟化：libvirt + KVM + virt-manager（USB 直通支持）
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  programs.virt-manager.enable = true;

  # Waydroid（Android 容器）
  virtualisation.waydroid.enable = true;
}
