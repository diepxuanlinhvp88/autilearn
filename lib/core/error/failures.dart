import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}

class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message);
}

class DatabaseFailure extends Failure {
  final String? indexUrl;

  const DatabaseFailure(String message, {this.indexUrl}) : super(message);

  @override
  List<Object> get props => [message, if (indexUrl != null) indexUrl!];

  /// Kiểm tra xem lỗi có phải là lỗi thiếu index không
  bool get isMissingIndexError => indexUrl != null;
}

class StorageFailure extends Failure {
  const StorageFailure(String message) : super(message);
}