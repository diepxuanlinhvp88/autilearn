import 'package:equatable/equatable.dart';

abstract class AuthFailure extends Equatable {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object> get props => [message];

  @override
  String toString() => message;
}

class ServerFailure extends AuthFailure {
  const ServerFailure(String message) : super(message);
}

class CacheFailure extends AuthFailure {
  const CacheFailure(String message) : super(message);
}

class NetworkFailure extends AuthFailure {
  const NetworkFailure(String message) : super(message);
}

class ValidationFailure extends AuthFailure {
  const ValidationFailure(String message) : super(message);
}
