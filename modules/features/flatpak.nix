# Flatpak：应用清单、国内镜像 remote、每日自动更新
_: {
  den.aspects.flatpak.nixos =
    { config, ... }:
    {
      services.flatpak = {
        enable = true;
        overrides = {
          # 否则沙箱内时区回退 UTC
          global.Environment.TZ = config.time.timeZone;
        };
        # flatseal（权限管理）、betterbird（邮件）、bottles（Windows 应用）、百度网盘
        packages = [
          "com.github.tchx84.Flatseal"
          "eu.betterbird.Betterbird"
          "com.usebottles.bottles"
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
    };
}
