import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latinterritory/features/worldcup_2026/data/world_cup_api.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late WorldCupApi api;

  setUp(() {
    dio = _MockDio();
    api = WorldCupApi(dio);
  });

  Response<dynamic> ok(Object data) =>
      Response<dynamic>(requestOptions: RequestOptions(path: '/'), data: data, statusCode: 200);

  DioException dioErr({DioExceptionType type = DioExceptionType.badResponse}) =>
      DioException(requestOptions: RequestOptions(path: '/'), type: type);

  test('fetchLive parsea la respuesta OK', () async {
    when(() => dio.get<dynamic>('/api/sports/worldcup/live')).thenAnswer((_) async => ok({
          'fixtures': [
            {'id': 1, 'teams': {'home': {'name': 'A'}, 'away': {'name': 'B'}}, 'status': {'short': '2H'}}
          ],
          'hasLive': true,
        }));
    final live = await api.fetchLive();
    expect(live.hasLive, true);
    expect(live.fixtures, hasLength(1));
    expect(live.fixtures.first.home.name, 'A');
  });

  test('fetchConfig es fail-safe: devuelve null ante error de red', () async {
    when(() => dio.get<dynamic>('/api/sports/worldcup/config')).thenThrow(dioErr());
    expect(await api.fetchConfig(), isNull);
  });

  test('fetchConfig devuelve null ante timeout', () async {
    when(() => dio.get<dynamic>('/api/sports/worldcup/config'))
        .thenThrow(dioErr(type: DioExceptionType.connectionTimeout));
    expect(await api.fetchConfig(), isNull);
  });

  test('fetchStandings relanza el error (502/504/500)', () async {
    when(() => dio.get<dynamic>('/api/sports/worldcup/standings')).thenThrow(dioErr());
    expect(() => api.fetchStandings(), throwsA(isA<DioException>()));
  });

  test('fetchRounds calcula knockoutRounds excluyendo grupos', () async {
    when(() => dio.get<dynamic>('/api/sports/worldcup/rounds')).thenAnswer((_) async => ok({
          'rounds': ['Group Stage - 1', 'Group Stage - 2', 'Round of 16', 'Final'],
          'current': 'Round of 16',
        }));
    final r = await api.fetchRounds();
    expect(r.knockoutRounds, ['Round of 16', 'Final']);
  });
}
