import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/shared/widgets/lt_pressable.dart';

/// Avatar de iniciales sobre un círculo con gradiente de marca.
/// Sin imágenes de stock: deriva el gradiente del nombre (estable).
class LtAvatar extends StatelessWidget {
  const LtAvatar({
    super.key,
    required this.name,
    this.size = 40,
    this.onTap,
  });

  final String name;
  final double size;
  final VoidCallback? onTap;

  static const _pairs = [
    [LTBrand.gold, LTBrand.coral],
    [LTBrand.night, LTBrand.green],
    [LTBrand.coral, LTBrand.gold],
    [LTBrand.green, LTBrand.night],
  ];

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts[1].characters.first).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final pair = _pairs[name.hashCode.abs() % _pairs.length];

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: pair,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: GoogleFonts.hankenGrotesk(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.2,
        ),
      ),
    );

    if (onTap == null) return avatar;
    return LtPressable(onTap: onTap, child: avatar);
  }
}
