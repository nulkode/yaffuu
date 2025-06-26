import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yaffuu/app/theme/typography.dart';

/// A dialog for displaying detailed error messages with technical information.
class DetailedErrorDialog extends StatefulWidget {
  final String title;
  final String message;
  final String? technicalDetails;
  final VoidCallback? onOk;

  const DetailedErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.technicalDetails,
    this.onOk,
  });

  @override
  State<DetailedErrorDialog> createState() => _DetailedErrorDialogState();
}

class _DetailedErrorDialogState extends State<DetailedErrorDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showCheckIcon = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.message),
                      if (widget.technicalDetails != null) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Technical Details',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.maxFinite,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.technicalDetails!,
                                      style: AppTypography.codeStyle.copyWith(fontSize: 12),
                                    ),
                                  ),
                                  IconButton(
                                    icon: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 300),
                                      child: _showCheckIcon
                                          ? FadeTransition(
                                              opacity: _fadeAnimation,
                                              child: const Icon(Icons.check, size: 16, key: ValueKey('check')),
                                            )
                                          : const Icon(Icons.copy, size: 16, key: ValueKey('copy')),
                                    ),
                                    onPressed: () => _copyToClipboard(context),
                                    tooltip: 'Copy to clipboard',
                                    constraints: const BoxConstraints(
                                      minWidth: 24,
                                      minHeight: 24,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: widget.onOk ?? () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context) async {
    if (widget.technicalDetails != null) {
      await Clipboard.setData(ClipboardData(text: widget.technicalDetails!));
      
      setState(() {
        _showCheckIcon = true;
      });
      _animationController.forward();
      
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          _animationController.reverse().then((_) {
            if (mounted) {
              setState(() {
                _showCheckIcon = false;
              });
            }
          });
        }
      });
    }
  }
}

/// Shows a detailed error dialog with optional technical details.
Future<void> showDetailedErrorDialog({
  required BuildContext context,
  required String title,
  required String message,
  String? technicalDetails,
  VoidCallback? onOk,
}) {
  return showDialog(
    context: context,
    builder: (context) => DetailedErrorDialog(
      title: title,
      message: message,
      technicalDetails: technicalDetails,
      onOk: onOk,
    ),
  );
}
