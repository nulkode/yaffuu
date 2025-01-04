import 'package:flutter/material.dart';
import 'package:yaffuu/logic/operations/operations.dart';

enum OperationTag {
  image('Image'),
  video('Video'),
  audio('Audio'),
  format('Format'),
  other('Other');

  final String displayName;

  const OperationTag(this.displayName);
}

class DisplayOperation {
  final List<OperationTag> tags;
  final OperationType type;
  final String displayName;

  const DisplayOperation({
    required this.tags,
    required this.type,
    required this.displayName,
  });
}

class DisplayOperationWidget extends StatelessWidget {
  const DisplayOperationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
