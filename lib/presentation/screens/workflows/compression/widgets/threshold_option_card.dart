import 'package:flutter/material.dart';
import '../constants/compression_option.dart';
import 'custom_size_input.dart';

class ThresholdOptionCard extends StatelessWidget {
  final CompressionOption option;
  final int index;
  final bool isSelected;
  final VoidCallback? onTap;
  final TextEditingController? customSizeController;
  final String? selectedUnit;
  final List<String>? units;
  final ValueChanged<String>? onUnitChanged;

  const ThresholdOptionCard({
    super.key,
    required this.option,
    required this.index,
    required this.isSelected,
    this.onTap,
    this.customSizeController,
    this.selectedUnit,
    this.units,
    this.onUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Card.outlined(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: isSelected ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const minWidthForInline = 500.0;
                final shouldUseInlineLayout = option.isCustom &&
                    isSelected &&
                    constraints.maxWidth >= minWidthForInline;

                return Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: option.color.withAlpha(25),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(
                            option.icon,
                            color: option.color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option.platform,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                option.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (!option.isCustom)
                          Text(
                            option.maxSize,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        else if (isSelected &&
                            shouldUseInlineLayout &&
                            _canShowCustomInput())
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: _buildCustomInput(),
                            ),
                          ),
                      ],
                    ),
                    if (option.isCustom &&
                        isSelected &&
                        !shouldUseInlineLayout &&
                        _canShowCustomInput())
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: _buildCustomInput(),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  bool _canShowCustomInput() {
    return customSizeController != null &&
        selectedUnit != null &&
        units != null &&
        onUnitChanged != null;
  }

  Widget _buildCustomInput() {
    return CustomSizeInput(
      controller: customSizeController!,
      selectedUnit: selectedUnit!,
      units: units!,
      onUnitChanged: onUnitChanged!,
    );
  }
}
