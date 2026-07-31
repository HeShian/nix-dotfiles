{ config, ... }:
{
    services.flatpak = {
      enable = true;
      overrides = {
        # 妙笔：绕过 document portal 的 SQLite I/O 问题
        "com.tominlab.wonderpen".Context.filesystems = [
          "xdg-documents/wonderpen"
        ];
        # 否则沙箱内时区回退 UTC
        global.Environment.TZ = config.time.timeZone;
      };
      # flatseal（权限管理）、wps365（办公）、betterbird（邮件）、bottles（Windows 应用）、妙笔（写作）、百度网盘
      packages = [
        "com.github.tchx84.Flatseal"
        "cn.wps.wps_365"
        "eu.betterbird.Betterbird"
        "com.usebottles.bottles"
        "com.tominlab.wonderpen"
        "com.baidu.NetDisk"
      ];
      remotes = [
        # 中科大镜像（主）
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
      # onActivation=false 避免下载阻塞 rebuild
      update.auto = {
        enable = true;
        onCalendar = "daily";
      };
    };
  }
