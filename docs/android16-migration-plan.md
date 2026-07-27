# Migración Android 16 (API 36) — latinterritory-mobile

> Rama: `chore/android-16-api-36` · Deadline Play: **31-ago-2026** · Estado: plan aprobado, ejecución pendiente

## Contexto

Google Play exige que la app apunte a Android 16 (API 36) antes del 31-ago-2026. Hoy apunta a `targetSdk 35`. Android está en closed testing; iOS está live en App Store.

**Hallazgo central del discovery:** con Flutter 3.44.5, `compileSdk`/`minSdk`/`ndkVersion` se delegan al SDK de Flutter, cuyos defaults ya son **36 / 24 / 28.2.13676358** — la app **ya compila contra SDK 36** y el toolchain (AGP 8.11.1, Gradle 8.14, Kotlin 2.2.20, JDK 17) es compatible con API 36 sin cambios. El único valor rezagado es `targetSdk = 35` en `android/app/build.gradle.kts:34`.

**Regla de esta rama:** el AAB bajo prueba contiene exactamente UNA variable (el salto a API 36). Cero upgrades de dependencias aquí — movidos a la rama follow-up `chore/deps-post-api36`.

## Baseline (verificado 27-jul-2026)

- Rama `main` limpia y sincronizada con `origin/main`. Sin tags (convención del repo).
- Versión: **1.1.0+7** (`pubspec.yaml`; Android lee versionCode/versionName desde ahí).
- Valores efectivos hoy (defaults del Flutter SDK): `compileSdk = 36`, `minSdk = 24`, `ndk = 28.2.13676358`.
- `key.properties` / `upload-keystore.jks` no trackeados en git (correcto).
- Flutter 3.44.5 stable / Dart 3.12.2.
- `ANDROID_HOME=~/Library/Android/sdk` (verificado); AVD phone API 36 existente: `Medium_Phone_API_36.1`.

## Fase 0 — Rama de seguridad ✅

```bash
git checkout main && git pull
git checkout -b chore/android-16-api-36
```

Racional: la migración toca Gradle, toolchain y manifest; sin rama aislada el rollback es doloroso. Todo se commitea en esta rama; nada se pushea ni mergea hasta validar el build de closed testing.

**Rollback de toda la migración:** `git checkout main && git branch -D chore/android-16-api-36`

- [x] Rama creada
- [x] Este documento commiteado (`docs(android): add Android 16 (API 36) migration plan`)

## Fase 1 — SDKs explícitos + targetSdk 36

Archivo: `android/app/build.gradle.kts` (líneas 19, 33, 34).

| Antes | Después | Por qué |
|---|---|---|
| `compileSdk = flutter.compileSdkVersion` | `compileSdk = 36` | Pin explícito: un `flutter upgrade` futuro no debe cambiarlo silenciosamente (valor efectivo actual: 36 — sin cambio real). |
| `minSdk = flutter.minSdkVersion` | `minSdk = 24` | Ídem: subir minSdk silenciosamente expulsaría dispositivos de testers (valor efectivo actual: 24 — sin cambio real). |
| `targetSdk = 35` | `targetSdk = 36` | Requisito de Play; explícito por la misma razón. |

`ndkVersion = flutter.ndkVersion` se deja delegado a propósito: la app no tiene código nativo propio y el engine de Flutter llega precompilado.

- Riesgo: **bajo** (compileSdk ya es 36; el delta real es solo targetSdk).
- Verificar: `flutter build apk --debug` + smoke en emulador API 36.
- Rollback: revert del commit.

- [ ] Cambios aplicados
- [ ] Build debug OK
- [ ] Commit: `chore(android): target API 36, pin compile/min SDK`

## Fase 2 — Resiliencia del MiniPlayer en pantallas grandes (B3, ejecutable)

**Problema:** en tablets/foldables con API 36 el lock a portrait de `main.dart:18` se ignora → rotación y split-screen posibles. El offset draggable del MiniPlayer vive en estado Riverpod (`radio_player_provider.dart:15,147` — no persistido a disco, pero estable durante la sesión), con default `Offset(16, 600)` (`:24`) y posición calculada una sola vez al expandir (`:115-117`). El drag se clampea contra constantes hardcodeadas `kTopSafeArea = 50` / `kNavBarMargin = 96` (`lt_radio_mini_player.dart:15-16`). Si el tamaño disponible cambia, un offset válido puede quedar fuera de pantalla y el control se vuelve inalcanzable.

