enum MediaCodecType {
  video,
  audio,
}

enum MediaCodec {
  h264('h264'),
  aac('aac');

  final String name;
  MediaCodecType get type => switch (this) {
        MediaCodec.h264 => MediaCodecType.video,
        MediaCodec.aac => MediaCodecType.audio,
      };
  const MediaCodec(this.name);
}
