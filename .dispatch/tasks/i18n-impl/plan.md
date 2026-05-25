# Implementar i18n completa en latinterritory-mobile

- [ ] FASE 0: Instalar shared_preferences y agregar flutter_localizations al pubspec.yaml
- [ ] FASE 1: Leer todos los archivos de pantallas listados para entender la estructura actual
- [ ] FASE 2: Crear lib/core/i18n/app_translations.dart con el mapa completo ES/EN
- [ ] FASE 3: Crear lib/core/i18n/locale_provider.dart (Riverpod Notifier que persiste con SharedPreferences)
- [ ] FASE 4: Crear lib/core/i18n/tr.dart (helpers tr() y trRead())
- [ ] FASE 5: Actualizar lib/app.dart con locale, supportedLocales y localizationsDelegates
- [ ] FASE 6: Actualizar lib/shared/widgets/lt_main_scaffold.dart — convertir a ConsumerWidget y usar tr() para labels del nav (LEER PRIMERO, NO tocar _LtFloatingNav/_NavTab/_TabItem)
- [ ] FASE 7: Actualizar lib/features/profile/ui/profile_screen.dart — agregar _LanguageTile entre _ProfileMenu y _LogoutButton
- [ ] FASE 8a: Reemplazar textos en home_screen.dart, business_list_screen.dart, business_detail_screen.dart
- [ ] FASE 8b: Reemplazar textos en job_list_screen.dart, job_detail_screen.dart, event_list_screen.dart, event_detail_screen.dart
- [ ] FASE 8c: Reemplazar textos en forum_list_screen.dart, forum_posts_screen.dart, post_comments_screen.dart, post_card.dart (si existe)
- [ ] FASE 8d: Reemplazar textos en weather_screen.dart, sports_screen.dart (si existe), exchange_screen.dart
- [ ] FASE 8e: Reemplazar textos en login_screen.dart, register_screen.dart, forgot_password_screen.dart
- [ ] FASE 8f: Reemplazar textos en create_business_screen.dart, create_event_screen.dart, create_job_screen.dart
- [ ] FASE 8g: Reemplazar textos en edit_profile_screen.dart, change_password_screen.dart
- [ ] FASE 9: Ejecutar dart analyze lib/ y corregir TODOS los errores (los info son opcionales)
- [ ] Escribir resumen de cambios en .dispatch/tasks/i18n-impl/output.md
