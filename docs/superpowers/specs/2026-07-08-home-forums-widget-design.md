# Design: Widget "Foro del día" en el home

**Fecha:** 2026-07-08
**Estado:** Aprobado por el usuario (pendiente de plan de implementación)

## Objetivo

Dar visibilidad a la sección de foros desde el home con una card del "foro del día",
reutilizando la feature de foros existente sin cambios de lógica. Solo presentación,
siguiendo el mismo enfoque de la migración al design system.

## Decisiones tomadas

| Decisión | Elección |
|---|---|
| Contenido | Foro del día: nombre, descripción, nº de posts y CTA "Participar" |
| Ubicación | Entre "Eventos próximos" (`_EventsFeatured`) y la card de Radio (`_RadioCard`) |
| Estado vacío/error/loading | Ocultar la sección por completo (`SizedBox.shrink()`) |
| Forma visual | Sección con `LtSectionHeader` + card estándar (patrón del home) |

## Componente

- **Archivo nuevo:** `lib/features/forums/ui/lt_forum_widget.dart`
- **Clase:** `LTForumWidget` (`ConsumerWidget`), mismo patrón de naming que
  `LTSportsWidget` / `LTWeatherWidget`.
- Renderiza la **sección completa** (header + card + spacing inferior) o
  `SizedBox.shrink()`. El header nunca queda huérfano sin contenido.
- Cambio en `home_screen.dart`: insertar `const LTForumWidget()` entre la sección
  de eventos y la card de radio. Ningún otro cambio en el home.
- Cero cambios en `ForumRepository`, providers o rutas.

## UI de la card

Tokens del design system existentes (`context.lt`, `LTType`, `LTSpace`, `LTRadius`):

- `LtSectionHeader`: eyebrow "Comunidad", título "Foro del día", acento `c.green`,
  acción "Ver foros" → `context.go('/forums')`.
- Card: fondo `c.card`, borde `c.line`, radio `LTRadius.lg`, sombra `c.softShadow`.
  - Chip con icono `Icons.forum_outlined` en `c.green` sobre fondo `c.greenSoft`.
  - Eyebrow "Tema del día" (`LTType.eyebrow`).
  - Título: `forum.name`, `LTType.card`, máx. 2 líneas con ellipsis.
  - Descripción: `forum.description`, `LTType.caption` en `c.ink2`, máx. 2 líneas
    con ellipsis.
  - Footer: a la izquierda `postsCount` con formato "N posts"; a la derecha botón
    pill "Participar" (fondo `c.green`, texto en contraste).
- Card completa presionable con `LtPressable`.

Mockup aprobado:

```
COMUNIDAD                    Ver foros →
Foro del día

┌────────────────────────────────┐
│ 💬  TEMA DEL DÍA               │
│                                │
│ ¿Cómo encontrar vivienda       │
│ sin historial crediticio?      │
│ Comparte tu experiencia y      │
│ aprende de la comunidad…       │
│                                │
│ 🔥 24 posts    [ Participar → ]│
└────────────────────────────────┘
```

## Data flow y estados

- Observa `forumsProvider` (existente, `FutureProvider.autoDispose<List<Forum>>`).
- Selecciona el **primer foro con `isActive == true`** de la lista.
- Estados:
  - `loading` → `SizedBox.shrink()`
  - `error` → `SizedBox.shrink()`
  - lista vacía o sin foros activos → `SizedBox.shrink()`
  - foro activo → sección completa
- Trade-off aceptado: la sección "aparece" cuando cargan los datos (pequeño layout
  shift), a cambio de un home sin loaders ni cards de error para una feature
  secundaria. Es el mismo patrón del widget del Mundial 2026.

## Navegación

- Tap en la card o en "Participar" →
  `context.pushNamed(RouteNames.forumDetail, pathParameters: {'id': forum.id}, extra: forum)`.
  La ruta `/forums/:id` ya espera el objeto `Forum` como `state.extra`.
- "Ver foros" en el header → `context.go('/forums')`.

## i18n

Claves nuevas en `lib/core/i18n/app_translations.dart`, en español e inglés:

| Clave | es | en |
|---|---|---|
| `home.eyebrow_community` | Comunidad | Community |
| `home.forum_of_day` | Foro del día | Forum of the day |
| `home.see_forums` | Ver foros | See forums |
| `home.forum_topic_of_day` | Tema del día | Topic of the day |
| `home.forum_join` | Participar | Join in |
| `home.forum_posts_label` | posts | posts |

Nota: `tr()` no soporta interpolación (recibe solo la clave), así que el contador
se construye por concatenación: `'${forum.postsCount} ${tr(ref, 'home.forum_posts_label')}'`.

## Testing

`test/features/forums/lt_forum_widget_test.dart`, siguiendo el patrón de
`test/features/worldcup_2026/visibility_test.dart` (override de providers):

1. Con un foro activo → renderiza nombre del foro y CTA "Participar".
2. Con lista vacía → no renderiza nada (`SizedBox.shrink`).
3. Con solo foros inactivos (`isActive == false`) → no renderiza nada.
4. En estado de error del provider → no renderiza nada.

## Fuera de alcance

- Mostrar posts o actividad reciente dentro de la card.
- Cambios en backend, repositorio, providers o rutas.
- Animación de entrada de la sección.
