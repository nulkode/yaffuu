import 'package:yaffuu/domain/media/stream.dart';

enum Format {
  mp4('mp4'),
  mov('mov');

  final String name;
  const Format(this.name);
}

class MediaContainer {
  final List<MediaStream> streams;
  final List<Format> formats;
  final int size;

  MediaContainer(this.streams, this.formats, this.size);
}