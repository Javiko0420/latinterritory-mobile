import 'package:flutter/material.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';

/// Press feedback tipo Apple: escala sutil a 0.97 (~160ms, easeOut) al tocar.
///
/// Envuelve cualquier contenido tappable del design system. No cambia layout.
class LtPressable extends StatefulWidget {
  const LtPressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.97,
    this.behavior = HitTestBehavior.opaque,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;
  final HitTestBehavior behavior;

  @override
  State<LtPressable> createState() => _LtPressableState();
}

class _LtPressableState extends State<LtPressable> {
  bool _pressed = false;

  void _set(bool v) {
    if (widget.onTap == null && widget.onLongPress == null) return;
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final tappable = widget.onTap != null || widget.onLongPress != null;
    return Semantics(
      button: tappable,
      child: GestureDetector(
        behavior: widget.behavior,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        child: AnimatedScale(
          scale: _pressed ? widget.pressedScale : 1.0,
          duration: LTMotion.press,
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
