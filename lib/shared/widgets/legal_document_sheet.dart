import 'package:flutter/material.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';

/// A modal bottom sheet that displays a legal document with scrollable content.
///
/// Usage:
/// ```dart
/// LegalDocumentSheet.show(context, title: 'Terms', content: '...');
/// ```
class LegalDocumentSheet extends StatelessWidget {
  const LegalDocumentSheet({
    super.key,
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  /// Shows the legal document in a modal bottom sheet.
  static void show(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLg),
        ),
      ),
      builder: (_) => LegalDocumentSheet(title: title, content: content),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // ── Drag handle ──────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: AppDimensions.sm),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withValues(alpha: 0.4),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                ),
              ),
            ),

            // ── Header ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPaddingH,
                vertical: AppDimensions.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: AppDimensions.iconMd),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // ── Scrollable content ───────────────────────
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
                child: Text(
                  content,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 1.6,
                      ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
