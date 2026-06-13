import 'package:flutter/foundation.dart';
import 'package:latinterritory/features/categories/data/category_local_cache.dart';
import 'package:latinterritory/features/categories/data/category_remote_data_source.dart';
import 'package:latinterritory/features/categories/domain/category_option.dart';

class CategoryRepository {
  CategoryRepository({
    required CategoryRemoteDataSource remote,
    required CategoryLocalCache cache,
  })  : _remote = remote,
        _cache = cache;

  final CategoryRemoteDataSource _remote;
  final CategoryLocalCache _cache;

  Future<List<CategoryOption>> getCategories(CategoryVertical vertical) async {
    final lastSync = await _cache.getLastSync();
    final isFresh = lastSync != null && !_cache.isStale(lastSync);

    if (isFresh) {
      final cached = await _cache.read();
      if (cached != null) return cached[vertical.apiKey] ?? [];
    }

    try {
      final fetched = await _remote.fetchAll();
      await _cache.write(fetched);
      return fetched[vertical.apiKey] ?? [];
    } catch (e) {
      final stale = await _cache.read();
      if (stale != null) {
        debugPrint('[CategoryRepository] Using stale cache after network error: $e');
        return stale[vertical.apiKey] ?? [];
      }
      rethrow;
    }
  }
}