**Cambios:**

1. **Re-clamp al cambiar el tamaño** — `lib/features/radio/ui/lt_radio_mini_player.dart`. El clamp se aplica a una **variable local** que posiciona el widget; **nunca se muta el estado Riverpod dentro de `build()`** (lanza excepción / provoca rebuild loops). El estado persistido queda como está y se auto-corrige en el próximo `onPanUpdate`. Forma prevista del código:

   ```dart
   // build() — clamp SOLO en variable local; nunca mutar estado Riverpod aquí.
   final screen = MediaQuery.sizeOf(context);
   final vp = MediaQuery.viewPaddingOf(context);
   final maxY = screen.height - kPlayerHeight - kNavBarMargin - vp.bottom;
   final pos = Offset(
     state.position.dx.clamp(0.0, screen.width - kPlayerWidth),
     state.position.dy.clamp(vp.top + 8, maxY),
   );
   return Positioned(left: pos.dx, top: pos.dy, child: /* player */);

   // Solo si se decide persistir la corrección (opcional):
   // WidgetsBinding.instance.addPostFrameCallback((_) {
   //   if (pos != state.position) notifier.updatePosition(pos);
   // }); // nunca inline en build()
   ```

   `build()` se re-ejecuta en cada cambio de métricas porque depende de `MediaQuery`, así que no hace falta `WidgetsBindingObserver`. El mismo clamp se aplica al calcular la posición al expandir (`radio_player_provider.dart:115-117`).

2. **Safe areas derivadas de MediaQuery** — reemplazar `kTopSafeArea = 50` por `MediaQuery.viewPaddingOf(context).top + margen` y sumar `viewPadding.bottom` al límite inferior. `kNavBarMargin = 96` se mantiene como constante: es la reserva de diseño del bottom nav, no un inset del sistema.

**Nota de alcance:** esto toca Dart compartido — lo exige estrictamente el behaviour change B3. Es neutral para iOS y mejora iPad; por eso V8 incluye smoke tests iOS.

- Riesgo: **medio** (lógica de posicionamiento). Rollback: revert del commit.
- Verificar: `flutter test` + rotar emulador tablet con radio sonando; el player permanece visible y arrastrable.

- [ ] Re-clamp local en build
- [ ] Safe areas desde MediaQuery
- [ ] Tests verdes
- [ ] Commit: `fix(radio): re-clamp mini player offset on metrics change, derive safe areas from MediaQuery`

**Regla de decisión (contingencia B3):** si el smoke test de tablet/foldable falla igualmente → aplicar en `<application>` del manifest:

```xml
<property android:name="android.window.PROPERTY_COMPAT_ALLOW_RESTRICTED_RESIZABILITY" android:value="true"/>
```

y **shippear de todos modos** — no se retrasa el release; los layouts se arreglan en un ciclo posterior. Caveat: el opt-out es temporal y desaparece en API 37 (2027).

## Fase 3 — Auditoría de behaviour changes API 36

