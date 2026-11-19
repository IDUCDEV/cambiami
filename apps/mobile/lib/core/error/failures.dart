import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure({required this.message, this.code});

  final String message;
  final int? code;

  @override
  List<Object?> get props => [message, code];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, required super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection', super.code});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache failure', super.code});
}

class ValidationFailure extends Failure {
  const ValidationFailure({super.message = 'Validation failure', super.code});
}

class ParseFailure extends Failure {
  const ParseFailure({super.message = 'Parse failure', super.code});
}
