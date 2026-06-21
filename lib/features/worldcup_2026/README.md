# Mundial 2026 — feature TEMPORAL de campaña

Vista del Mundial 2026 dentro de Deportes: **En vivo**, **Grupos** y **Eliminatorias**.
Todo el código vive aislado aquí (`lib/features/worldcup_2026/`) para poder borrarlo sin rastro.

## Visibilidad / sunset
`worldCupVisibleProvider` resuelve si mostrar la campaña:
1. **Flag remoto (principal)**: `GET /api/sports/worldcup/config` → `{ enabled, sunsetAt }`.
   Visible si `enabled == true && now < sunsetAt`.
2. **Fail-safe (date-guard local)**: si el config falla/timeout/no existe → visible mientras
   `now < kWorldCupSunsetDate` (`DateTime(2026, 7, 20)`, local). Cubre toda la final del 19-jul.
- El "ahora" es inyectable (`clockProvider`) para tests.

## Punto de entrada
`WorldCupEntryBanner` (en `features/sports/ui/sports_screen.dart`) se **auto-oculta** cuando
`worldCupVisible == false`. Abre `WorldCupScreen` con `Navigator.push` (no toca el router).

## Datos (backend Next.js, nunca api-sports directo)
`/api/sports/worldcup/{config,live,standings,rounds,fixtures}`. Base URL por entorno vía `dioProvider`
(`AppConfig.baseUrl`). Live hace polling 15s (con partidos) / 60s (sin) solo mientras la vista está
visible; se pausa en background y se cancela en dispose (provider autoDispose).

## Rollback (20-jul-2026)
1. **Inmediato, sin release**: poner `enabled=false` en `GET /api/sports/worldcup/config`.
2. **Automático**: `sunsetAt` / `kWorldCupSunsetDate` ocultan la campaña el 20-jul.
3. **Borrado definitivo**:
   - Eliminar `lib/features/worldcup_2026/` y `test/features/worldcup_2026/`.
   - En `features/sports/ui/sports_screen.dart`: quitar el import marcado `// TEMPORAL` y la línea
     `const WorldCupEntryBanner(),`.
   - Quitar las claves `worldcup.*` de `core/i18n/app_translations.dart`.
   - La app vuelve a su estado previo sin tocar nada más.

## Dependencia (repo WEB)
`GET /api/sports/worldcup/config` **aún no existe** → crearlo en el backend web. Mientras tanto, la app
funciona solo con el date-guard local (fail-safe).