- [ ] **B1 · Edge-to-edge obligatorio → YA ACTIVO.** Ningún `styles.xml` usa `windowOptOutEdgeToEdgeEnforcement`; desde targetSdk 35 los testers ya ven la app edge-to-edge — API 36 solo elimina un opt-out que no usamos. Insets bien manejados: bottom nav en `SafeArea(top:false)` + `Positioned(bottom:12)` (`lt_main_scaffold.dart:66`, reserva de 96px en `:31`); 29 archivos con `SafeArea`; manifest `adjustResize`. El riesgo residual de cutouts lo resuelve la Fase 2.
- [ ] **B2 · Predictive back → no afectado.** Cero `WillPopScope`/`PopScope`/`BackButtonListener`/`onPopInvoked` en `lib/`; GoRouter sin interceptores; solo `Navigator.maybePop` (`publish_screen.dart:39`, `world_cup_screen.dart:33`), compatible. Verificar animación en V8.
- [ ] **B3 · Orientación/resizability ignoradas en sw≥600dp → resuelto en Fase 2** + regla de decisión con opt-out.
- [ ] **B4 · Intent hardening / matching estricto → no afectado.** Sin deep links ni schemes custom (solo MAIN/LAUNCHER + MEDIA_BUTTON + MediaBrowserService); `google_sign_in` 7.x usa Credential Manager, sin redirect activities (R8 cubierto en `proguard-rules.pro:27-30`); Apple Sign-In gated a iOS (`login_screen.dart:250`).
- [ ] **B5 · FGS/JobScheduler para radio → bajo.** Servicio tipado `mediaPlayback` + permiso `FOREGROUND_SERVICE_MEDIA_PLAYBACK` (manifest:5,45); playback con MediaSession activa exento de quotas. Verificar radio + lock screen + kill/restore en V8.
- [ ] **B6 · elegantTextHeight / métricas → mínimo.** Hanken Grotesk (script latino); cubierto por revisión visual.
- [ ] **B7 · 16 KB page size → ya cumplido.** Play lo exige desde nov-2025 para targetSdk ≥35 y 1.1.0+7 ya está en closed testing; ningún plugin del lockfile embebe `.so` propios (todos Java/Kotlin) — solo `libflutter.so`/`libapp.so`, alineados por Flutter ≥3.27 / AGP ≥8.5.1. Se verifica igual en V7.
- [ ] **B8 · APIs de color de system bars deprecadas → no-ops inofensivos, sin cambio de código.** En API 36, `Window.setStatusBarColor()`/`setNavigationBarColor()`/`setNavigationBarDividerColor()` son no-ops silenciosos. Inventario completo:

  | Hit | Clasificación |
  |---|---|
  | `lib/main.dart:24` `SystemChrome.setSystemUIOverlayStyle(` | llamada contenedora |
  | `lib/main.dart:26` `statusBarColor: Colors.transparent` | **no-op en 36**, inofensivo: transparente es lo que el edge-to-edge impone; sigue actuando en dispositivos ≤ API 34 → se conserva |
  | `lib/main.dart:27-28` `statusBarIconBrightness`/`statusBarBrightness` | **sigue funcionando** (solo los campos de color están muertos) |
  | `systemNavigationBarColor`, `systemOverlayStyle` (AppBarTheme) en `lib/` | cero hits |
  | `android:statusBarColor`/`navigationBarColor` en `values*/styles.xml` | cero hits |

  El diseño no exige barras de color sólido (todo transparente/glass) → no se necesita reemplazo. Patrón documentado por si un diseño futuro lo pide: dibujar un `Container` de altura `MediaQuery.viewPadding.top` detrás del contenido.

Commit: `docs(android): record API 36 behaviour-change audit results` (checkboxes marcados tras verificar en V8).

## Fase 4 — Verificación y release

- **V0 · Pre-flight (entorno):**
  ```bash
  echo "$ANDROID_HOME"   # debe ser ~/Library/Android/sdk (verificado 27-jul)
  ls "$ANDROID_HOME/ndk/28.2.13676358/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-readelf"  # debe existir (verificado)
  avdmanager list avd    # phone API 36 ya existe: Medium_Phone_API_36.1
  # Falta tablet API 36 (sw>=600dp) — crear reutilizando la system image ya instalada:
  avdmanager create avd -n Tablet_API_36 -d pixel_tablet \
    -k "system-images;android-36;google_apis_playstore;arm64-v8a"
  ```
- **V1.** `flutter clean && flutter pub get`
- **V2.** `flutter analyze` — baseline esperada: 106 issues (no debe crecer)
- **V3.** `flutter test` — suite completa verde
- **V4.** `flutter pub upgrade --major-versions --dry-run` — SOLO reporte informativo para `chore/deps-post-api36`; no aplicar nada
- **V5.** `flutter build apk --debug` + smoke en `Medium_Phone_API_36.1`
- **V6.** Build release con el comando real del proyecto (sin flags de obfuscación — el proceso actual no las usa):
  ```bash
  flutter build appbundle --release
  # Artefacto: build/app/outputs/bundle/release/app-release.aab (~70MB)
  ```
  V7 y V10 operan sobre **este mismo artefacto** — no regenerar entre pasos.
