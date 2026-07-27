import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latinterritory/features/radio/ui/lt_radio_mini_player.dart';

/// Tests de los límites de posicionamiento del mini player.
///
/// Cubren el behaviour change B3 de Android 16: en pantallas grandes el lock a
/// portrait se ignora, así que rotación, split-screen y cutouts laterales pasan
/// a ser escenarios reales. Se afirma sobre los números, no sobre widgets
/// renderizados.
void main() {
  const expandedSize = Size(kPlayerWidth, kPlayerHeight);
  const fabSize = Size(kFabSize, kFabSize);

  group('PlayerBounds.of', () {
    test('portrait sin insets deriva los límites del tamaño de pantalla', () {
      final bounds = PlayerBounds.of(
        screen: const Size(400, 800),
        viewPadding: EdgeInsets.zero,
        size: expandedSize,
      );

      expect(bounds.minX, kSafeAreaMargin);
      expect(bounds.maxX, 400 - kPlayerWidth - kSafeAreaMargin);
      expect(bounds.minY, kSafeAreaMargin);
      // El borde inferior solo descuenta la reserva del bottom nav: sin gesture
      // bar, viewPadding.bottom es 0.
      expect(bounds.maxY, 800 - kPlayerHeight - kNavBarMargin);
    });

    test('landscape con cutout a la izquierda excluye el inset de minX', () {
      final bounds = PlayerBounds.of(
        screen: const Size(800, 400),
        viewPadding: const EdgeInsets.only(left: 44),
        size: expandedSize,
      );

      expect(bounds.minX, 44 + kSafeAreaMargin);
      // El borde derecho queda libre: no se descuenta inset de ese lado.
      expect(bounds.maxX, 800 - kPlayerWidth - kSafeAreaMargin);
      // Un offset pegado al borde izquierdo se corrige fuera del cutout.
      expect(bounds.clamp(const Offset(0, 100)).dx, 44 + kSafeAreaMargin);
    });

    test('landscape con cutout a la derecha excluye el inset de maxX', () {
      final bounds = PlayerBounds.of(
        screen: const Size(800, 400),
        viewPadding: const EdgeInsets.only(right: 44),
        size: expandedSize,
      );

      expect(bounds.minX, kSafeAreaMargin);
      expect(bounds.maxX, 800 - kPlayerWidth - 44 - kSafeAreaMargin);
      // Un offset fuera de pantalla por la derecha se corrige fuera del cutout.
      expect(
        bounds.clamp(const Offset(9999, 100)).dx,
        800 - kPlayerWidth - 44 - kSafeAreaMargin,
      );
    });

    test('split-screen: maxY colapsa a minY y clamp() no lanza', () {
      final bounds = PlayerBounds.of(
        screen: const Size(400, 150),
        viewPadding: EdgeInsets.zero,
        size: expandedSize,
      );

      // 150 - 72 - 96 es negativo: sin el saneo, clamp() recibiría un rango
      // invertido y lanzaría ArgumentError.
      expect(bounds.maxY, bounds.minY);
      expect(() => bounds.clamp(const Offset(16, 600)), returnsNormally);
      expect(bounds.clamp(const Offset(16, 600)).dy, bounds.minY);
    });

    test('el FAB minimizado admite un rango más amplio que la card', () {
      const screen = Size(400, 800);
      const viewPadding = EdgeInsets.zero;

      final expanded = PlayerBounds.of(
        screen: screen,
        viewPadding: viewPadding,
        size: expandedSize,
      );
      final minimized = PlayerBounds.of(
        screen: screen,
        viewPadding: viewPadding,
        size: fabSize,
      );

      expect(minimized.maxX, greaterThan(expanded.maxX));
      expect(minimized.maxY, greaterThan(expanded.maxY));
      expect(
        minimized.maxX - minimized.minX,
        greaterThan(expanded.maxX - expanded.minX),
      );
      expect(
        minimized.maxY - minimized.minY,
        greaterThan(expanded.maxY - expanded.minY),
      );
    });
  });
}
