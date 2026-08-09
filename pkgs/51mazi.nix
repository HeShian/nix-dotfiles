# 51mazi（我要码字）：Electron 小说写作软件，官方 AppImage 打包
# 注意：GitHub release 资源域名在本网络 DNS 被污染，更新版本后需先经代理
# `nix store prefetch-file <url>` 预取进 store，否则 fetchurl 构建期下载失败
{
  lib,
  appimageTools,
  fetchurl,
}:
let
  pname = "51mazi";
  version = "0.8.5";
  src = fetchurl {
    url = "https://github.com/xiaoshengxianjun/51mazi/releases/download/v${version}/51mazi-${version}.AppImage";
    hash = "sha256-GKDguRDj3oz+kzqczbS5DAXey89B2H3hcqVJGshIBUU=";
  };
  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/51mazi.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/51mazi.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=51mazi'
    install -Dm444 ${appimageContents}/usr/share/icons/hicolor/1024x1024/apps/51mazi.png \
      -t $out/share/icons/hicolor/1024x1024/apps
  '';

  meta = {
    description = "51mazi 小说写作软件（地图设计、关系图谱、人物档案、AI 辅助创作）";
    homepage = "https://github.com/xiaoshengxianjun/51mazi";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "51mazi";
  };
}
