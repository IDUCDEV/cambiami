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

  /// Discriminadores canónicos para [ValidationFailure]/[ValidationException].
  static const String fieldAmount = 'amount';

  /// Discriminadores canónicos para [ValidationFailure]/[ValidationException].
  static const String fieldRate = 'rate';

  /// Entrada pública desde un `catch (Object)`.
  /// El detalle técnico debe loguearse antes si se necesita conservar.
  static Failure from(Object error) {
    if (error is AppException) {
      return fromAppException(error);
    }
    // Fallback único para errores no modelados.
    return const NetworkFailure();
  }

  /// Traducción de excepciones de datos modeladas.
  static Failure fromAppException(AppException exception) {
    if (exception is NetworkException) {
      return const NetworkFailure();
    }
    if (exception is ServerException) {
      return ServerFailure(exception.code, exception.detail);
    }
    if (exception is ParseException) {
      return ParseFailure(exception.field);
    }
    if (exception is CacheException) {
      return const CacheFailure();
    }
    if (exception is ValidationException) {
      return ValidationFailure(exception.field);
    }

    // Inalcanzable: jerarquía sellada totalmente cubierta.
    throw StateError('AppException no contemplada: $exception');
  }

  /// Convierte un fallo en copy canónico y bandera de reintento.
  static ErrorInfo map(Failure failure) {
    if (failure is NetworkFailure) {
      return (message: updateRates, canRetry: true);
    }
    if (failure is ServerFailure) {
      return (message: updateRates, canRetry: _serverRetryable(failure.code));
    }
    if (failure is ParseFailure) {
      return (message: updateRates, canRetry: false);
    }
    if (failure is CacheFailure) {
      return (message: updateRates, canRetry: false);
    }
    if (failure is ValidationFailure) {
      final message = failure.field == fieldRate ? invalidRate : invalidAmount;
      return (message: message, canRetry: false);
    }

    // Inalcanzable: jerarquía sellada totalmente cubierta.
    throw StateError('Failure no contemplado: $failure');
  }

  /// 401/403 son de configuración; 5xx puede resolverse al reintentar.
  /// 4xx y el resto no se reintentan.
  static bool _serverRetryable(int code) {
    if (code == 401 || code == 403) return false;
    return code >= 500;
  }
}
