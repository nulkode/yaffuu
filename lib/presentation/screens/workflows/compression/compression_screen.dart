import 'package:flutter/material.dart';
import 'constants/compression_option.dart';
import 'widgets/compression_header.dart';
import 'views/threshold_view.dart';
import 'views/advanced_view.dart';

class CompressionView extends StatefulWidget {
  const CompressionView({super.key});

  @override
  State<CompressionView> createState() => _CompressionViewState();
}

class _CompressionViewState extends State<CompressionView> {
  CompressionApproach selectedApproach = CompressionApproach.byThreshold;
  CompressionOption? selectedOption;
  String? customSize;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Compression'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                CompressionHeader(
                  selectedApproach: selectedApproach,
                  onApproachChanged: _onApproachChanged,
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: _buildCompressionContent(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _canStartCompression() ? _startCompression : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Start Compression'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
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
    });
  }

  void _onThresholdSelectionChanged(CompressionOption? option, String? size) {
    setState(() {
      selectedOption = option;
      customSize = size;
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Starting compression for ${selectedOption!.platform}: $size'),
        ),
      );
    }
  }
}
