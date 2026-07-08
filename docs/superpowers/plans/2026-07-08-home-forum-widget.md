# Home "Foro del día" Widget Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Sección "Foro del día" en el home que muestra el primer foro activo con CTA para participar, y desaparece por completo cuando no hay datos.

**Architecture:** Un único widget autocontenido `LTForumWidget` (ConsumerWidget) que observa el `forumsProvider` existente y renderiza header + card, o `SizedBox.shrink()`. Solo presentación: cero cambios en repositorio, providers o rutas. Spec aprobado: `docs/superpowers/specs/2026-07-08-home-forums-widget-design.md`.

**Tech Stack:** Flutter, Riverpod (`flutter_riverpod`), go_router, freezed models existentes, design system Latin Territory (`LTColors`/`LTType`/`LTSpace`/`LTRadius`).

## Global Constraints

- Solo presentación: NO modificar `ForumRepository`, `forum_providers.dart`, rutas ni backend.
- `const` constructors siempre que sea posible.
- `tr()` NO soporta interpolación: el contador se construye por concatenación `'${forum.postsCount} ${tr(ref, 'forums.posts')}'` (la clave `forums.posts` ya existe en es/en).
- Acento de la sección: `c.green` / `c.greenSoft` (mismo acento que el shortcut de foros del home).
- Estados loading / error / lista vacía / sin foros activos → `SizedBox.shrink()` (sin loaders ni cards de error).
- Claves i18n nuevas (verbatim, es/en): `home.eyebrow_community` (Comunidad/Community), `home.forum_of_day` (Foro del día/Forum of the day), `home.see_forums` (Ver foros/See forums), `home.forum_topic_of_day` (Tema del día/Topic of the day), `home.forum_join` (Participar/Join in).
- Commits: mensaje en inglés + footer:
  ```
  Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
  Claude-Session: https://claude.ai/code/session_01BQMEEQ5J4mq7nwik5dXkmz
  ```

---

### Task 1: Claves i18n del foro del día

**Files:**
- Modify: `lib/core/i18n/app_translations.dart` (bloque `'es'` tras la línea 60 `'home.see_agenda'`; bloque `'en'` tras la línea 342 `'home.see_agenda'`)
- Test: `test/core/i18n/home_forum_keys_test.dart` (nuevo)

**Interfaces:**
- Consumes: `AppTranslations.translate(String key, String locale)` — fallback: locale → es → devuelve la clave misma.
- Produces: las 5 claves `home.eyebrow_community`, `home.forum_of_day`, `home.see_forums`, `home.forum_topic_of_day`, `home.forum_join` resolubles en `es` y `en`. Task 2 las consume vía `tr(ref, key)`.

- [ ] **Step 1: Write the failing test**

Crear `test/core/i18n/home_forum_keys_test.dart`:

```dart
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/i18n/home_forum_keys_test.dart`
Expected: FAIL — `home.eyebrow_community falta en "es"` (translate devuelve la clave).

- [ ] **Step 3: Add the keys**

En `lib/core/i18n/app_translations.dart`, bloque `'es'`, inmediatamente después de `'home.see_agenda': 'Ver agenda',` (línea 60):

```dart
      'home.eyebrow_community': 'Comunidad',
      'home.forum_of_day': 'Foro del día',
      'home.see_forums': 'Ver foros',
      'home.forum_topic_of_day': 'Tema del día',
      'home.forum_join': 'Participar',
```

En el bloque `'en'`, inmediatamente después de `'home.see_agenda': 'See agenda',` (línea ~342, se desplaza +5 tras el edit anterior):

```dart
      'home.eyebrow_community': 'Community',
      'home.forum_of_day': 'Forum of the day',
      'home.see_forums': 'See forums',
      'home.forum_topic_of_day': 'Topic of the day',
      'home.forum_join': 'Join in',
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/i18n/home_forum_keys_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/core/i18n/app_translations.dart test/core/i18n/home_forum_keys_test.dart
git commit -m "$(cat <<'EOF'
feat(i18n): add home forum-of-the-day keys (es/en)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01BQMEEQ5J4mq7nwik5dXkmz
EOF
)"
```

---

### Task 2: Widget `LTForumWidget`

**Files:**
- Create: `lib/features/forums/ui/lt_forum_widget.dart`
- Test: `test/features/forums/lt_forum_widget_test.dart` (nuevo)

**Interfaces:**
- Consumes: `forumsProvider` (`FutureProvider.autoDispose<List<Forum>>` de `lib/features/forums/providers/forum_providers.dart`); modelo `Forum` (campos `id`, `name`, `description`, `slug`, `topic`, `startDate`, `endDate`, `isActive`, `postsCount`); claves i18n de Task 1; `LtSectionHeader(eyebrow:, title:, accent:, actionLabel:, onAction:)`; `LtPressable(onTap:, child:)`; tokens `context.lt` y `LTType`; `RouteNames.forumDetail` (ruta `/forums/:id`, espera `Forum` como `extra`).
- Produces: `class LTForumWidget extends ConsumerWidget` con constructor `const LTForumWidget({super.key})`, exportado desde `package:latinterritory/features/forums/ui/lt_forum_widget.dart`. Task 3 lo inserta en el home.

- [ ] **Step 1: Write the failing tests**

Crear `test/features/forums/lt_forum_widget_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/features/forums/data/models/forum_models.dart';
import 'package:latinterritory/features/forums/providers/forum_providers.dart';
import 'package:latinterritory/features/forums/ui/lt_forum_widget.dart';
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
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/features/forums/lt_forum_widget_test.dart`
Expected: FAIL en compilación — `Error: Couldn't resolve the package ... lt_forum_widget.dart` (el archivo no existe todavía).

