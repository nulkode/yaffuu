import 'package:flutter/material.dart';
import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:yaffuu/presentation/pages/workflows/compression/constants/compression_option.dart'
    as compression_options;
import '../constants/compression_option.dart';
import '../constants/compression_priority.dart';
import '../widgets/threshold_option_card.dart';
import '../widgets/priority_selection_widget.dart';

class ThresholdView extends StatefulWidget {
  final Function(CompressionOption?, String?, List<CompressionPriority>?)
      onSelectionChanged;

  const ThresholdView({
    super.key,
    required this.onSelectionChanged,
  });

  @override
  State<ThresholdView> createState() => _ThresholdViewState();
}

class _ThresholdViewState extends State<ThresholdView>
    with TickerProviderStateMixin {
  int? selectedOptionIndex;
  final TextEditingController _customSizeController = TextEditingController();
  String _selectedUnit = 'MB';
  List<CompressionPriority> _priorities = List.from(defaultPriorities);
  late AnimationController _priorityAnimationController;

  @override
  void initState() {
    super.initState();
    _priorityAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _customSizeController.dispose();
    _priorityAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayOptions = selectedOptionIndex == null
        ? compression_options.defaultOptions
        : [compression_options.defaultOptions[selectedOptionIndex!]];

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
                compression_options.defaultOptions.indexOf(option);
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
            height: selectedOptionIndex != null ? 56.0 : 0.0,
            child: selectedOptionIndex != null
                ? Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: IconButton(
                        onPressed: _deselectOption,
                        icon: const Icon(Icons.close),
                      ),
                    ),
                  )
                : null,
          ),
        ),
        AnimatedBuilder(
          animation: _priorityAnimationController,
          builder: (context, child) {
            final sizeAnimation = CurvedAnimation(
              parent: _priorityAnimationController,
              curve: Curves.easeInOutCubic,
            );

            final fadeAnimation = CurvedAnimation(
              parent: _priorityAnimationController,
              curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
            );

            return SizeTransition(
              sizeFactor: sizeAnimation,
              axis: Axis.vertical,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: PrioritySelectionWidget(
                  priorities: _priorities,
                  onPrioritiesChanged: _onPrioritiesChanged,
                ),
              ),
            );
          },
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
        _priorityAnimationController.forward();
      }
    });

    final customSize =
        option.isCustom ? '${_customSizeController.text} $_selectedUnit' : null;
    widget.onSelectionChanged(option, customSize, _priorities);
  }

  void _deselectOption() {
    setState(() {
      selectedOptionIndex = null;
      _priorityAnimationController.reverse();
    });
    widget.onSelectionChanged(null, null, null);
  }

  void _onUnitChanged(String unit) {
    setState(() {
      _selectedUnit = unit;
    });

    if (selectedOptionIndex != null &&
        compression_options.defaultOptions[selectedOptionIndex!].isCustom) {
      final customSize = '${_customSizeController.text} $_selectedUnit';
      widget.onSelectionChanged(
        compression_options.defaultOptions[selectedOptionIndex!],
        customSize,
        _priorities,
      );
    }
  }

  void _onPrioritiesChanged(List<CompressionPriority> priorities) {
    setState(() {
      _priorities = priorities;
    });

    if (selectedOptionIndex != null) {
      final option = compression_options.defaultOptions[selectedOptionIndex!];
      final customSize = option.isCustom
          ? '${_customSizeController.text} $_selectedUnit'
          : null;
      widget.onSelectionChanged(option, customSize, _priorities);
    }
  }
}
