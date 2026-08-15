# fcitx5-rime 附加 rime-ice 雾凇拼音词库
_final: prev: {
  fcitx5-rime = prev.fcitx5-rime.override {
    rimeDataPkgs = [
      prev.rime-data
      prev.rime-ice
    ];
  };
}
