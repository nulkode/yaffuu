import 'package:flutter/material.dart';

class HelpButton extends StatelessWidget {
  final String title;
  final String content;

  const HelpButton({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.help_outline),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return HelpDialog(title: title, content: content);
          },
        );
      },
    );
  }
}

class HelpDialog extends StatelessWidget {
  final String title;
  final String content;

  const HelpDialog({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: SingleChildScrollView(
          child: AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
