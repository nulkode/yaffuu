import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class FFmpegLogo extends StatelessWidget {
  final double width;
  const FFmpegLogo({super.key, this.width = 120});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    final ffmpegLogo = isDarkTheme
        ? 'assets/images/ffmpeg_dark.svg'
        : 'assets/images/ffmpeg_light.svg';

    return SvgPicture.asset(
      ffmpegLogo,
      width: width,
    );
  }
}

class YaffuuLogo extends StatelessWidget {
  final double? width;
  const YaffuuLogo({super.key, this.width});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    final yaffuuLogo = isDarkTheme
        ? 'assets/images/yaffuu_dark.svg'
        : 'assets/images/yaffuu_light.svg';

    return SvgPicture.asset(
      yaffuuLogo,
      width: width,
    );
  }
}
