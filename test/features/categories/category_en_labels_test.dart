import 'package:flutter_test/flutter_test.dart';
import 'package:latinterritory/features/categories/data/category_en_labels.dart';

void main() {
  group('businessLabelsEn completeness', () {
    const expected = [
      'GASTRONOMIA',
      'TECNOLOGIA',
      'ARTESANIAS',
      'SERVICIOS',
      'MODA',
      'AGRICULTURA',
      'TURISMO',
      'SALUD',
      'EDUCACION',
      'CONSTRUCCION',
      'TRANSPORTE',
      'ENTRETENIMIENTO',
      'OTROS',
    ];

    for (final value in expected) {
      test('contains $value', () {
        expect(
          businessLabelsEn.containsKey(value),
          isTrue,
          reason: 'businessLabelsEn is missing key "$value"',
        );
      });
    }
  });

  group('jobLabelsEn completeness', () {
    const expected = [
      'TECNOLOGIA',
      'HOSTELERIA',
      'CONSTRUCCION',
      'VENTAS',
      'MARKETING',
    ];

    for (final value in expected) {
      test('contains $value', () {
        expect(
          jobLabelsEn.containsKey(value),
          isTrue,
          reason: 'jobLabelsEn is missing key "$value"',
        );
      });
    }
  });

  group('eventLabelsEn completeness', () {
    const expected = [
      'CONCIERTO',
      'TEATRO',
      'COMEDIA',
      'FIESTA',
      'FESTIVAL',
      'DEPORTES',
      'CULTURAL',
      'NETWORKING',
      'OTRO',
    ];

    for (final value in expected) {
      test('contains $value', () {
        expect(
          eventLabelsEn.containsKey(value),
          isTrue,
          reason: 'eventLabelsEn is missing key "$value"',
        );
      });
    }
  });

  group('labelEnFor', () {
    test('returns English label for known business value', () {
      expect(labelEnFor('businesses', 'GASTRONOMIA', 'Gastronomía'), 'Food & Dining');
    });

    test('returns English label for known job value', () {
      expect(labelEnFor('jobs', 'HOSTELERIA', 'Hostelería'), 'Hospitality');
    });

    test('returns English label for known event value', () {
      expect(labelEnFor('events', 'CONCIERTO', 'Concierto'), 'Concert');
    });

    test('returns fallbackEs for unknown value', () {
      expect(labelEnFor('businesses', 'NUEVO_VALOR', 'Nuevo Valor'), 'Nuevo Valor');
    });

    test('returns fallbackEs for unknown vertical', () {
      expect(labelEnFor('unknown_vertical', 'GASTRONOMIA', 'Gastronomía'), 'Gastronomía');
    });
  });
}
