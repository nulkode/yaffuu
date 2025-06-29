import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yaffuu/presentation/screens/home/home_shell.dart';
import 'package:yaffuu/presentation/shared/widgets/single_child_scroll_view_with_padding.dart';
import 'constants/compression_option.dart';
import 'constants/compression_priority.dart';
import 'widgets/compression_header.dart';
import 'views/threshold_view.dart';
import 'views/advanced_view.dart';

class CompressionPage extends StatefulWidget {
  const CompressionPage({super.key});

  @override
  State<CompressionPage> createState() => _CompressionPageState();
}

class _CompressionPageState extends State<CompressionPage> {
  CompressionApproach selectedApproach = CompressionApproach.byThreshold;
  CompressionOption? selectedOption;
  String? customSize;
  List<CompressionPriority>? priorities;

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      child: Column(
        children: [
          CompressionHeader(
            selectedApproach: selectedApproach,
            onApproachChanged: _onApproachChanged,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: SingleChildScrollViewWithPadding(
              sizeTransitionDuration: const Duration(milliseconds: 300),
              child: _buildCompressionContent(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canStartCompression() ? _startCompression : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Start Compression'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCompressionContent() {
    switch (selectedApproach) {
      case CompressionApproach.byThreshold:
        return ThresholdView(
          onSelectionChanged: _onThresholdSelectionChanged,
        );
      case CompressionApproach.advanced:
        return const AdvancedView();
    }
  }

  void _onApproachChanged(CompressionApproach approach) {
    setState(() {
      selectedApproach = approach;
      selectedOption = null;
      customSize = null;
      priorities = null;
    });
  }

  void _onThresholdSelectionChanged(CompressionOption? option, String? size,
      List<CompressionPriority>? newPriorities) {
    setState(() {
      selectedOption = option;
      customSize = size;
      priorities = newPriorities;
    });
  }

  bool _canStartCompression() {
    switch (selectedApproach) {
      case CompressionApproach.byThreshold:
        return selectedOption != null;
      case CompressionApproach.advanced:
        return true;
    }
  }

  void _startCompression() {
    if (selectedOption != null) {
      final size =
          selectedOption!.isCustom ? customSize : selectedOption!.maxSize;

      String message =
          'Starting compression for ${selectedOption!.platform}: $size';

      if (priorities != null && priorities!.isNotEmpty) {
        final priorityNames = priorities!.map((p) => p.name).join(', ');
        message += '\nPriorities: $priorityNames';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );

      context.go('/processing/compression-1');
    }
  }
}
