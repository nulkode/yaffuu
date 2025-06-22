import 'package:flutter/material.dart';

class AppTypography {
  static const titleStyle = TextStyle(
    fontFamily: 'RobotoFlex',
    fontWeight: FontWeight.w700,
    fontSize: 20,
    fontVariations: [FontVariation.width(150.0)],
  );

  static const subtitleStyle = TextStyle(
    fontFamily: 'RobotoFlex',
    fontWeight: FontWeight.w500,
    fontSize: 18,
    fontVariations: [FontVariation.width(150.0)],
  );

  static const subsubtitleStyle = TextStyle(
    fontFamily: 'RobotoFlex',
    fontWeight: FontWeight.w400,
    fontSize: 16,
    fontVariations: [FontVariation.width(150.0)],
  );

  static const contentStyle = TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w400,
    fontSize: 16,
  );

  static const codeStyle = TextStyle(
    fontFamily: 'RobotoMono',
    fontWeight: FontWeight.w400,
    fontSize: 16,
  );
}
