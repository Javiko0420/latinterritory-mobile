import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';

enum LtButtonVariant { filled, outlined, text }

/// Branded button with loading state, icon support, and a soft brand-colored
/// shadow on the filled variant for a tactile, "stamp-like" feel.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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

    final labelStyle = GoogleFonts.spaceGrotesk(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
    );

    final filledShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
    );

    switch (variant) {
      case LtButtonVariant.filled:
        return DecoratedBox(
          decoration: isDark
              ? const BoxDecoration()
              : BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMd),
                  boxShadow: onPressed == null
                      ? null
                      : [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
          child: ElevatedButton(
            onPressed: effectiveOnPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
              shape: filledShape,
              textStyle: labelStyle,
              elevation: 0,
            ),
            child: child,
          ),
        );
      case LtButtonVariant.outlined:
        return OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
            shape: filledShape,
            textStyle: labelStyle,
          ),
          child: child,
        );
      case LtButtonVariant.text:
        return TextButton(
          onPressed: effectiveOnPressed,
          style: TextButton.styleFrom(textStyle: labelStyle),
          child: child,
        );
    }
  }
}
