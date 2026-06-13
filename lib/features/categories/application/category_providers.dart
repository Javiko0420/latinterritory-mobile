import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latinterritory/features/auth/providers/auth_provider.dart';
import 'package:latinterritory/features/categories/data/category_local_cache.dart';
import 'package:latinterritory/features/categories/data/category_remote_data_source.dart';
import 'package:latinterritory/features/categories/data/category_repository.dart';
import 'package:latinterritory/features/categories/domain/category_option.dart';

final _categoryRemoteDataSourceProvider = Provider<CategoryRemoteDataSource>((ref) {
  return CategoryRemoteDataSource(dio: ref.watch(dioProvider));
});

final _categoryLocalCacheProvider = Provider<CategoryLocalCache>((ref) {
  return CategoryLocalCache();
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(
    remote: ref.watch(_categoryRemoteDataSourceProvider),
    cache: ref.watch(_categoryLocalCacheProvider),
  );
});

final businessCategoriesProvider = FutureProvider<List<CategoryOption>>((ref) {
  return ref.watch(categoryRepositoryProvider).getCategories(CategoryVertical.business);
});

final jobCategoriesProvider = FutureProvider<List<CategoryOption>>((ref) {
  return ref.watch(categoryRepositoryProvider).getCategories(CategoryVertical.job);
});

final eventCategoriesProvider = FutureProvider<List<CategoryOption>>((ref) {
  return ref.watch(categoryRepositoryProvider).getCategories(CategoryVertical.event);
});
