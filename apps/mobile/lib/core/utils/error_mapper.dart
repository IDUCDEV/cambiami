import 'package:cambiami/core/error/exceptions.dart';
import 'package:cambiami/core/error/failures.dart';

/// Texto y acción que la presentación necesita para dibujar un error.
typedef ErrorInfo = ({String message, bool canRetry});

/// Único productor de mensajes de error (`DESIGN_SYSTEM.md` §13.4, ADR 0004).
abstract final class ErrorMapper {
  /// Fallo al actualizar/consultar tasas. Copy canónico de §13.4.
  static const String updateRates = 'No pudimos actualizar las tasas.';

  /// Estado de vista vacía. No es un [Failure]; se usa desde el cubit.
  static const String noRates = 'No hay tasas publicadas.';

  /// Entrada de monto inválida.
  static const String invalidAmount = 'Ingresa un monto válido.';

  /// Tasa de cálculo inválida (0 o negativa). Copy canónico de §13.4.
  static const String invalidRate = 'No pudimos calcular con esta tasa.';

  /// Etiqueta de la acción de reintento.
  static const String retry = 'Reintentar';

  /// Traduce una excepción de datos a un fallo de dominio.
  ///
  /// El detalle técnico de la excepción (p. ej. el body HTTP) no se copia al
  /// [Failure.message]; debe registrarse en el log antes de llamar a este
  /// método si se necesita conservar.
  static Failure fromException(Object exception) {
    if (exception is NetworkException) {
      return const NetworkFailure(message: updateRates);
    }
    if (exception is ServerException) {
      return ServerFailure(message: updateRates, code: exception.statusCode);
    }
    if (exception is ParseException) {
      return const ParseFailure(message: updateRates);
    }
    if (exception is CacheException) {
      return const CacheFailure(message: updateRates);
    }
    if (exception is ValidationException) {
      final message = exception.message == invalidRate
          ? invalidRate
          : invalidAmount;
      return ValidationFailure(message: message);
    }

    // Excepción no contemplada: se trata como fallo genérico sin reintento
    // implícito; el copy sigue siendo el canónico.
    return const CacheFailure(message: updateRates);
  }

  /// Convierte un fallo en copy canónico y bandera de reintento.
  /// fronteta dominio presentacion
  static ErrorInfo map(Failure failure) {
    return (message: _messageFor(failure), canRetry: _canRetry(failure));
  }

  static String _messageFor(Failure failure) {
    if (failure is ValidationFailure) {
      // Sin `field`, el discriminador es el propio mensaje canónico.
      return failure.message == invalidRate ? invalidRate : invalidAmount;
    }
    if (failure is NetworkFailure ||
        failure is ServerFailure ||
        failure is ParseFailure ||
        failure is CacheFailure) {
      // Siempre copy canónico: evita filtrar mensajes técnicos a la UI.
      return updateRates;
    }

    return failure.message.isNotEmpty ? failure.message : updateRates;
  }

  static bool _canRetry(Failure failure) {
    if (failure is NetworkFailure) return true;
    if (failure is ServerFailure) {
      return _serverRetryable(failure.code);
    }
    return false;
  }

  /// 401/403 son de configuración; 5xx puede resolverse al reintentar.
  /// 4xx, código nulo y el resto no se reintentan.
  static bool _serverRetryable(int? code) {
    if (code == null) return false;
    if (code == 401 || code == 403) return false;
    return code >= 500;
  }
}
