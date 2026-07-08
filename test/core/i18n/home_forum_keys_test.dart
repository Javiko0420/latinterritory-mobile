import 'package:flutter_test/flutter_test.dart';
import 'package:latinterritory/core/i18n/app_translations.dart';

void main() {
  const keys = [
    'home.eyebrow_community',
    'home.forum_of_day',
    'home.see_forums',
    'home.forum_topic_of_day',
    'home.forum_join',
  ];

  test('claves del foro del día existen en es y en', () {
    for (final key in keys) {
      for (final locale in ['es', 'en']) {
        final value = AppTranslations.translate(key, locale);
        // translate() devuelve la clave misma cuando no existe.
        expect(value, isNot(equals(key)), reason: '$key falta en "$locale"');
        expect(value, isNotEmpty);
      }
    }
  });

  test('es y en tienen textos distintos para claves traducibles', () {
    expect(
      AppTranslations.translate('home.forum_of_day', 'es'),
      isNot(equals(AppTranslations.translate('home.forum_of_day', 'en'))),
    );
  });
}
