# Release Notes — LatinTerritory Mobile

## 1.1.0 (build 5) — 2026-07-09

Cambios desde 1.0.1+4 (2026-06-14):

### Novedades
- **Nuevo diseño "Latin Territory"**: migración completa al design system — tipografía Hanken Grotesk, acento gold, dark theme night-blue y navegación con efecto glass.
- **Mundial 2026** (sección temporal en Deportes): partidos en vivo, fase de grupos y eliminatorias. Se oculta automáticamente vía flag remoto + date-guard (20-jul-2026).
- **Foro del día en Home**: widget con el foro destacado de la comunidad entre las secciones de eventos y radio; se oculta si no hay foro activo. Textos en ES/EN.

### Mejoras y correcciones
- MiniPlayer de radio migrado al design system: superficie glass (como el bottom nav), acento coral (identidad de radio), tokens `LTColors` con soporte completo de tema claro/oscuro. También el sheet de estaciones.
- Token `onGreen` y semántica de botón en `LtPressable` (accesibilidad).
- Fix de estado tras dispose en el widget del Mundial en Home.
- Uso de `AsyncValue.value` (Riverpod 3) en widgets de foros.
- Pulido final de widgets de foros tras code review.

### Verificación pre-release
- Tests: 72/72 pasando.
- `flutter analyze`: 106 issues (igual al baseline, sin regresiones).
- Sin secrets en el diff del release.

---

## Store "What's New" (para copiar/pegar)

### Español (≤500 caracteres, Play Store / App Store)
```
¡LatinTerritory se renueva!

• Nuevo diseño: colores, tipografía y navegación completamente renovados
• Mundial 2026: sigue los partidos en vivo, grupos y eliminatorias en Deportes
• Foro del día: descubre la conversación destacada de la comunidad desde el inicio
• Mejoras de accesibilidad y correcciones menores
```

### English (≤500 characters)
```
LatinTerritory gets a fresh new look!

• New design: fully refreshed colors, typography and navigation
• World Cup 2026: follow live matches, groups and knockouts in Sports
• Forum of the day: discover the community's featured conversation right from Home
• Accessibility improvements and minor fixes
```

---

## Historial

### 1.0.1 (build 4) — 2026-06-14
- Fix de freeze en splash por R8/ProGuard en Android (clases de audio).
- Fix de audio en background y arranque en Android con `just_audio_background`.
- `versionCode`/`versionName` leídos desde `pubspec.yaml`.

### 1.0.1 (build 3) — 2026-06-13
- Nuevo train de versión en App Store Connect.
- Reproducción de radio en background al bloquear pantalla.
- Sincronización de categorías con backend como fuente de verdad.
- Manejo de todos los formatos de error del backend (incl. arrays de Zod).

### 1.0.0 (builds 1-2) — release inicial
- Sign in with Apple, flujo de borrado de cuenta, radio en background con controles en lock screen, clave de export compliance (iOS).
