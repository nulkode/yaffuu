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
  State<PrioritySelectionWidget> createState() =>
      _PrioritySelectionWidgetState();
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
        const double minWidthForTwoColumns = 450; // Ajusta según necesites
        final bool useTwoColumns =
            constraints.maxWidth >= minWidthForTwoColumns;

        if (useTwoColumns) {
          return _buildTwoColumnLayout();
        } else {
          return _buildSingleColumnLayout();
        }
      },
    );
  }

  Widget _buildTwoColumnLayout() {
    final leftColumn = <CompressionPriority>[];
    final rightColumn = <CompressionPriority>[];

    for (int i = 0; i < _priorities.length; i++) {
      if (i % 2 == 0) {
        leftColumn.add(_priorities[i]);
      } else {
        rightColumn.add(_priorities[i]);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: leftColumn
                .map((priority) => _buildPriorityCard(
                    priority, _selectedPriorities.contains(priority.type)))
                .toList(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            children: rightColumn
                .map((priority) => _buildPriorityCard(
                    priority, _selectedPriorities.contains(priority.type)))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleColumnLayout() {
    return Column(
      children: _priorities
          .map((priority) => _buildPriorityCard(
              priority, _selectedPriorities.contains(priority.type)))
          .toList(),
    );
  }

  Widget _buildPriorityCard(CompressionPriority priority, bool isSelected) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      child: Card.outlined(
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

    final selectedPriorities = _priorities
        .where((priority) => _selectedPriorities.contains(priority.type))
        .toList();

    widget.onPrioritiesChanged(selectedPriorities);
  }
}
