import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latinterritory/features/worldcup_2026/models/world_cup_config.dart';
import 'package:latinterritory/features/worldcup_2026/state/world_cup_providers.dart';

/// Crea un container con `clockProvider` y `worldCupConfigProvider` overrideados.
ProviderContainer _container({required DateTime now, required WorldCupConfig? config}) {
  return ProviderContainer(
    overrides: [
      clockProvider.overrideWithValue(() => now),
      worldCupConfigProvider.overrideWith((ref) async => config),
    ],
  );
}

Future<bool> _resolveVisible(ProviderContainer c) async {
  // Mantener vivos los providers (autoDispose) y esperar el config.
  c.listen(worldCupVisibleProvider, (_, __) {});
  await c.read(worldCupConfigProvider.future);
  return c.read(worldCupVisibleProvider);
}

void main() {
  final beforeSunset = DateTime(2026, 7, 19, 22); // final del 19-jul
  final atSunset = DateTime(2026, 7, 20, 0, 1); // ya 20-jul

  test('flag servidor enabled=true + antes del sunset → visible', () async {
    final c = _container(
      now: beforeSunset,
      config: WorldCupConfig(enabled: true, sunsetAt: DateTime(2026, 7, 20)),
    );
    expect(await _resolveVisible(c), isTrue);
    c.dispose();
  });

  test('flag servidor enabled=false → oculto', () async {
    final c = _container(
      now: beforeSunset,
      config: WorldCupConfig(enabled: false, sunsetAt: DateTime(2026, 7, 20)),
    );
    expect(await _resolveVisible(c), isFalse);
    c.dispose();
  });

  test('sunsetAt ya pasó aunque enabled=true → oculto', () async {
    final c = _container(
      now: beforeSunset,
      config: WorldCupConfig(enabled: true, sunsetAt: DateTime(2026, 7, 1)),
    );
    expect(await _resolveVisible(c), isFalse);
    c.dispose();
  });

  test('config caído (null) → date-guard local: visible el 19-jul', () async {
    final c = _container(now: beforeSunset, config: null);
    expect(await _resolveVisible(c), isTrue);
    c.dispose();
  });

  test('config caído (null) → date-guard local: oculto el 20-jul', () async {
    final c = _container(now: atSunset, config: null);
    expect(await _resolveVisible(c), isFalse);
    c.dispose();
  });
}
