# wemeet 绿屏方案：Exec 改走 wemeet-xwayland 包装（x11/xcb），原生 Wayland 版勿用
# 注：此 overrideAttrs 块保持手工格式（kitsfmt 会排乱，已知 bug）
final: prev: {
  wemeet = prev.wemeet.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      substituteInPlace $out/share/applications/wemeetapp.desktop \
        --replace-fail "Exec=wemeet %u" "Exec=wemeet-xwayland %u"
    '';
  });
}
