# 虚拟化：libvirtd/virt-manager/waydroid 与 SPICE USB 重定向
_: {
  den.aspects.virtualisation.nixos =
    {
      config,
      host,
      lib,
      pkgs,
      ...
    }:
    {
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
      # nixpkgs 默认禁用 setuid pkexec；Waydroid Helper 用自带的 Polkit policy
      # 约束提权命令，因此仅在安装该工具的 feature 中恢复 wrapper。
      security.polkit.enablePkexecWrapper = true;
      virtualisation.libvirtd.enable = true;
      virtualisation.spiceUSBRedirection.enable = true;
      virtualisation.waydroid.enable = true;

      # waydroid.cfg 含镜像时间戳等运行时状态，不能整体链接到只读 Nix store；
      # 启动前收敛 Intel DRM 与已安装 Houdini 的激活属性，再离线重建它们的派生文件。
      systemd.services = lib.optionalAttrs (host.waydroidDrmDevice != null) {
        waydroid-container.preStart = ''
          waydroid_config=/var/lib/waydroid/waydroid.cfg
          waydroid_base_prop=/var/lib/waydroid/waydroid_base.prop
          waydroid_lxc_nodes=/var/lib/waydroid/lxc/waydroid/config_nodes
          waydroid_drm_device=${lib.escapeShellArg host.waydroidDrmDevice}

          [[ -f "$waydroid_config" ]] || exit 0

          waydroid_needs_upgrade=0

          waydroid_sync_property() {
            local waydroid_property=$1
            local waydroid_value=$2
            local waydroid_current_value

            waydroid_current_value=$("${pkgs.crudini}/bin/crudini" \
              --get "$waydroid_config" properties "$waydroid_property" 2>/dev/null || true)
            if [[ "$waydroid_current_value" != "$waydroid_value" ]]; then
              "${pkgs.crudini}/bin/crudini" \
                --set "$waydroid_config" properties "$waydroid_property" "$waydroid_value"
              waydroid_needs_upgrade=1
            fi

            if ! grep -Fqx "$waydroid_property=$waydroid_value" "$waydroid_base_prop" 2>/dev/null; then
              waydroid_needs_upgrade=1
            fi
          }

          waydroid_current_device=$("${pkgs.crudini}/bin/crudini" \
            --get "$waydroid_config" waydroid drm_device 2>/dev/null || true)

          if [[ "$waydroid_current_device" != "$waydroid_drm_device" ]]; then
            "${pkgs.crudini}/bin/crudini" \
              --set "$waydroid_config" waydroid drm_device "$waydroid_drm_device"
            waydroid_needs_upgrade=1
          fi

          if ! grep -Fqx "gralloc.gbm.device=$waydroid_drm_device" "$waydroid_base_prop" 2>/dev/null; then
            waydroid_needs_upgrade=1
          fi
          if ! grep -Fq "lxc.mount.entry = $waydroid_drm_device " "$waydroid_lxc_nodes" 2>/dev/null; then
            waydroid_needs_upgrade=1
          fi

          # Helper 只负责下载专有 blob；upgrade -o 会重写 prop，因此在 blob
          # 实际存在时固定其激活属性，避免 ARM64-only 应用被 Zygote 拒绝。
          if [[ -x /var/lib/waydroid/overlay/system/bin/houdini64 \
            && -f /var/lib/waydroid/overlay/system/lib64/libhoudini.so ]]; then
            waydroid_sync_property ro.product.cpu.abilist x86_64,arm64-v8a,x86,armeabi-v7a
            waydroid_sync_property ro.product.cpu.abilist32 x86,armeabi-v7a
            waydroid_sync_property ro.product.cpu.abilist64 x86_64,arm64-v8a
            waydroid_sync_property ro.dalvik.vm.native.bridge libhoudini.so
            waydroid_sync_property ro.enable.native.bridge.exec 1
            waydroid_sync_property ro.dalvik.vm.isa.arm x86
            waydroid_sync_property ro.dalvik.vm.isa.arm64 x86_64
          fi

          if ((waydroid_needs_upgrade)); then
            "${config.virtualisation.waydroid.package}/bin/waydroid" upgrade -o
          fi
        '';
      };
    };
}
