import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latinterritory/features/categories/data/category_en_labels.dart';

part 'category_option.freezed.dart';

enum CategoryVertical { business, job, event }

extension CategoryVerticalApiKey on CategoryVertical {
  String get apiKey => switch (this) {
        CategoryVertical.business => 'businesses',
        CategoryVertical.job => 'jobs',
        CategoryVertical.event => 'events',
      };
}

@freezed
abstract class CategoryOption with _$CategoryOption {
  const factory CategoryOption({
    required String value,
    required String labelEs,
  }) = _CategoryOption;
}

extension CategoryOptionX on CategoryOption {
  Map<String, dynamic> toJson() => {'value': value, 'labelEs': labelEs};

  String label(CategoryVertical vertical, Locale locale) {
    if (locale.languageCode == 'en') {
      return labelEnFor(vertical.apiKey, value, labelEs);
    }
    return labelEs;
  }
}

/// Looks up [value] in [available]; returns a fallback option that displays
/// the raw value if the category is unknown or not yet synced from the backend.
CategoryOption resolveCategory(String value, List<CategoryOption> available) {
  return available.firstWhere(
    (c) => c.value == value,
    orElse: () => CategoryOption(value: value, labelEs: value),
  );
}
