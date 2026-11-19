import 'package:cambiami/core/formatters/es_ve_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

const String _minus = '\u2212';

/// Caso de un método que recibe un número y devuelve texto.
typedef _NumCase = ({String label, num value, String expected});

/// Caso de `variation`, con las dos entradas numéricas.
typedef _VariationCase = ({String label, num change, num pct, String expected});

/// Caso de un método que recibe una fecha.
typedef _DateTimeCase = ({String label, DateTime value, String expected});

/// Caso de `parse`.
typedef _ParseCase = ({String label, String input, double? expected});

void main() {
  group('EsVeFormatter', () {
    _checkNum('rate', EsVeFormatter.rate, const <_NumCase>[
      (
        label: '§8 caso 1 · conserva los 4 decimales de la fuente',
        value: 889.5754,
        expected: '889,5754 Bs',
      ),
      (
        label: 'D-2 · entero con mínimo 2 decimales',
        value: 889,
        expected: '889,00 Bs',
      ),
      (
        label: 'D-2 · un decimal se rellena a 2',
        value: 1.5,
        expected: '1,50 Bs',
      ),
      (
        label: 'D-2 · hasta 6 decimales naturales',
        value: 1.2345678,
        expected: '1,234568 Bs',
      ),
      (
        label: 'D-2 · 0,000001 no se recorta',
        value: 0.000001,
        expected: '0,000001 Bs',
      ),
      (
        label: 'miles con decimales naturales',
        value: 1234567.891,
        expected: '1.234.567,891 Bs',
      ),
      (
        label: 'menos tipográfico en la tasa',
        value: -889.5754,
        expected: '−889,5754 Bs',
      ),
      (label: 'menos cero sin signo', value: -0.0, expected: '0,00 Bs'),
    ]);

    _checkNum('bs', EsVeFormatter.bs, const <_NumCase>[
      (label: '§8 caso 2 · monto en Bs', value: 889.58, expected: '889,58 Bs'),
      (
        label: '§8 caso 4 · punto de miles con 4 dígitos enteros',
        value: 1234.5,
        expected: '1.234,50 Bs',
      ),
      (label: '§8 caso 8 · cero', value: 0, expected: '0,00 Bs'),
      (
        label: '3 dígitos enteros no llevan punto de miles',
        value: 999.5,
        expected: '999,50 Bs',
      ),
      (
        label: '4 dígitos enteros sí llevan punto de miles',
        value: 1000,
        expected: '1.000,00 Bs',
      ),
      (
        label: 'D-5 · siempre 2 decimales, sin half-even propio',
        value: 2.346,
        expected: '2,35 Bs',
      ),
      (
        label: 'acarreo antes de agrupar',
        value: 999999.999,
        expected: '1.000.000,00 Bs',
      ),
      (label: 'negativo con miles', value: -1234.5, expected: '−1.234,50 Bs'),
      (label: 'menos cero sin signo', value: -0.0, expected: '0,00 Bs'),
    ]);

    _checkNum('usd', EsVeFormatter.usd, const <_NumCase>[
      (
        label: r'§8 caso 3 · $ delante con espacio',
        value: 1,
        expected: r'$ 1,00',
      ),
      (label: 'miles', value: 1234.5, expected: r'$ 1.234,50'),
      (
        label: 'D-4 · el signo abre la cifra completa',
        value: -1.5,
        expected: r'−$ 1,50',
      ),
      (label: 'cero', value: 0, expected: r'$ 0,00'),
      (label: 'menos cero sin signo', value: -0.0, expected: r'$ 0,00'),
    ]);

    _checkVariation(const <_VariationCase>[
      (
        label: '§8 caso 5 · + en el monto, sin + en el porcentaje',
        change: 0.32,
        pct: 0.04,
        expected: '+0,32 Bs (0,04 %)',
      ),
      (
        label: '§8 caso 6 · menos tipográfico en ambas cifras',
        change: -1.55,
        pct: -0.16,
        expected: '−1,55 Bs (−0,16 %)',
      ),
      (
        label: '§8 caso 7 · cero sin signo',
        change: 0,
        pct: 0,
        expected: '0,00 Bs (0,00 %)',
      ),
      (
        label: 'porcentaje positivo sin signo',
        change: 1.5,
        pct: 2,
        expected: '+1,50 Bs (2,00 %)',
      ),
      (
        label: 'el signo se decide después de redondear',
        change: -0.004,
        pct: -0.001,
        expected: '0,00 Bs (0,00 %)',
      ),
      (
        label: 'menos cero',
        change: -0.0,
        pct: -0.0,
        expected: '0,00 Bs (0,00 %)',
      ),
      (
        label: 'los signos de monto y porcentaje son independientes',
        change: 0.32,
        pct: -0.16,
        expected: '+0,32 Bs (−0,16 %)',
      ),
    ]);

    _checkNum('gap', EsVeFormatter.gap, const <_NumCase>[
      (
        label: '§8 caso 11 · ratio a porcentaje',
        value: 0.1195,
        expected: '11,95 %',
      ),
      (label: 'cero', value: 0, expected: '0,00 %'),
      (label: 'ratio negativo', value: -0.0016, expected: '−0,16 %'),
      (label: 'ratio 1 es 100 %', value: 1, expected: '100,00 %'),
      (label: 'un centésimo', value: 0.0001, expected: '0,01 %'),
    ]);

    _checkDateTime('date', EsVeFormatter.date, <_DateTimeCase>[
      (
        label: '§8 caso 9 · fecha larga',
        value: DateTime(2026, 11, 2),
        expected: 'Lunes, 02/11/26',
      ),
      (
        label: 'enero',
        value: DateTime(2026, 1, 5),
        expected: 'Lunes, 05/01/26',
      ),
      (
        label: 'miércoles con acento',
        value: DateTime(2025, 12, 31),
        expected: 'Miércoles, 31/12/25',
      ),
      (
        label: 'domingo',
        value: DateTime(2026, 11, 8),
        expected: 'Domingo, 08/11/26',
      ),
      (
        label: 'año con cero a la izquierda',
        value: DateTime(2005, 3, 7),
        expected: 'Lunes, 07/03/05',
      ),
    ]);

    _checkDateTime('time', EsVeFormatter.time, <_DateTimeCase>[
      (
        label: '§8 caso 10 · D-1, sin cero a la izquierda',
        value: DateTime(2026, 11, 2, 9),
        expected: '9:00 a. m.',
      ),
      (
        label: 'medianoche',
        value: DateTime(2026, 11, 2, 0, 5),
        expected: '12:05 a. m.',
      ),
      (
        label: 'mediodía',
        value: DateTime(2026, 11, 2, 12),
        expected: '12:00 p. m.',
      ),
      (
        label: 'tarde',
        value: DateTime(2026, 11, 2, 13, 7),
        expected: '1:07 p. m.',
      ),
      (
        label: 'final del día',
        value: DateTime(2026, 11, 2, 23, 59),
        expected: '11:59 p. m.',
      ),
      (
        label: 'copia de §7.7',
        value: DateTime(2026, 11, 2, 9, 41),
        expected: '9:41 a. m.',
      ),
      (
        label: 'copia de §13.2',
        value: DateTime(2026, 11, 2, 17, 2),
        expected: '5:02 p. m.',
      ),
    ]);

    _checkParse(const <_ParseCase>[
      (label: 'coma decimal', input: '889,5754', expected: 889.5754),
      (label: 'punto decimal', input: '889.5754', expected: 889.5754),
      (
        label: 'dos separadores, gana la coma',
        input: '1.234,56',
        expected: 1234.56,
      ),
      (
        label: 'dos separadores, gana el punto',
        input: '1,234.56',
        expected: 1234.56,
      ),
      (
        label: 'separador repetido con grupos de 3',
        input: '1.234.567',
        expected: 1234567,
      ),
      (
        label: 'D-3 · un separador suelto es decimal',
        input: '1.234',
        expected: 1.234,
      ),
      (label: 'menos tipográfico', input: '−1,5', expected: -1.5),
      (label: 'menos ASCII', input: '-1,5', expected: -1.5),
      (
        label: 'espacios y agrupamiento con espacio',
        input: ' 1 234,56 ',
        expected: 1234.56,
      ),
      (label: 'vacío', input: '', expected: null),
      (label: 'letras', input: 'abc', expected: null),
      (label: 'grupos incompletos', input: '1,2,3', expected: null),
      (label: 'separador final sin decimales', input: '1,', expected: null),
      (label: 'signo sin dígitos', input: '-', expected: null),
      (label: 'dos signos', input: '--1', expected: null),
    ]);

    group('reglas transversales', () {
      test('el menos siempre es U+2212 y nunca el guion ASCII', () {
        final salidas = <String>[
          EsVeFormatter.rate(-1),
          EsVeFormatter.bs(-1),
          EsVeFormatter.usd(-1),
          EsVeFormatter.variation(-1, -1),
          EsVeFormatter.gap(-1),
        ];

        for (final salida in salidas) {
          expect(salida, contains(_minus), reason: salida);
          expect(salida, isNot(contains('-')), reason: salida);
        }
      });

      test('el porcentaje nunca lleva +', () {
        expect(EsVeFormatter.variation(1, 2), '+1,00 Bs (2,00 %)');
        expect(EsVeFormatter.gap(0.02), '2,00 %');
      });

      test('gap convierte el ratio a porcentaje una sola vez', () {
        // 0,1195 es un ratio: 11,95 %, no 0,12 % ni 1195 %.
        expect(EsVeFormatter.gap(0.1195), '11,95 %');
      });
    });
  });
}

void _checkNum(
  String method,
  String Function(num) format,
  List<_NumCase> cases,
) {
  group(method, () {
    for (final testCase in cases) {
      test(testCase.label, () {
        expect(format(testCase.value), testCase.expected);
      });
    }
  });
}

void _checkVariation(List<_VariationCase> cases) {
  group('variation', () {
    for (final testCase in cases) {
      test(testCase.label, () {
        expect(
          EsVeFormatter.variation(testCase.change, testCase.pct),
          testCase.expected,
        );
      });
    }
  });
}

void _checkDateTime(
  String method,
  String Function(DateTime) format,
  List<_DateTimeCase> cases,
) {
  group(method, () {
    for (final testCase in cases) {
      test(testCase.label, () {
        expect(format(testCase.value), testCase.expected);
      });
    }
  });
}

void _checkParse(List<_ParseCase> cases) {
  group('parse', () {
    for (final testCase in cases) {
      test(testCase.label, () {
        expect(EsVeFormatter.parse(testCase.input), testCase.expected);
      });
    }
  });
}
