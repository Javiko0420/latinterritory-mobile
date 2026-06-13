import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:latinterritory/features/categories/domain/category_option.dart';

class CategoryLocalCache {
  static const _dataKey = 'lt_categories_data_v1';
  static const _tsKey = 'lt_categories_ts_v1';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<Map<String, List<CategoryOption>>?> read() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_dataKey);
    if (raw == null) return null;

    try {
      final decoded = json.decode(raw) as Map<String, dynamic>;
      return {
        for (final key in ['businesses', 'jobs', 'events'])
          key: (decoded[key] as List<dynamic>)
              .map((e) => _fromMap(e as Map<String, dynamic>))
              .toList(),
      };
    } catch (_) {
      return null;
    }
  }

  Future<void> write(Map<String, List<CategoryOption>> data) async {
    final prefs = await _prefs;
    final encoded = json.encode({
      for (final entry in data.entries)
        entry.key: entry.value.map((o) => o.toJson()).toList(),
    });
    await Future.wait([
      prefs.setString(_dataKey, encoded),
      prefs.setString(_tsKey, DateTime.now().toIso8601String()),
    ]);
  }

  Future<DateTime?> getLastSync() async {
    final raw = (await _prefs).getString(_tsKey);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  bool isStale(
    DateTime lastSync, {
    Duration maxAge = const Duration(hours: 6),
  }) =>
      DateTime.now().difference(lastSync) > maxAge;

  CategoryOption _fromMap(Map<String, dynamic> map) => CategoryOption(
        value: map['value'] as String,
        labelEs: map['labelEs'] as String,
      );
}
