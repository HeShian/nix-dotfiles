{ config, pkgs, ... }:
{
  # Flatpak：flathub 国内镜像（中科大主用 + 上交大备用）+ 声明式安装应用
  services.flatpak.enable = true;

  # 安装服务由定时器触发（开机 1 分钟后 + 每天），避免大体积下载阻塞 nixos-rebuild
  systemd.services.flatpak-setup = {
    description = "Flathub 国内镜像配置与声明式应用安装";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = [ pkgs.flatpak ];
    serviceConfig.Type = "oneshot";
    script = ''
      set -e
      # 中科大镜像（主）
      flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
      flatpak remote-modify flathub --url=https://mirrors.ustc.edu.cn/flathub
      # 上交大镜像（备）
      flatpak remote-add --if-not-exists flathub-sjtu https://dl.flathub.org/repo/flathub.flatpakrepo || true
      flatpak remote-modify flathub-sjtu --url=https://mirror.sjtu.edu.cn/flathub
      # 全局时区覆盖：NixOS 的 /etc/localtime 符号链接解析进 /nix/store，
      # flatpak 沙箱无法映射，应用回退显示 UTC；运行时自带 zoneinfo，注入 TZ 修复
      flatpak override --env=TZ=${config.time.timeZone}
      # 声明式安装（已安装则为快速 no-op）
      for app in com.github.tchx84.Flatseal cn.wps.wps_365 eu.betterbird.Betterbird com.usebottles.bottles com.tominlab.wonderpen; do
        flatpak install -y --noninteractive flathub "$app" || echo "install failed: $app"
      done
    '';
  };
  systemd.timers.flatpak-setup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "1d";
    };
  };
}