- [ ] **Step 3: Implement the widget**

Crear `lib/features/forums/ui/lt_forum_widget.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latinterritory/core/i18n/tr.dart';
import 'package:latinterritory/core/routing/route_names.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';
import 'package:latinterritory/core/theme/lt_typography.dart';
import 'package:latinterritory/features/forums/data/models/forum_models.dart';
import 'package:latinterritory/features/forums/providers/forum_providers.dart';
import 'package:latinterritory/shared/widgets/lt_pressable.dart';
import 'package:latinterritory/shared/widgets/lt_section_header.dart';

/// Sección "Foro del día" del home — design system "Latin Territory".
///
/// Solo presentación: observa [forumsProvider] (foros activos de hoy) y
/// muestra el primero con `isActive == true`. En loading, error o sin foros
/// activos no renderiza nada: la sección desaparece del home.
class LTForumWidget extends ConsumerWidget {
  const LTForumWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    final forums = ref.watch(forumsProvider).valueOrNull ?? const <Forum>[];
    final active = forums.where((f) => f.isActive).toList();
    if (active.isEmpty) return const SizedBox.shrink();
    final forum = active.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LtSectionHeader(
          eyebrow: tr(ref, 'home.eyebrow_community'),
          title: tr(ref, 'home.forum_of_day'),
          accent: c.green,
          actionLabel: tr(ref, 'home.see_forums'),
          onAction: () => context.go('/forums'),
        ),
        const SizedBox(height: 14),
        _ForumCard(forum: forum),
        // Spacing propio: al ocultarse la sección no deja hueco doble.
        const SizedBox(height: 24),
      ],
    );
  }
}

class _ForumCard extends ConsumerWidget {
  const _ForumCard({required this.forum});

  final Forum forum;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    return LtPressable(
      onTap: () => context.pushNamed(
        RouteNames.forumDetail,
        pathParameters: {'id': forum.id},
        extra: forum,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(LTRadius.lg),
          border: Border.all(color: c.line),
          boxShadow: c.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: c.greenSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.forum_outlined, color: c.green, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr(ref, 'home.forum_topic_of_day').toUpperCase(),
                        style: LTType.eyebrow(c.green),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        forum.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: LTType.card(c.ink),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              forum.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: LTType.caption(c.ink2, size: 13),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  '${forum.postsCount} ${tr(ref, 'forums.posts')}',
                  style: LTType.caption(c.ink2, size: 13, weight: FontWeight.w600),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: c.green,
                    borderRadius: BorderRadius.circular(LTRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tr(ref, 'home.forum_join'),
                        style: LTType.caption(
                          Colors.white,
                          size: 13,
                          weight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward,
                          size: 14, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/features/forums/lt_forum_widget_test.dart`
Expected: PASS (4 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/features/forums/ui/lt_forum_widget.dart test/features/forums/lt_forum_widget_test.dart
git commit -m "$(cat <<'EOF'
feat(forums): add home forum-of-the-day widget

Self-contained section that hides entirely when no active forum,
keeping the home free of loaders/error cards for a secondary feature.

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01BQMEEQ5J4mq7nwik5dXkmz
EOF
)"
```

---

### Task 3: Integrar en el home

**Files:**
- Modify: `lib/features/home/ui/home_screen.dart` (imports ~línea 16 y children del ListView ~líneas 151-155)

**Interfaces:**
- Consumes: `const LTForumWidget()` de Task 2.
- Produces: sección visible en el home entre "Eventos próximos" y la card de Radio.

- [ ] **Step 1: Add the import**

En `lib/features/home/ui/home_screen.dart`, después de `import 'package:latinterritory/features/exchange/ui/lt_exchange_rate_widget.dart';`:

```dart
import 'package:latinterritory/features/forums/ui/lt_forum_widget.dart';
```

(Queda ordenado alfabéticamente: exchange → forums → jobs.)

- [ ] **Step 2: Insert the widget**

En el `ListView` del `build`, localizar:

```dart
              const _EventsFeatured(),
              const SizedBox(height: 24),

              // ── Radio ───────────────────────────────────────
              const _RadioCard(),
```

y reemplazar por:

```dart
              const _EventsFeatured(),
              const SizedBox(height: 24),

              // ── Foro del día ────────────────────────────────
              const LTForumWidget(),

              // ── Radio ───────────────────────────────────────
              const _RadioCard(),
```

Nota: `LTForumWidget` trae su propio spacing inferior (24) cuando es visible; oculto, el layout queda idéntico al actual.

- [ ] **Step 3: Analyze and run full test suite**

Run: `flutter analyze && flutter test`
Expected: `No issues found!` y todos los tests PASS (incluidos los de worldcup_2026, categories y auth existentes).

- [ ] **Step 4: Commit**

```bash
git add lib/features/home/ui/home_screen.dart
git commit -m "$(cat <<'EOF'
feat(home): show forum-of-the-day section between events and radio

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01BQMEEQ5J4mq7nwik5dXkmz
EOF
)"
```

---

## Verificación final (manual)

- `flutter run` y revisar el home: con un foro activo en el backend aparece la sección con acento verde entre eventos y radio; tap en la card navega a los posts del foro; "Ver foros" navega al listado.
- Cambiar idioma a inglés en el perfil y verificar los textos ("Forum of the day", "Join in").
