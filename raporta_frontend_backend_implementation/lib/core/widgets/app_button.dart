import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, outlined, text }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isExpanded;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isExpanded = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    final Widget button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: buttonChild,
      ),
      AppButtonVariant.secondary => FilledButton.tonal(
        onPressed: isLoading ? null : onPressed,
        child: buttonChild,
      ),
      AppButtonVariant.outlined => OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        child: buttonChild,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: isLoading ? null : onPressed,
        child: buttonChild,
      ),
    };

    return SizedBox(
      width: isExpanded ? double.infinity : null,
      height: 40,
      child: button,
    );
  }
}
