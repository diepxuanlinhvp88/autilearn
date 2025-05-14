import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String role;

  const RegisterRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, name, role];
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

class EnsureUserInFirestore extends AuthEvent {
  final String userId;
  final String? name;
  final String? email;
  final String role;

  const EnsureUserInFirestore({
    required this.userId,
    this.name,
    this.email,
    required this.role,
  });

  @override
  List<Object?> get props => [userId, name, email, role];
}

class RefreshUserInfo extends AuthEvent {
  final String userId;

  const RefreshUserInfo(this.userId);

  @override
  List<Object?> get props => [userId];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String role;

  const SignUpRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
  });

  @override
  List<Object> get props => [email, password, name, role];
}

class ResetPasswordRequested extends AuthEvent {
  final String email;

  const ResetPasswordRequested({
    required this.email,
  });

  @override
  List<Object> get props => [email];
}
