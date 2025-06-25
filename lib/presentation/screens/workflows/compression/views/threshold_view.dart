import 'package:flutter/material.dart';
import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:yaffuu/presentation/screens/workflows/compression/constants/compression_option.dart'
    as CompressionData;
import '../constants/compression_option.dart';
import '../widgets/threshold_option_card.dart';

class ThresholdView extends StatefulWidget {
  final Function(CompressionOption?, String?) onSelectionChanged;

  const ThresholdView({
    super.key,
    required this.onSelectionChanged,
  });

  @override
  State<ThresholdView> createState() => _ThresholdViewState();
}

class _ThresholdViewState extends State<ThresholdView> {
  int? selectedOptionIndex;
  final TextEditingController _customSizeController = TextEditingController();
  String _selectedUnit = 'MB';

  @override
  void dispose() {
    _customSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayOptions = selectedOptionIndex == null
        ? CompressionData.defaultOptions
        : [CompressionData.defaultOptions[selectedOptionIndex!]];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ImplicitlyAnimatedList<CompressionOption>(
          items: displayOptions,
          areItemsTheSame: (oldItem, newItem) =>
              oldItem.platform == newItem.platform,
          insertDuration: const Duration(milliseconds: 400),
          removeDuration: const Duration(milliseconds: 300),
          updateDuration: const Duration(milliseconds: 350),
          itemBuilder: (context, animation, option, index) {
            final sizeAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            );

            final fadeAnimation = CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
            );

            final originalIndex =
                CompressionData.defaultOptions.indexOf(option);
            final isSelected = selectedOptionIndex == originalIndex;

            return SizeTransition(
              sizeFactor: sizeAnimation,
              axis: Axis.vertical,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: index > 0 ? 4.0 : 0.0,
                  ),
                  child: ThresholdOptionCard(
                    option: option,
                    index: originalIndex,
                    isSelected: isSelected,
                    onTap: () => _selectOption(originalIndex, option),
                    customSizeController:
                        option.isCustom ? _customSizeController : null,
                    selectedUnit: option.isCustom ? _selectedUnit : null,
                    units: option.isCustom
                        ? [
                            'kB',
                            'MB',
                            'GB',
                          ]
                        : null,
                    onUnitChanged: option.isCustom ? _onUnitChanged : null,
                  ),
                ),
              ),
            );
          },
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: selectedOptionIndex != null ? 1.0 : 0.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: selectedOptionIndex != null ? 48.0 : 0.0,
            child: selectedOptionIndex != null
                ? Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: IconButton(
                        onPressed: _deselectOption,
                        icon: const Icon(Icons.close),
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  void _selectOption(int index, CompressionOption option) {
    setState(() {
      if (selectedOptionIndex == null) {
        selectedOptionIndex = index;
        if (option.isCustom) {
          _customSizeController.text = '25';
        }
      }
    });

    final customSize =
        option.isCustom ? '${_customSizeController.text} $_selectedUnit' : null;
    widget.onSelectionChanged(option, customSize);
  }

  void _deselectOption() {
    setState(() {
      selectedOptionIndex = null;
    });
    widget.onSelectionChanged(null, null);
  }

  void _onUnitChanged(String unit) {
    setState(() {
      _selectedUnit = unit;
    });

    if (selectedOptionIndex != null &&
        CompressionData.defaultOptions[selectedOptionIndex!].isCustom) {
      final customSize = '${_customSizeController.text} $_selectedUnit';
      widget.onSelectionChanged(
        CompressionData.defaultOptions[selectedOptionIndex!],
        customSize,
      );
    }
  }
}
