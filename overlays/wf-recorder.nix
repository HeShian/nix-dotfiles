# wf-recorder 0.6.0 未适配 ffmpeg 8+（AVCodec.sample_fmts 已移除）；nixpkgs 参数已改名为 ffmpeg_8，仍绑定 ffmpeg_7 构建
# 上游修复或 nixpkgs 跟进后可删除此文件
_final: prev: {
  wf-recorder = prev.wf-recorder.override { ffmpeg_8 = prev.ffmpeg_7; };
}
