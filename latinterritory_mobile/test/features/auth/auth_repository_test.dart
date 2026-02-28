import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:latinterritory/core/storage/secure_storage.dart';
import 'package:latinterritory/features/auth/data/auth_repository.dart';
import 'package:latinterritory/features/auth/data/models/auth_models.dart';

// ── Mocks ─────────────────────────────────────────────────

class MockDio extends Mock implements Dio {}

class MockSecureStorage extends Mock implements SecureStorageService {}

class MockResponse extends Mock implements Response<dynamic> {}

void main() {
  late MockDio mockDio;
  late MockSecureStorage mockStorage;
  late AuthRepository repository;

  setUp(() {
    mockDio = MockDio();
    mockStorage = MockSecureStorage();
    repository = AuthRepository(dio: mockDio, storage: mockStorage);
  });

  group('AuthRepository', () {
    group('login', () {
      test('should return AuthResponse and persist tokens on success',
          () async {
        // Arrange
        final mockResponseData = {
          'accessToken': 'test-access-token',
          'refreshToken': 'test-refresh-token',
          'user': {
            'id': 'user-1',
            'email': 'test@example.com',
            'name': 'Test User',
            'role': 'USER',
            'profileCompleted': false,
          },
          'isNewUser': false,
        };

        final response = MockResponse();
        when(() => response.data).thenReturn(mockResponseData);
        when(() => response.statusCode).thenReturn(200);

        when(() => mockDio.post(any(), data: any(named: 'data')))
            .thenAnswer((_) async => response);

        when(() => mockStorage.saveTokens(
              accessToken: any(named: 'accessToken'),
              refreshToken: any(named: 'refreshToken'),
              expiry: any(named: 'expiry'),
            )).thenAnswer((_) async {});

        // Act
        final result = await repository.login(
          const LoginRequest(
            email: 'test@example.com',
            password: 'password123',
          ),
        );

        // Assert
        expect(result.user.email, 'test@example.com');
        expect(result.accessToken, 'test-access-token');

        verify(() => mockStorage.saveTokens(
              accessToken: 'test-access-token',
              refreshToken: 'test-refresh-token',
            )).called(1);
      });
    });

    group('logout', () {
      test('should clear all stored data', () async {
        when(() => mockStorage.clearAll()).thenAnswer((_) async {});

        await repository.logout();

        verify(() => mockStorage.clearAll()).called(1);
      });
    });
  });
}
