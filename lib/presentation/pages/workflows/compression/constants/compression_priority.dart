import 'package:flutter/material.dart';

enum PriorityType {
  sharpness,
  resolution,
  smoothness,
  audioQuality,
  processingSpeed,
}

class CompressionPriority {
  final PriorityType type;
  final String name;
  final String description;
  final IconData icon;
  final int priority; // 1 = highest, 5 = lowest

  const CompressionPriority({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.priority,
  });

  CompressionPriority copyWith({
    PriorityType? type,
    String? name,
    String? description,
    IconData? icon,
    int? priority,
  }) {
    return CompressionPriority(
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      priority: priority ?? this.priority,
    );
  }
}

final List<CompressionPriority> defaultPriorities = [
  const CompressionPriority(
    type: PriorityType.sharpness,
    name: 'Sharpness',
    description: 'Preserve fine details and edge definition',
    icon: Icons.auto_fix_high,
    priority: 1,
  ),
  const CompressionPriority(
    type: PriorityType.resolution,
    name: 'Resolution',
    description: 'Maintain video dimensions and clarity',
    icon: Icons.crop,
    priority: 2,
  ),
  const CompressionPriority(
    type: PriorityType.smoothness,
    name: 'Smoothness',
    description: 'Ensure fluid motion and frame rate',
    icon: Icons.play_circle_filled,
    priority: 3,
  ),
  const CompressionPriority(
    type: PriorityType.audioQuality,
    name: 'Audio Quality',
    description: 'Preserve sound clarity and fidelity',
    icon: Icons.volume_up,
    priority: 4,
  ),
  const CompressionPriority(
    type: PriorityType.processingSpeed,
    name: 'Processing Speed',
    description: 'Optimize for faster encoding time',
    icon: Icons.speed,
    priority: 5,
  ),
];
