# wf-recorder 0.6.0 未适配 ffmpeg 8+（AVCodec.sample_fmts 已移除），改用 ffmpeg_7 构建
# 上游修复或 nixpkgs 跟进后可删除此文件
_final: prev: {
  wf-recorder = prev.wf-recorder.override { ffmpeg = prev.ffmpeg_7; };
}
