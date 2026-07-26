{ config, ... }:
{
    # Flatpak：由 nix-flatpak（flake 输入，NixOS 模块在 flake.nix 注册）声明式管理
    services.flatpak = {
      enable = true;
      # 全局 TZ 覆盖（legacy overrides 格式，v0.7.0 与新版 coercion 均兼容）：
      # NixOS 的 /etc/localtime 符号链接解析进 /nix/store，flatpak 沙箱无法映射会回退 UTC，
      # 运行时自带 zoneinfo，注入 TZ 修复（Betterbird 邮件时间曾因此显示 UTC）
      overrides = {
        global.Environment.TZ = config.time.timeZone;
      };
      # 声明式安装：flatseal / wps365 / betterbird / bottles / 妙笔（wonderpen）
      packages = [
        "com.github.tchx84.Flatseal"
        "cn.wps.wps_365"
        "eu.betterbird.Betterbird"
        "com.usebottles.bottles"
        "com.tominlab.wonderpen"
      ];
      remotes = [
        # 中科大镜像（主）：直接指向 ostree 仓库 URL（镜像站只镜像 repo，不提供 .flatpakrepo 文件）
        {
          location = "https://mirrors.ustc.edu.cn/flathub";
          name = "flathub";
        }
        # 上交大镜像（备）
        {
          location = "https://mirror.sjtu.edu.cn/flathub";
          name = "flathub-sjtu";
        }
      ];
      # 每日自动更新（realtime systemd timer，睡眠/关机错过会补触发）。
      # update.onActivation 保持默认 false：避免大体积下载阻塞 rebuild
      update.auto = {
        enable = true;
        onCalendar = "daily";
      };
    };
  }