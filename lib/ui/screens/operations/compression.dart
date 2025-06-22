import 'package:flutter/material.dart';
import '../../../logic/classes/compression_option.dart';
import '../../components/compression_header.dart';
import 'compression/threshold_view.dart';
import 'compression/advanced_view.dart';

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
                // Dynamic content based on selected approach
                Expanded(
                  child: _buildCompressionContent(),
                ),
                const SizedBox(height: 16),
                // Common Start Compression button
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
      // Reset selection when switching approaches
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
        return true; // Advanced view is always valid for now
    }
  }

  void _startCompression() {
    // TODO: Implement compression logic
    if (selectedOption != null) {
      final size = selectedOption!.isCustom ? customSize : selectedOption!.maxSize;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Starting compression for ${selectedOption!.platform}: $size'),
        ),
      );
    }
  }
}
