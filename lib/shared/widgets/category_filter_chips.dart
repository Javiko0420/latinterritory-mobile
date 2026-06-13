import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/core/i18n/locale_provider.dart';
import 'package:latinterritory/features/categories/application/category_providers.dart';
import 'package:latinterritory/features/categories/domain/category_option.dart';

class CategoryFilterChips extends ConsumerWidget {
  const CategoryFilterChips({
    super.key,
    required this.vertical,
    required this.selectedValue,
    required this.onChanged,
  });

  final CategoryVertical vertical;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = switch (vertical) {
      CategoryVertical.business => ref.watch(businessCategoriesProvider),
      CategoryVertical.job => ref.watch(jobCategoriesProvider),
      CategoryVertical.event => ref.watch(eventCategoriesProvider),
    };
    final locale = ref.watch(localeProvider);
    final todosLabel = locale.languageCode == 'en' ? 'All' : 'Todos';

    return SizedBox(
      height: 48,
      child: categoriesAsync.when(
        loading: _shimmerRow,
        error: (_, _) => _errorRow(ref, todosLabel),
        data: (cats) => _chipsRow(cats, locale, todosLabel),
      ),
    );
  }

  Widget _shimmerRow() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingH,
        vertical: AppDimensions.sm,
      ),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(width: AppDimensions.xs),
      itemBuilder: (_, _) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          width: 80,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          ),
        ),
      ),
    );
  }

  Widget _errorRow(WidgetRef ref, String todosLabel) {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingH,
        vertical: AppDimensions.sm,
      ),
      children: [
        _chip(
          label: todosLabel,
          isSelected: selectedValue == null,
          onTap: () => onChanged(null),
        ),
        const SizedBox(width: AppDimensions.xs),
        IconButton(
          icon: const Icon(Icons.refresh, size: 16, color: AppColors.textTertiary),
          onPressed: () => switch (vertical) {
            CategoryVertical.business => ref.invalidate(businessCategoriesProvider),
            CategoryVertical.job => ref.invalidate(jobCategoriesProvider),
            CategoryVertical.event => ref.invalidate(eventCategoriesProvider),
          },
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _chipsRow(
    List<CategoryOption> categories,
    Locale locale,
    String todosLabel,
  ) {
    final extra = (selectedValue != null &&
            !categories.any((c) => c.value == selectedValue))
        ? [CategoryOption(value: selectedValue!, labelEs: selectedValue!)]
        : <CategoryOption>[];
    final chips = [...categories, ...extra];

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingH,
        vertical: AppDimensions.sm,
      ),
      itemCount: chips.length + 1,
      separatorBuilder: (_, _) => const SizedBox(width: AppDimensions.xs),
      itemBuilder: (_, index) {
        if (index == 0) {
          return _chip(
            label: todosLabel,
            isSelected: selectedValue == null,
            onTap: () => onChanged(null),
          );
        }
        final cat = chips[index - 1];
        final isSelected = selectedValue == cat.value;
        return _chip(
          label: cat.label(vertical, locale),
          isSelected: isSelected,
          onTap: () => onChanged(isSelected ? null : cat.value),
        );
      },
    );
  }

  Widget _chip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : AppColors.textSecondary,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary,
      showCheckmark: false,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}
