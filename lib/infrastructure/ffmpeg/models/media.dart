import 'package:yaffuu/domain/common/constants/exception.dart';

enum Codec {
  h264('h264'),
  aac('aac');

  final String name;
  const Codec(this.name);

  static Codec fromString(String name) {
    for (var codec in Codec.values) {
      if (codec.name == name) {
        return codec;
      }
    }
    throw JsonParsingException("Unknown codec: $name");
  }
}

enum Format {
  mp4('mp4');

  final String name;
  const Format(this.name);

  static Format fromString(String name) {
    for (var format in Format.values) {
      if (format.name == name) {
        return format;
      }
    }
    throw JsonParsingException("Unknown format: $name");
  }
}

abstract class MediaStream {
  final int index;
  final Codec codec;

  MediaStream(this.index, this.codec);
}

class VideoStream extends MediaStream {
  final int width;
  final int height;
  final double duration;
  final int bitrate;

  VideoStream._(super.index, super.codec, this.width, this.height,
      this.duration, this.bitrate);

  static VideoStream fromJson(Map<String, dynamic> json) {
    if (json['index'] == null ||
        json['codec_name'] == null ||
        json['width'] == null ||
        json['height'] == null ||
        json['duration'] == null ||
        json['bitrate'] == null) {
      throw JsonParsingException('Invalid video stream JSON data.');
    }
    return VideoStream._(
      json['index'],
      Codec.fromString(json['codec_name']),
      json['width'],
      json['height'],
      double.parse(json['duration']),
      json['bitrate'],
    );
  }
}

class AudioStream extends MediaStream {
  final int sampleRate;
  final int channels;
  final double duration;

  AudioStream._(
      super.index, super.codec, this.sampleRate, this.channels, this.duration);

  static AudioStream fromJson(Map<String, dynamic> json) {
    if (json['index'] == null ||
        json['codec_name'] == null ||
        json['sample_rate'] == null ||
        json['channels'] == null ||
        json['duration'] == null) {
      throw JsonParsingException('Invalid audio stream JSON data.');
    }
    return AudioStream._(
      json['index'],
      Codec.fromString(json['codec_name']),
      int.parse(json['sample_rate']),
      json['channels'],
      double.parse(json['duration']),
    );
  }
}

class MediaFile {
  final List<MediaStream> streams;
  final List<Format> formats;
  final int size;

  MediaFile._(this.streams, this.formats, this.size);

  static MediaFile fromJson(Map<String, dynamic> json) {
    try {
      if (json['streams'] == null ||
          json['format'] == null ||
          json['format']['format_name'] == null ||
          json['format']['size'] == null) {
        throw JsonParsingException('Invalid media file JSON data.');
      }

      List<MediaStream> streams = [];
      for (var stream in json['streams']) {
        if (stream['codec_type'] == 'video') {
          streams.add(VideoStream.fromJson(stream));
        } else if (stream['codec_type'] == 'audio') {
          streams.add(AudioStream.fromJson(stream));
        }
      }

      List<Format> formats = [];
      for (var format in json['format']['format_name'].split(',')) {
        formats.add(Format.fromString(format));
      }

      return MediaFile._(
        streams,
        formats,
        int.parse(json['format']['size']),
      );
    } catch (e) {
      throw MultimediaNotFoundOrNotRecognizedException();
    }
  }
}