- **V7.** Verificación 16 KB del AAB de V6 (`llvm-readelf` del NDK; el `objdump` de macOS es LLVM y no sirve para este chequeo):
  ```bash
  READELF="$ANDROID_HOME/ndk/28.2.13676358/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-readelf"
  unzip -o build/app/outputs/bundle/release/app-release.aab "base/lib/*" -d /tmp/aab-16kb-check
  find /tmp/aab-16kb-check/base/lib -name "*.so" | while read -r so; do
    printf '%s → ' "$so"
    "$READELF" -l "$so" | awk '$1=="LOAD"{print $NF}' | sort -u | tr '\n' ' '
    echo
  done
  # Cada .so debe reportar únicamente 0x4000 (2^14 = 16384).
  # Si alguno muestra 0x1000: identificar el plugin dueño del .so y subirlo.
  ```
- **V8 · Test matrix manual:**
  - Android (emulador API 36 + dispositivo físico):
    - [ ] Phone gesture-nav y 3-button nav: bottom nav + FAB sin solape con la barra del sistema
    - [ ] Back gesture predictivo sobre el stack de GoRouter (detail → list → home → salir)
    - [ ] `Tablet_API_36` (sw≥600dp): rotación a landscape y split-screen **con radio sonando** — el MiniPlayer se re-clampea y sigue alcanzable (valida Fase 2); si falla → regla de decisión B3 (opt-out + ship)
    - [ ] Dark mode on/off
    - [ ] Teclado abierto en formularios (publish, login) — `adjustResize`
    - [ ] Radio por los 4 tabs + publish; lock screen controls; kill desde recientes con radio activa
    - [ ] Google Sign-In completo en build release (R8)
    - [ ] image_picker (cámara/galería) y geolocator (permiso runtime)
  - iOS (la Fase 2 toca Dart compartido que llegará a main y al próximo release de iOS, hoy live en producción):
    - [ ] iPhone simulator con notch: radio sonando, rotar, MiniPlayer alcanzable
    - [ ] iPad simulator: radio sonando, rotar, MiniPlayer alcanzable
- **V9.** Bump `pubspec.yaml`: `version: 1.1.0+7` → **`1.1.1+8`** · commit `chore(release): bump to 1.1.1+8 (target API 36)`
  - **Decisión de versión — se prefiere `1.1.1+8` sobre `1.1.0+8`:** `versionName` se comparte con iOS (pubspec único alimenta ambas plataformas), y la Fase 2 cambia Dart compartido que también llegará al próximo release de iOS — reutilizar `1.1.0` como versionName con contenido distinto rompería la trazabilidad entre tiendas. `1.1.1` refleja un patch real en ambas plataformas.
  - ⚠️ Antes de un futuro build iOS con este versionName: confirmar el último build number en App Store Connect (histórico: ASC tenía builds manuales que no están en git).
- **V10.** Subir el AAB de V6 (mismo artefacto verificado en V7) al track de closed testing; revisar Pre-launch report (incluye tablets → segunda validación de B3)
- **V11.** Merge: push de `chore/android-16-api-36` + PR a `main` cuando closed testing pase; sin tag. El workflow `claude-code-review.yml` revisará el PR automáticamente — esperado y benigno.

## Follow-up post-merge (rama separada, NO en esta)

`chore/deps-post-api36` — después de que closed testing pase: `flutter pub upgrade` (patches disponibles: `audio_service 0.18.19`, `connectivity_plus 7.2.0`, `flutter_secure_storage 10.3.1`, `google_sign_in_android 7.2.15`…) + evaluación del dry-run de majors reportado en V4. Así el AAB de la migración contiene exactamente una variable.

## CI / GitHub Actions (hallazgos)

`c0ce5c2` mergeó dos workflows: `claude.yml` (asistente @claude en issues/PRs) y `claude-code-review.yml` (review automático de PRs con `claude-code-action@v1`). **Ninguno construye AAB ni instala Flutter/JDK/Android SDK** — no hay versiones pineadas que choquen con la migración. Los builds de release son locales. No se requiere ningún cambio de workflow.

## Restricciones respetadas

- Android-first: cambios en `build.gradle.kts` y (solo por exigencia estricta de B3) `lt_radio_mini_player.dart` + `radio_player_provider.dart`, neutrales para iOS (con smoke tests iOS en V8). Manifest solo si se activa la contingencia B3.
- Cero backend, cero upgrades de toolchain, cero dependencias en esta rama.
- Rollback global: `git checkout main && git branch -D chore/android-16-api-36`.
