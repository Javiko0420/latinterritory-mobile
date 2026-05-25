import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latinterritory/core/i18n/app_translations.dart';
import 'package:latinterritory/core/i18n/locale_provider.dart';

/// Retorna la traducción de [key] según el locale actual (watch).
/// Usar dentro del método build() de ConsumerWidget / ConsumerStatefulWidget.
String tr(WidgetRef ref, String key) {
  final locale = ref.watch(localeProvider);
  return AppTranslations.translate(key, locale.languageCode);
}

/// Versión read-only (no reactiva) para callbacks y lógica fuera de build().
String trRead(WidgetRef ref, String key) {
  final locale = ref.read(localeProvider);
  return AppTranslations.translate(key, locale.languageCode);
}
