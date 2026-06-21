import 'package:flutter/foundation.dart';

/// Config remota de la campaña (feature flag). El endpoint puede no existir aún;
/// por eso `fetchConfig()` devuelve null ante fallo y la visibilidad cae al
/// date-guard local.
@immutable
class WorldCupConfig {
  const WorldCupConfig({required this.enabled, this.sunsetAt});

  final bool enabled;
  final DateTime? sunsetAt;

  factory WorldCupConfig.fromJson(Map<String, dynamic> json) {
    final rawSunset = json['sunsetAt'] as String?;
    return WorldCupConfig(
      enabled: json['enabled'] as bool? ?? false,
      sunsetAt: rawSunset != null ? DateTime.tryParse(rawSunset)?.toLocal() : null,
    );
  }
}
