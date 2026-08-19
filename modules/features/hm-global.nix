# home-manager 全局行为与多用户仓库视图（HM NixOS 模块由 den 在用户声明时自动导入；
# 只进常规主机的 includes，install 变体引用 home-manager.* 选项会报“选项不存在”）
_: {
  den.aspects.hm-global.nixos =
    { host, lib, ... }:
    {
      home-manager = {
        backupFileExtension = "backup";
        # 主用户保留安装器准备的可编辑仓库；其他用户链接当前构建的只读源码快照，
        # 使所有按 ~/Documents/nix-dotfiles 定位的活链接、模板与 nh 都有有效目标。
        sharedModules = [
          (
            { config, ... }:
            {
              home.file."Documents/nix-dotfiles" = lib.mkIf (config.home.username != host.primaryUser) {
                source = ../..;
              };
            }
          )
        ];
        useGlobalPkgs = true;
        useUserPackages = true;
      };
    };
}
