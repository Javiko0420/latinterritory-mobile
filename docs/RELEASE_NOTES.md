# Release Notes — LatinTerritory Mobile

## 1.1.0 (build 7) — 2026-07-09

> Build 5 y 6 quedaron quemados: App Store Connect ya tenía un build "6"
> registrado (subidas previas del train 1.0.1 no reflejadas en el repo), y
> exige que el bundle version sea siempre mayor al último subido.

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

### Español (389/500 caracteres, Play Store / App Store)
```
¡LatinTerritory se renueva!

• Nuevo diseño: colores, tipografía y navegación renovados, con tema claro y oscuro
• Mundial 2026: sigue los partidos en vivo, grupos y eliminatorias en Deportes
• Foro del día: la conversación destacada de la comunidad, directo en el inicio
• Reproductor de radio flotante renovado, adaptado al nuevo diseño
• Mejoras de accesibilidad y correcciones menores
```

### English (370/500 characters)
```
LatinTerritory gets a fresh new look!

• New design: refreshed colors, typography and navigation, with light and dark themes
• World Cup 2026: follow live matches, groups and knockouts in Sports
• Forum of the day: the community's featured conversation right on Home
• Redesigned floating radio player, matching the new look
• Accessibility improvements and minor fixes
```

---

## App Store "Novedades" (límite 4000 caracteres — versión extendida)

### Español
```
¡LatinTerritory se renueva!

NUEVO DISEÑO
La app estrena una imagen completamente renovada: nueva tipografía, colores y navegación, con tema claro y oscuro que se adapta a tu preferencia.

MUNDIAL 2026
Vive el Mundial desde la sección Deportes: partidos en vivo, fase de grupos y eliminatorias.

FORO DEL DÍA
La conversación destacada de la comunidad ahora te espera directo en el inicio.

RADIO
El reproductor flotante de radio se adaptó al nuevo diseño y luce increíble en ambos temas.

Además, esta versión incluye mejoras de accesibilidad y correcciones menores.

¿Te gusta la nueva imagen? Déjanos una reseña — nos ayuda muchísimo a seguir creciendo. 🌎
```

### English
```
LatinTerritory gets a fresh new look!

NEW DESIGN
The app debuts a fully refreshed look: new typography, colors and navigation, with light and dark themes that adapt to your preference.

WORLD CUP 2026
Experience the World Cup from the Sports section: live matches, group stage and knockouts.

FORUM OF THE DAY
The community's featured conversation now greets you right on Home.

RADIO
The floating radio player was redesigned to match the new look, and it shines in both themes.

This version also includes accessibility improvements and minor fixes.

Enjoying the new look? Leave us a review — it helps us keep growing. 🌎
```

---

## App Review Notes (App Store Connect → App Review Information → Notes)

> Recordatorio: crear una cuenta demo real y ponerla en los campos "Sign-In
> Information" (marcar el checkbox "Sign-in required").

```
Thank you for reviewing LatinTerritory 1.1.0.

ABOUT THE APP
LatinTerritory is a community platform for Latinos living in Australia: a business directory, job listings, community events, forums, live Latin radio, weather and currency exchange rates. The app is available in Spanish and English.

WHAT'S NEW IN 1.1.0
- Complete visual redesign: new typography, colors and navigation, with light and dark themes.
- Temporary "World Cup 2026" section under Sports (live scores, group stage, knockout bracket). It is informational only and will be remotely disabled once the tournament ends.
- New "Forum of the day" widget on the Home screen.
- Redesigned floating radio mini player.

ACCOUNT & LOGIN
- Most content can be browsed WITHOUT an account: Home, Businesses, Jobs, Events, Weather, Exchange Rates, Sports and Radio.
- An account is only required to participate in Forums and to publish businesses, events or job listings.
- Sign in with Apple is supported, in addition to email/password.
- A demo account is provided in the App Review Information fields.
- Account deletion is available in-app: Profile → Delete Account.

LOCATION PERMISSION
The app only requests "While Using the App" location access, used to show local weather and nearby businesses/events. The NSLocationAlwaysAndWhenInUseUsageDescription key is present solely because our location SDK (geolocator) statically references that API; the app never requests "Always" authorization.

BACKGROUND AUDIO
The Radio feature streams live Latin radio stations and continues playing in the background (UIBackgroundModes: audio). To test: open Radio, play a station, then lock the device — playback continues and playback controls appear on the lock screen.

USER-GENERATED CONTENT
Forum posts and comments can be reported in-app by authenticated users (report option on each post/comment), and publishing any content requires an account.

If you have any questions, please contact us through the support information provided. Thank you!
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
