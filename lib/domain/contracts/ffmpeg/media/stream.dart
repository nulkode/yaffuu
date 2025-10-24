import 'package:yaffuu/domain/contracts/ffmpeg/media/codec.dart';

abstract class MediaStream {
  final int index;
  final MediaCodec codec;

  MediaStream(this.index, this.codec);
}

class VideoStream extends MediaStream {
  final int width;
  final int height;
  final double duration;
  final int bitrate;

  VideoStream(super.index, super.codec, this.width, this.height, this.duration,
      this.bitrate);
}

class AudioStream extends MediaStream {
  final int sampleRate;
  final int channels;
  final double duration;

  AudioStream(
      super.index, super.codec, this.sampleRate, this.channels, this.duration);
}
