/// Excepciones de la capa de datos. Nunca cruzan a dominio.
sealed class AppException implements Exception {
  const AppException();
}

/// Fallo de red/conectividad. [detail] es técnico (para log), no para UI.
final class NetworkException extends AppException {
  const NetworkException([this.detail]);
  final String? detail;

  @override
  String toString() => detail ?? 'NetworkException';
}

/// Error HTTP/servidor. [code] gobierna el reintento; [detail] (body) no va a UI.
final class ServerException extends AppException {
  const ServerException(this.code, [this.detail]);
  final int code;
  final String? detail;

  @override
  String toString() => detail ?? 'ServerException($code)';
}

/// Error al parsear/decodificar datos. [field] identifica qué falló.
final class ParseException extends AppException {
  const ParseException([this.field, this.detail]);
  final String? field;
  final String? detail;

  @override
  String toString() => detail ?? field ?? 'ParseException';
}

/// Fallo de lectura/escritura local.
final class CacheException extends AppException {
  const CacheException([this.detail]);
  final String? detail;

  @override
  String toString() => detail ?? 'CacheException';
}

/// Entrada inválida. [field] discrimina el caso ('amount' | 'rate').
final class ValidationException extends AppException {
  const ValidationException([this.field, this.detail]);
  final String? field;
  final String? detail;

  @override
  String toString() => detail ?? field ?? 'ValidationException';
}
