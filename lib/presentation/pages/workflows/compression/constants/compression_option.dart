import 'package:flutter/material.dart';

class CompressionOption {
  final String platform;
  final String maxSize;
  final IconData icon;
  final String description;
  final Color color;
  final bool isCustom;

  const CompressionOption({
    required this.platform,
    required this.maxSize,
    required this.icon,
    required this.description,
    required this.color,
    this.isCustom = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'platform': platform,
      'maxSize': maxSize,
      'icon': icon.codePoint,
      'description': description,
      'color': color.toARGB32(),
      'isCustom': isCustom,
    };
  }

  factory CompressionOption.fromMap(Map<String, dynamic> map) {
    return CompressionOption(
      platform: map['platform'] ?? '',
      maxSize: map['maxSize'] ?? '',
      icon: IconData(map['icon'] ?? Icons.help.codePoint,
          fontFamily: 'MaterialIcons'),
      description: map['description'] ?? '',
      color: Color(map['color'] ?? Colors.grey.toARGB32()),
      isCustom: map['isCustom'] ?? false,
    );
  }

  CompressionOption copyWith({
    String? platform,
    String? maxSize,
    IconData? icon,
    String? description,
    Color? color,
    bool? isCustom,
  }) {
    return CompressionOption(
      platform: platform ?? this.platform,
      maxSize: maxSize ?? this.maxSize,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      color: color ?? this.color,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}

final List<CompressionOption> defaultOptions = [
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

class CustomSizeOption {
  final double size;
  final String unit;
  final DateTime createdAt;

  const CustomSizeOption({
    required this.size,
    required this.unit,
    required this.createdAt,
  });

  String get displaySize => '$size $unit';

  Map<String, dynamic> toMap() {
    return {
      'size': size,
      'unit': unit,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory CustomSizeOption.fromMap(Map<String, dynamic> map) {
    return CustomSizeOption(
      size: map['size']?.toDouble() ?? 0.0,
      unit: map['unit'] ?? 'MB',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  CompressionOption toCompressionOption() {
    return CompressionOption(
      platform: 'Custom ($displaySize)',
      maxSize: displaySize,
      icon: Icons.tune,
      description: 'Custom size created ${_formatDate(createdAt)}',
      color: Colors.grey,
      isCustom: true,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
}

enum CompressionApproach { byThreshold, advanced }
