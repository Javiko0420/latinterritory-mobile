import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latinterritory/features/radio/providers/radio_player_provider.dart';
import 'package:latinterritory/features/radio/ui/lt_radio_mini_player.dart';

/// Layers the floating radio mini player above all routed content.
///
/// Uses a [Stack] in the MaterialApp builder (not [OverlayEntry]) so the
/// player reliably renders on top of every screen.
class RadioOverlayWrapper extends ConsumerWidget {
  const RadioOverlayWrapper({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Rebuild whenever player state changes (mode, position, station…).
    ref.watch(radioPlayerProvider);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        const LtRadioMiniPlayer(),
      ],
    );
  }
}
