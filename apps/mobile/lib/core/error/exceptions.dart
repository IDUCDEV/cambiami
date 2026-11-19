class ServerException implements Exception {
  const ServerException({required this.message, this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  const NetworkException({required this.message});
  final String message;
  @override
  String toString() => message;
}

class CacheException implements Exception {
  const CacheException({required this.message});
  final String message;

  @override
  String toString() => message;
}

class ParseException implements Exception {
  const ParseException({required this.message});
  final String message;
  @override
  String toString() => message;
}

class ValidationException implements Exception {
  const ValidationException({required this.message});
  final String message;

  @override
  String toString() => message;
}
