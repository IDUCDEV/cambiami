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

typedef _FromExceptionCase = ({
  String label,
  Object exception,
  Failure expectedFailure,
});

void main() {
  group('ErrorMapper', () {
    group('map', () {
      _checkMap(const <_MapCase>[
        (
          label: 'NetworkFailure es reintentable con copy canónico',
          failure: NetworkFailure(message: ErrorMapper.updateRates),
          expectedMessage: ErrorMapper.updateRates,
          expectedCanRetry: true,
        ),
        (
          label: 'NetworkFailure con mensaje por defecto se normaliza',
          failure: NetworkFailure(),
          expectedMessage: ErrorMapper.updateRates,
          expectedCanRetry: true,
        ),
        (
          label: 'ServerFailure 401 no se reintenta',
          failure: ServerFailure(message: ErrorMapper.updateRates, code: 401),
          expectedMessage: ErrorMapper.updateRates,
          expectedCanRetry: false,
        ),
        (
          label: 'ServerFailure 403 no se reintenta',
          failure: ServerFailure(message: ErrorMapper.updateRates, code: 403),
          expectedMessage: ErrorMapper.updateRates,
          expectedCanRetry: false,
        ),
        (
          label: 'ServerFailure 404 no se reintenta',
          failure: ServerFailure(message: ErrorMapper.updateRates, code: 404),
          expectedMessage: ErrorMapper.updateRates,
          expectedCanRetry: false,
        ),
        (
          label: 'ServerFailure 422 no se reintenta',
          failure: ServerFailure(message: ErrorMapper.updateRates, code: 422),
          expectedMessage: ErrorMapper.updateRates,
          expectedCanRetry: false,
        ),
        (
          label: 'ServerFailure 500 se reintenta',
          failure: ServerFailure(message: ErrorMapper.updateRates, code: 500),
          expectedMessage: ErrorMapper.updateRates,
          expectedCanRetry: true,
        ),
        (
          label: 'ServerFailure 503 se reintenta',
          failure: ServerFailure(message: ErrorMapper.updateRates, code: 503),
          expectedMessage: ErrorMapper.updateRates,
          expectedCanRetry: true,
        ),
        (
          label: 'ServerFailure sin código no se reintenta',
          failure: ServerFailure(message: ErrorMapper.updateRates, code: null),
          expectedMessage: ErrorMapper.updateRates,
          expectedCanRetry: false,
        ),
        (
          label: 'ServerFailure 0 no se reintenta',
          failure: ServerFailure(message: ErrorMapper.updateRates, code: 0),
          expectedMessage: ErrorMapper.updateRates,
          expectedCanRetry: false,
        ),
        (
          label: 'ParseFailure no se reintenta y usa copy canónico',
          failure: ParseFailure(),
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
          label: 'ValidationFailure de monto usa copy de monto',
          failure: ValidationFailure(message: ErrorMapper.invalidAmount),
          expectedMessage: ErrorMapper.invalidAmount,
          expectedCanRetry: false,
        ),
        (
          label: 'ValidationFailure de tasa usa copy de §13.4',
          // D-1: §13.4 gana sobre ADR 0004
          // ("No pudimos calcular con esta tasa.").
          failure: ValidationFailure(message: ErrorMapper.invalidRate),
          expectedMessage: ErrorMapper.invalidRate,
          expectedCanRetry: false,
        ),
        (
          label: 'ValidationFailure con mensaje por defecto se normaliza',
          failure: ValidationFailure(),
          expectedMessage: ErrorMapper.invalidAmount,
          expectedCanRetry: false,
        ),
      ]);
    });

    group('mensajes no vacíos', () {
      final failures = <Failure>[
        const NetworkFailure(),
        const ServerFailure(message: ErrorMapper.updateRates, code: 401),
        const ParseFailure(),
        const CacheFailure(),
        const ValidationFailure(),
      ];

      for (final failure in failures) {
        test('${failure.runtimeType} produce mensaje no vacío', () {
          expect(failure.message, isNotEmpty);
          expect(ErrorMapper.map(failure).message, isNotEmpty);
        });
      }
    });

    group('fromException', () {
      _checkFromException(const <_FromExceptionCase>[
        (
          label: 'NetworkException -> NetworkFailure canónico',
          exception: NetworkException(message: 'socket error'),
          expectedFailure: NetworkFailure(message: ErrorMapper.updateRates),
        ),
        (
          label: 'ServerException conserva statusCode como code',
          exception: ServerException(
            message: 'PostgREST: permission denied',
            statusCode: 401,
          ),
          expectedFailure: ServerFailure(
            message: ErrorMapper.updateRates,
            code: 401,
          ),
        ),
        (
          label: 'ServerException 500 conserva code',
          exception: ServerException(message: 'boom', statusCode: 500),
          expectedFailure: ServerFailure(
            message: ErrorMapper.updateRates,
            code: 500,
          ),
        ),
        (
          label: 'ParseException -> ParseFailure canónico',
          exception: ParseException(message: 'rate_value'),
          expectedFailure: ParseFailure(message: ErrorMapper.updateRates),
        ),
        (
          label: 'CacheException -> CacheFailure canónico',
          exception: CacheException(message: 'disk'),
          expectedFailure: CacheFailure(message: ErrorMapper.updateRates),
        ),
        (
          label: 'ValidationException de monto',
          exception: ValidationException(message: 'bad amount'),
          expectedFailure: ValidationFailure(
            message: ErrorMapper.invalidAmount,
          ),
        ),
        (
          label: 'ValidationException de tasa conserva el mensaje canónico',
          exception: ValidationException(message: ErrorMapper.invalidRate),
          expectedFailure: ValidationFailure(message: ErrorMapper.invalidRate),
        ),
      ]);
    });

    group('detalle técnico no filtra a la UI', () {
      test('el body de ServerException no aparece en el mensaje mapeado', () {
        const detail = 'PostgREST: permission denied for table rates';
        final failure = ErrorMapper.fromException(
          const ServerException(message: detail, statusCode: 500),
        );
        final info = ErrorMapper.map(failure);

        expect(info.message, isNot(contains('PostgREST')));
        expect(info.message, isNot(contains(detail)));
        expect(info.message, ErrorMapper.updateRates);
      });

      test('el detalle de NetworkException no aparece en el mensaje', () {
        final failure = ErrorMapper.fromException(
          const NetworkException(message: 'SocketException: timeout'),
        );
        final info = ErrorMapper.map(failure);

        expect(info.message, isNot(contains('SocketException')));
        expect(info.message, ErrorMapper.updateRates);
      });
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

void _checkFromException(List<_FromExceptionCase> cases) {
  for (final testCase in cases) {
    test(testCase.label, () {
      final failure = ErrorMapper.fromException(testCase.exception);
      expect(failure, testCase.expectedFailure);
    });
  }
}
