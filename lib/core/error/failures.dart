import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String code;

  const Failure({
    required this.message,
    required this.code,
  });

  @override
  List<Object> get props => [message, code];
}

class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    required super.code,
  });
}

class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    required super.code,
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    required super.code,
  });
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    required super.code,
  });
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    required super.message,
    required super.code,
  });
}

// Firebase specific failures
class FirebaseFailure extends Failure {
  const FirebaseFailure({
    required super.message,
    required super.code,
  });
}

class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    required super.code,
  });
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required super.message,
    required super.code,
  });
}
