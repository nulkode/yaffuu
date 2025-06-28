import 'package:flutter/material.dart';
import '../../../../shared/widgets/context_menu.dart';

class CustomSizeInput extends StatelessWidget {
  final TextEditingController controller;
  final String selectedUnit;
  final List<String> units;
  final ValueChanged<String> onUnitChanged;

  const CustomSizeInput({
    super.key,
    required this.controller,
    required this.selectedUnit,
    required this.units,
    required this.onUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Enter size',
              border: UnderlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
        const SizedBox(width: 8),
        ContextMenuButton(
          activateOnMainTap: true,
          positionAtWidget: true,
          actions: units.map((unit) {
            return ContextMenuAction(
              label: unit,
              icon: Icons.straighten,
              onTap: () => onUnitChanged(unit),
            );
          }).toList(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedUnit,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_drop_down,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
