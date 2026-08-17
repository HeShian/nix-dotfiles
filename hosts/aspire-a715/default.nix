{ ... }:
{
  # 共享 feature 模块经 den aspects 挂载（modules/features/ 定义、hosts.nix includes）
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];
  # 勿随系统升级改动
  system.stateVersion = "25.05";
}
