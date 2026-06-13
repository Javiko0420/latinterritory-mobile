import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:latinterritory/features/categories/data/category_local_cache.dart';
import 'package:latinterritory/features/categories/data/category_remote_data_source.dart';
import 'package:latinterritory/features/categories/data/category_repository.dart';
import 'package:latinterritory/features/categories/domain/category_option.dart';

class MockCategoryRemoteDataSource extends Mock implements CategoryRemoteDataSource {}

class MockCategoryLocalCache extends Mock implements CategoryLocalCache {}

void main() {
  late MockCategoryRemoteDataSource mockRemote;
  late MockCategoryLocalCache mockCache;
  late CategoryRepository repo;

  const tBusiness = CategoryOption(value: 'GASTRONOMIA', labelEs: 'Gastronomía');
  const tFreshBusiness = CategoryOption(value: 'TECNOLOGIA', labelEs: 'Tecnología');

  final tCachedData = {
    'businesses': [tBusiness],
    'jobs': <CategoryOption>[],
    'events': <CategoryOption>[],
  };

  final tFreshData = {
    'businesses': [tFreshBusiness],
    'jobs': <CategoryOption>[],
    'events': <CategoryOption>[],
  };

  setUpAll(() {
    registerFallbackValue(<String, List<CategoryOption>>{});
  });

  setUp(() {
    mockRemote = MockCategoryRemoteDataSource();
    mockCache = MockCategoryLocalCache();
    repo = CategoryRepository(remote: mockRemote, cache: mockCache);
  });

  group('getCategories', () {
    test('cache hit (fresh): returns cached data without network call', () async {
      final recentSync = DateTime.now().subtract(const Duration(hours: 1));
      when(() => mockCache.getLastSync()).thenAnswer((_) async => recentSync);
      when(() => mockCache.isStale(any())).thenReturn(false);
      when(() => mockCache.read()).thenAnswer((_) async => tCachedData);

      final result = await repo.getCategories(CategoryVertical.business);

      expect(result, [tBusiness]);
      verifyNever(() => mockRemote.fetchAll());
    });

    test('cache stale, refresh success: writes fresh data and returns it', () async {
      final oldSync = DateTime.now().subtract(const Duration(hours: 10));
      when(() => mockCache.getLastSync()).thenAnswer((_) async => oldSync);
      when(() => mockCache.isStale(any())).thenReturn(true);
      when(() => mockRemote.fetchAll()).thenAnswer((_) async => tFreshData);
      when(() => mockCache.write(any())).thenAnswer((_) async {});

      final result = await repo.getCategories(CategoryVertical.business);

      expect(result, [tFreshBusiness]);
      verify(() => mockCache.write(any())).called(1);
    });

    test('cache stale, refresh fails: falls back to stale cache', () async {
      final oldSync = DateTime.now().subtract(const Duration(hours: 10));
      when(() => mockCache.getLastSync()).thenAnswer((_) async => oldSync);
      when(() => mockCache.isStale(any())).thenReturn(true);
      when(() => mockRemote.fetchAll()).thenThrow(Exception('Network error'));
      when(() => mockCache.read()).thenAnswer((_) async => tCachedData);

      final result = await repo.getCategories(CategoryVertical.business);

      expect(result, [tBusiness]);
      verifyNever(() => mockCache.write(any()));
    });

    test('no cache, fetch fails: propagates exception', () async {
      when(() => mockCache.getLastSync()).thenAnswer((_) async => null);
      when(() => mockRemote.fetchAll()).thenThrow(Exception('Network error'));
      when(() => mockCache.read()).thenAnswer((_) async => null);

      expect(
        () => repo.getCategories(CategoryVertical.business),
        throwsException,
      );
    });
  });
}
