# wemeet 绿屏方案：Exec 改走 wemeet-xwayland 包装（x11/xcb），原生 Wayland 版勿用
_final: prev: {
  wemeet = prev.wemeet.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      substituteInPlace $out/share/applications/wemeetapp.desktop \
        --replace-fail "Exec=wemeet %u" "Exec=wemeet-xwayland %u"
    '';
  });
}
