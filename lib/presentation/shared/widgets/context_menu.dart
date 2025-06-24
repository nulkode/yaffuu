import 'package:flutter/material.dart';
import 'package:yaffuu/domain/logger.dart';

class ContextMenuAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const ContextMenuAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });
}

class ContextMenuButton extends StatelessWidget {
  final List<ContextMenuAction> actions;
  final Widget child;
  final bool activateOnMainTap;
  final bool positionAtWidget;

  const ContextMenuButton({
    super.key,
    required this.actions,
    required this.child,
    this.activateOnMainTap = false,
    this.positionAtWidget = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: activateOnMainTap
          ? (details) {
              final position = positionAtWidget
                  ? _getWidgetPosition(context)
                  : details.globalPosition;
              _showContextMenu(context, position);
            }
          : null,
      onSecondaryTapDown: activateOnMainTap
          ? null
          : (details) {
              final position = positionAtWidget
                  ? _getWidgetPosition(context)
                  : details.globalPosition;
              _showContextMenu(context, position);
            },
      onLongPressStart: activateOnMainTap
          ? null
          : (details) {
              final position = positionAtWidget
                  ? _getWidgetPosition(context)
                  : details.globalPosition;
              _showContextMenu(context, position);
            },
      child: child,
    );
  }

  Offset _getWidgetPosition(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    return renderBox.localToGlobal(Offset.zero);
  }

  void _showContextMenu(BuildContext context, Offset position) {
    logger.d('Showing context menu at position: $position');

    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(position.dx, position.dy, 0, 0),
        Rect.fromLTWH(0, 0, overlay.size.width, overlay.size.height),
      ),
      constraints: const BoxConstraints(
        minWidth: 160,
        maxWidth: 200,
      ),
      popUpAnimationStyle: AnimationStyle(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      ),
      items: actions.map((action) {
        return PopupMenuItem<void>(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          onTap: action.onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                action.icon,
                size: 16,
                color: action.color,
              ),
              const SizedBox(width: 12),
              Text(
                action.label,
                style: TextStyle(
                  fontSize: 14,
                  color: action.color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
