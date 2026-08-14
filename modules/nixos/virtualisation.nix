{ ... }:
{
    # 信任网桥，否则 VM 拿不到 IP
    networking.firewall.trustedInterfaces = [
      "virbr0"
    ];
    programs.virt-manager.enable = true;
    virtualisation.libvirtd.enable = true;
    virtualisation.spiceUSBRedirection.enable = true;
    virtualisation.waydroid.enable = true;
  }
