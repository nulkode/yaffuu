import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/compression_option.dart';
import 'package:yaffuu/app/theme/typography.dart';

class CompressionHeader extends StatelessWidget {
  final CompressionApproach selectedApproach;
  final ValueChanged<CompressionApproach> onApproachChanged;

  const CompressionHeader({
    super.key,
    required this.selectedApproach,
    required this.onApproachChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final backButton = IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
          tooltip: 'Back',
        );
        const headerText = Text('Compression', style: AppTypography.titleStyle);
        final segmentedButton = _buildSegmentedButton();

        const minWidthForInline = 500.0;

        if (constraints.maxWidth >= minWidthForInline) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  backButton,
                  const SizedBox(width: 8),
                  headerText,
                ],
              ),
              segmentedButton,
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              backButton,
              const SizedBox(height: 8),
              headerText,
              const SizedBox(height: 16),
              segmentedButton,
            ],
          );
        }
      },
    );
  }

  Widget _buildSegmentedButton() {
    return SegmentedButton<CompressionApproach>(
      segments: const [
        ButtonSegment<CompressionApproach>(
          value: CompressionApproach.byThreshold,
          label: Text('By threshold'),
        ),
        ButtonSegment<CompressionApproach>(
          value: CompressionApproach.advanced,
          label: Text('Advanced'),
        ),
      ],
      selected: {selectedApproach},
      onSelectionChanged: (Set<CompressionApproach> selection) {
        onApproachChanged(selection.first);
      },
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: Colors.grey.shade300,
        selectedForegroundColor: Colors.black87,
        side: BorderSide(color: Colors.grey.shade400),
        iconSize: 0,
      ),
      showSelectedIcon: false,
    );
  }
}
