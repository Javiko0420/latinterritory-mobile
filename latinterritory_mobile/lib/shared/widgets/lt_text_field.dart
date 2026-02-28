import 'package:flutter/material.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';

/// Branded text field with label, hint, and validation support.
///
/// Wraps [TextFormField] with consistent styling.
class LtTextField extends StatelessWidget {
  const LtTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.enabled = true,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLines = 1,
    this.onFieldSubmitted,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool enabled;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int maxLines;
  final ValueChanged<String>? onFieldSubmitted;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppDimensions.xs),
        ],
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          enabled: enabled,
          maxLines: maxLines,
          onFieldSubmitted: onFieldSubmitted,
          autofillHints: autofillHints,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
          ),
        ),
      ],
    );
  }
}
