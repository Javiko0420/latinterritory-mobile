import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/features/forums/data/models/forum_models.dart';
import 'package:latinterritory/features/forums/providers/forum_providers.dart';
import 'package:latinterritory/features/forums/ui/forum_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Forum _forum() => Forum(
      id: 'f1',
      name: 'Vivienda sin historial crediticio',
      description: 'Comparte tu experiencia con la comunidad',
      slug: 'vivienda',
      topic: 'housing',
      startDate: DateTime(2026, 7, 8),
      endDate: DateTime(2026, 7, 9),
      postsCount: 24,
    );

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('el contador de posts usa la clave i18n forums.posts',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        forumsProvider.overrideWith((ref) async => [_forum()]),
      ],
      child: MaterialApp(
        theme: ThemeData(extensions: const [LTColors.light]),
        home: const ForumListScreen(),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('publicaciones'), findsNothing);
    expect(find.textContaining('24 posts'), findsOneWidget);
  });
}
