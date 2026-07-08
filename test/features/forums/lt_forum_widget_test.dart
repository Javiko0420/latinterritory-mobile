import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latinterritory/core/extensions/async_value_extensions.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/features/forums/data/models/forum_models.dart';
import 'package:latinterritory/features/forums/providers/forum_providers.dart';
import 'package:latinterritory/features/forums/ui/lt_forum_widget.dart';
import 'package:riverpod/src/framework.dart';
import 'package:shared_preferences/shared_preferences.dart';

Forum _forum({bool isActive = true}) => Forum(
      id: 'f1',
      name: 'Vivienda sin historial crediticio',
      description: 'Comparte tu experiencia con la comunidad',
      slug: 'vivienda',
      topic: 'housing',
      startDate: DateTime(2026, 7, 8),
      endDate: DateTime(2026, 7, 9),
      isActive: isActive,
      postsCount: 24,
    );

Widget _app(List<Override> overrides) => ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: ThemeData(extensions: const [LTColors.light]),
        home: const Scaffold(
          body: SingleChildScrollView(child: LTForumWidget()),
        ),
      ),
    );

void main() {
  setUpAll(() {
    // Evita fetch de fuentes en tests (google_fonts).
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    // localeProvider lee SharedPreferences al inicializarse.
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('con foro activo renderiza sección, nombre, contador y CTA',
      (tester) async {
    await tester.pumpWidget(_app([
      forumsProvider.overrideWith((ref) async => [_forum()]),
    ]));
    await tester.pump(); // resuelve el FutureProvider

    expect(find.text('Foro del día'), findsOneWidget);
    expect(find.text('Vivienda sin historial crediticio'), findsOneWidget);
    expect(find.text('24 posts'), findsOneWidget);
    expect(find.text('Participar'), findsOneWidget);
  });

  testWidgets('con lista vacía no renderiza nada', (tester) async {
    await tester.pumpWidget(_app([
      forumsProvider.overrideWith((ref) async => <Forum>[]),
    ]));
    await tester.pump();

    expect(find.text('Foro del día'), findsNothing);
    expect(find.text('Participar'), findsNothing);
  });

  testWidgets('con solo foros inactivos no renderiza nada', (tester) async {
    await tester.pumpWidget(_app([
      forumsProvider.overrideWith((ref) async => [_forum(isActive: false)]),
    ]));
    await tester.pump();

    expect(find.text('Foro del día'), findsNothing);
  });

  testWidgets('con error del provider no renderiza nada', (tester) async {
    await tester.pumpWidget(_app([
      forumsProvider.overrideWith(
        (ref) async => throw Exception('network down'),
      ),
    ]));
    await tester.pump();

    expect(find.text('Foro del día'), findsNothing);
  });
}
