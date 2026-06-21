import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';

/// Badge "EN VIVO" con punto pulsante. Presentacional (recibe textos y colores).
class LiveBadge extends StatefulWidget {
  const LiveBadge({
    super.key,
    required this.label,
    required this.color,
    required this.soft,
    this.trailing,
  });

  final String label;
  final Color color;
  final Color soft;
  final String? trailing;

  @override
  State<LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<LiveBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.trailing != null ? '${widget.label} · ${widget.trailing}' : widget.label;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: widget.soft, borderRadius: BorderRadius.circular(LTRadius.pill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: Tween(begin: 1.0, end: 0.35).animate(_ctrl),
            child: Container(width: 6, height: 6, decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle)),
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: GoogleFonts.hankenGrotesk(fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 0.3, color: widget.color),
          ),
        ],
      ),
    );
  }
}
