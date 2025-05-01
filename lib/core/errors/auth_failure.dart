import 'package:equatable/equatable.dart';

class AuthFailure extends Equatable {
  final String message;

  const AuthFailure._(this.message);

  factory AuthFailure.serverError() => const AuthFailure._('Server error occurred');
  factory AuthFailure.userNotFound() => const AuthFailure._('User not found');
  factory AuthFailure.wrongPassword() => const AuthFailure._('Wrong password');
  factory AuthFailure.emailAlreadyInUse() => const AuthFailure._('Email already in use');
  factory AuthFailure.weakPassword() => const AuthFailure._('Password is too weak');
  factory AuthFailure.invalidEmail() => const AuthFailure._('Invalid email');

  @override
  List<Object?> get props => [message];
}
