import 'package:flutter/material.dart';
import '../../logic/classes/compression_option.dart';

class CompressionData {
  static final List<CompressionOption> defaultOptions = [
    const CompressionOption(
      platform: 'Discord (No Nitro)',
      maxSize: '10 MB',
      icon: Icons.chat,
      description: 'Standard Discord file upload limit',
      color: Colors.orange,
    ),
    const CompressionOption(
      platform: 'Discord (Nitro Basic)',
      maxSize: '50 MB',
      icon: Icons.chat,
      description: 'Discord Nitro Basic file upload limit',
      color: Colors.blue,
    ),
    const CompressionOption(
      platform: 'Discord (Nitro)',
      maxSize: '500 MB',
      icon: Icons.chat,
      description: 'Discord Nitro file upload limit',
      color: Colors.purple,
    ),
    const CompressionOption(
      platform: 'Custom',
      maxSize: 'Set size',
      icon: Icons.tune,
      description: 'Set your own file size limit',
      color: Colors.grey,
      isCustom: true,
    ),
  ];

  static const List<String> sizeUnits = ['kB', 'MB', 'GB'];
}
