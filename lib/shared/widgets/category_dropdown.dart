import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/core/i18n/locale_provider.dart';
import 'package:latinterritory/features/categories/application/category_providers.dart';
import 'package:latinterritory/features/categories/domain/category_option.dart';

class CategoryDropdown extends ConsumerWidget {
  const CategoryDropdown({
    super.key,
    required this.vertical,
    required this.value,
    required this.onChanged,
    this.label = 'Categoría',
    this.hint = 'Selecciona una categoría',
    this.enabled = true,
    this.validator,
  });

  final CategoryVertical vertical;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String label;
  final String hint;
  final bool enabled;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = switch (vertical) {
      CategoryVertical.business => ref.watch(businessCategoriesProvider),
      CategoryVertical.job => ref.watch(jobCategoriesProvider),
      CategoryVertical.event => ref.watch(eventCategoriesProvider),
    };
    final locale = ref.watch(localeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final fillColor =
        isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.hankenGrotesk(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: labelColor,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        categoriesAsync.when(
          loading: () => Shimmer.fromColors(
            baseColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            highlightColor:
                isDark ? Colors.grey.shade600 : Colors.grey.shade100,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusMd),
              ),
            ),
          ),
          error: (_, __) => Container(
            height: 50,
            padding:
                const EdgeInsets.symmetric(horizontal: AppDimensions.md),
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'No se pudieron cargar las categorías',
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 13,
                      color: AppColors.error,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  color: AppColors.error,
                  tooltip: 'Reintentar',
                  onPressed: () => switch (vertical) {
                    CategoryVertical.business =>
                      ref.invalidate(businessCategoriesProvider),
                    CategoryVertical.job =>
                      ref.invalidate(jobCategoriesProvider),
                    CategoryVertical.event =>
                      ref.invalidate(eventCategoriesProvider),
                  },
                ),
              ],
            ),
          ),
          data: (categories) {
            // Preserve unknown/legacy value so the dropdown doesn't crash.
            final effectiveItems = [
              ...categories,
              if (value != null &&
                  value!.isNotEmpty &&
                  !categories.any((c) => c.value == value))
                CategoryOption(value: value!, labelEs: value!),
            ];

            return DropdownButtonFormField<String>(
              value: value,
              onChanged: enabled ? onChanged : null,
              validator: validator,
              decoration: InputDecoration(
                hintText: hint,
                filled: true,
                fillColor: fillColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMd),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMd),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMd),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              items: effectiveItems
                  .map(
                    (c) => DropdownMenuItem(
                      value: c.value,
                      child: Text(c.label(vertical, locale)),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
