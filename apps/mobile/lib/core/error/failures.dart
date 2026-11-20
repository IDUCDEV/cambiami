import 'package:equatable/equatable.dart';

/// Fallo de dominio. No contiene texto: el copy vive en `ErrorMapper`.
sealed class Failure extends Equatable {
  const Failure();

  @override
  List<Object?> get props => const [];
}

final class NetworkFailure extends Failure {
  const NetworkFailure();
}

/// [detail] es solo diagnóstico/log, nunca se muestra en UI.
final class ServerFailure extends Failure {
  const ServerFailure(this.code, [this.detail]);
  final int code;
  final String? detail;

  @override
  List<Object?> get props => [code, detail];
}

/// [field] opcional: qué dato no se pudo interpretar (diagnóstico).
final class ParseFailure extends Failure {
  const ParseFailure([this.field]);
  final String? field;

  @override
  List<Object?> get props => [field];
}

final class CacheFailure extends Failure {
  const CacheFailure();
}

/// [field] discrimina el copy: 'amount' | 'rate' (ver ErrorMapper).
final class ValidationFailure extends Failure {
  const ValidationFailure([this.field]);
  final String? field;

  @override
  List<Object?> get props => [field];
}
