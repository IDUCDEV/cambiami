import 'package:cambiami/core/error/exceptions.dart';
import 'package:cambiami/core/error/failures.dart';
import 'package:cambiami/core/utils/error_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

typedef _MapCase = ({
  String label,
  Failure failure,
  String expectedMessage,
  bool expectedCanRetry,
});

typedef _FromCase = ({String label, Object error, Failure expectedFailure});

void main() {
  group('ErrorMapper', () {
    group('map', () {
      _checkMap(const <_MapCase>[
        (
          label: 'NetworkFailure es reintentable con copy canónico',
          failure: NetworkFailure(),
          expectedMessage: ErrorMapper.updateRates,
          expectedCanRetry: true,
        ),
        (
          label: 'ServerFailure 401 no se reintenta',
          failure: ServerFailure(401),
          expectedMessage: ErrorMapper.updateRates,
          expectedCanRetry: false,
        ),
        (
          label: 'ServerFailure 403 no se reintenta',
          failure: ServerFailure(403),
          expectedMessage: ErrorMapper.updateRates,
          expectedCanRetry: false,
        ),
        (
          label: 'ServerFailure 404 no se reintenta',
          failure: ServerFailure(404),
          expectedMessage: ErrorMapper.updateRates,
          expectedCanRetry: false,
        ),
        (
          label: 'ServerFailure 422 no se reintenta',
          failure: ServerFailure(422),
          expectedMessage: ErrorMapper.updateRates,
          expectedCanRetry: false,
        ),
        (
          label: 'ServerFailure 500 se reintenta',
          failure: ServerFailure(500),
          expectedMessage: ErrorMapper.updateRates,
          expectedCanRetry: true,
        ),
        (
          label: 'ServerFailure 503 se reintenta',
          failure: ServerFailure(503),
          expectedMessage: ErrorMapper.updateRates,
          expectedCanRetry: true,
        ),
        (
          label: 'ServerFailure 0 no se reintenta',
          failure: ServerFailure(0),
          expectedMessage: ErrorMapper.updateRates,
          expectedCanRetry: false,
        ),
        (
          label: 'ParseFailure no se reintenta y usa copy canónico',
          failure: ParseFailure('rate_value'),
          expectedMessage: ErrorMapper.updateRates,
          expectedCanRetry: false,
        ),
        (
          label: 'CacheFailure no se reintenta y usa copy canónico',
          // D-2: el mensaje existe pero la UI decide no mostrarlo
          // (degradación silenciosa).
          failure: CacheFailure(),
          expectedMessage: ErrorMapper.updateRates,
          expectedCanRetry: false,
        ),
        (
          label: 'ValidationFailure sin campo usa copy de monto',
          failure: ValidationFailure(),
          expectedMessage: ErrorMapper.invalidAmount,
          expectedCanRetry: false,
        ),
        (
          label: 'ValidationFailure de monto usa copy de monto',
          failure: ValidationFailure(ErrorMapper.fieldAmount),
          expectedMessage: ErrorMapper.invalidAmount,
          expectedCanRetry: false,
        ),
        (
          label: 'ValidationFailure de tasa usa copy de §13.4',
          // D-1: §13.4 gana sobre ADR 0004
          // ("No pudimos calcular con esta tasa.").
          failure: ValidationFailure(ErrorMapper.fieldRate),
          expectedMessage: ErrorMapper.invalidRate,
          expectedCanRetry: false,
        ),
      ]);
    });

    group('cada Failure produce mensaje no vacío al mapear', () {
      final failures = <Failure>[
        const NetworkFailure(),
        const ServerFailure(401),
        const ParseFailure('rate_value'),
        const CacheFailure(),
        const ValidationFailure(),
        const ValidationFailure(ErrorMapper.fieldRate),
      ];

      for (final failure in failures) {
        test('${failure.runtimeType} produce mensaje no vacío', () {
          final info = ErrorMapper.map(failure);
          expect(info.message, isNotEmpty);
        });
      }
    });

    group('from / fromAppException', () {
      _checkFrom(const <_FromCase>[
        (
          label: 'NetworkException -> NetworkFailure',
          error: NetworkException('socket error'),
          expectedFailure: NetworkFailure(),
        ),
        (
          label: 'ServerException conserva code y detail',
          error: ServerException(401, 'PostgREST: permission denied'),
          expectedFailure: ServerFailure(401, 'PostgREST: permission denied'),
        ),
        (
          label: 'ServerException 500 conserva code',
          error: ServerException(500, 'boom'),
          expectedFailure: ServerFailure(500, 'boom'),
        ),
        (
          label: 'ParseException conserva field y descarta detail',
          error: ParseException('fetched_at', 'bad date'),
          expectedFailure: ParseFailure('fetched_at'),
        ),
        (
          label: 'CacheException -> CacheFailure',
          error: CacheException('disk'),
          expectedFailure: CacheFailure(),
        ),
        (
          label: 'ValidationException sin campo -> ValidationFailure sin campo',
          error: ValidationException(),
          expectedFailure: ValidationFailure(),
        ),
        (
          label: 'ValidationException de monto',
          error: ValidationException(ErrorMapper.fieldAmount),
          expectedFailure: ValidationFailure(ErrorMapper.fieldAmount),
        ),
        (
          label: 'ValidationException de tasa conserva el discriminador',
          error: ValidationException(ErrorMapper.fieldRate),
          expectedFailure: ValidationFailure(ErrorMapper.fieldRate),
        ),
        (
          label: 'Objeto no modelado usa fallback único',
          error: FormatException('inesperado'),
          expectedFailure: NetworkFailure(),
        ),
      ]);
    });

    group('detalle técnico no filtra a la UI', () {
      test('el body de ServerException no aparece en el mensaje mapeado', () {
        const detail = 'PostgREST: permission denied for table rates';
        final failure = ErrorMapper.from(const ServerException(500, detail));
        final info = ErrorMapper.map(failure);

        expect(failure, const ServerFailure(500, detail));
        expect((failure as ServerFailure).detail, detail);
        expect(info.message, isNot(contains('PostgREST')));
        expect(info.message, isNot(contains(detail)));
        expect(info.message, ErrorMapper.updateRates);
      });

      test('el detalle de NetworkException no aparece en el mensaje', () {
        final failure = ErrorMapper.from(
          const NetworkException('SocketException: timeout'),
        );
        final info = ErrorMapper.map(failure);

        expect(failure, const NetworkFailure());
        expect(info.message, isNot(contains('SocketException')));
        expect(info.message, ErrorMapper.updateRates);
      });
    });

    test('fromAppException traduce excepciones modeladas', () {
      expect(
        ErrorMapper.fromAppException(const CacheException('disk')),
        const CacheFailure(),
      );
      expect(
        ErrorMapper.fromAppException(
          const ValidationException(ErrorMapper.fieldRate),
        ),
        const ValidationFailure(ErrorMapper.fieldRate),
      );
    });
  });
}

void _checkMap(List<_MapCase> cases) {
  for (final testCase in cases) {
    test(testCase.label, () {
      final info = ErrorMapper.map(testCase.failure);
      expect(info.message, testCase.expectedMessage);
      expect(info.canRetry, testCase.expectedCanRetry);
    });
  }
}

void _checkFrom(List<_FromCase> cases) {
  for (final testCase in cases) {
    test(testCase.label, () {
      final failure = ErrorMapper.from(testCase.error);
      expect(failure, testCase.expectedFailure);
    });
  }
}
