import 'package:flutter/material.dart';
import '../constants/compression_priority.dart';

class PrioritySelectionWidget extends StatefulWidget {
  final List<CompressionPriority> priorities;
  final Function(List<CompressionPriority>) onPrioritiesChanged;

  const PrioritySelectionWidget({
    super.key,
    required this.priorities,
    required this.onPrioritiesChanged,
  });

  @override
  State<PrioritySelectionWidget> createState() => _PrioritySelectionWidgetState();
}

class _PrioritySelectionWidgetState extends State<PrioritySelectionWidget> {
  late List<CompressionPriority> _priorities;
  late Set<PriorityType> _selectedPriorities;

  @override
  void initState() {
    super.initState();
    _priorities = List.from(widget.priorities);
    _selectedPriorities = <PriorityType>{};
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _buildPriorityGrid(),
      ],
    );
  }

  Widget _buildPriorityGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double cardMinWidth = 260;
        final availableWidth = constraints.maxWidth;
        final cardWidth = availableWidth < cardMinWidth * 2 
            ? availableWidth 
            : (availableWidth - 8) / 2;
        
        return Wrap(
          spacing: 4,
          runSpacing: 4,
          children: _priorities.map((priority) {
            final isSelected = _selectedPriorities.contains(priority.type);
            return SizedBox(
              width: cardWidth,
              child: _buildPriorityCard(priority, isSelected),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildPriorityCard(CompressionPriority priority, bool isSelected) {
    return Card.outlined(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => _togglePriority(priority.type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary 
                  : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  priority.icon,
                  size: 32,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        priority.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        priority.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _togglePriority(PriorityType type) {
    setState(() {
      if (_selectedPriorities.contains(type)) {
        _selectedPriorities.remove(type);
      } else {
        _selectedPriorities.add(type);
      }
    });

    // Create a list of selected priorities in their original order
    final selectedPriorities = _priorities
        .where((priority) => _selectedPriorities.contains(priority.type))
        .toList();

    widget.onPrioritiesChanged(selectedPriorities);
  }
}
