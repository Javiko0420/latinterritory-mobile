import 'package:flutter/material.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';

enum LtButtonVariant { filled, outlined, text }

/// Branded button with loading state and icon support.
///
/// Usage:
/// ```dart
/// LtButton(
///   label: 'Log In',
///   onPressed: _handleLogin,
///   isLoading: isLoading,
/// )
/// ```
class LtButton extends StatelessWidget {
  const LtButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.variant = LtButtonVariant.filled,
    this.icon,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final LtButtonVariant variant;
  final IconData? icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : icon != null
            ? Row(
                mainAxisSize:
                    fullWidth ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: AppDimensions.iconMd),
                  const SizedBox(width: AppDimensions.sm),
                  Text(label),
                ],
              )
            : Text(label);

    final effectiveOnPressed = isLoading ? null : onPressed;

    return switch (variant) {
      LtButtonVariant.filled => ElevatedButton(
          onPressed: effectiveOnPressed,
          child: child,
        ),
      LtButtonVariant.outlined => OutlinedButton(
          onPressed: effectiveOnPressed,
          child: child,
        ),
      LtButtonVariant.text => TextButton(
          onPressed: effectiveOnPressed,
          child: child,
        ),
    };
  }
}
