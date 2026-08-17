# home-manager 全局行为（HM NixOS 模块由 den 在用户声明时自动导入；
# 只进常规主机的 includes，install 变体引用 home-manager.* 选项会报“选项不存在”）
_: {
  den.aspects.hm-global.nixos = {
    home-manager = {
      backupFileExtension = "backup";
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };
}
