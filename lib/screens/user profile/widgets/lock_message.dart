import 'package:flutter/material.dart';
import 'package:rudhirakshapp/core/constants/app_radius.dart';

class LockMessageWrapper extends StatelessWidget {
  final Widget child;
  final String message;

  const LockMessageWrapper({
    super.key,
    required this.child,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            title: const Text(
              "Field Locked",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      },
      child: child,
    );
  }
}
