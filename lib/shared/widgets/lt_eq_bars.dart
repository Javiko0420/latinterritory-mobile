import 'package:flutter/material.dart';

/// Animated equalizer bars shown while radio is playing.
class LtEqBars extends StatefulWidget {
  const LtEqBars({super.key});

  @override
  State<LtEqBars> createState() => _LtEqBarsState();
}

class _LtEqBarsState extends State<LtEqBars>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        const heights = [4.0, 8.0, 6.0, 10.0, 7.0];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(5, (i) {
            final phase = i / 5;
            final t = ((_ctrl.value + phase) % 1.0);
            final h = 4.0 +
                (heights[i] - 4.0) * (t < 0.5 ? t * 2 : (1 - t) * 2);
            return Container(
              width: 3,
              height: h,
              margin: const EdgeInsets.only(right: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(1),
              ),
            );
          }),
        );
      },
    );
  }
}
