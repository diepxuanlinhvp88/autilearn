import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserProfile extends UserEvent {
  final String userId;

  const LoadUserProfile(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadUserStats extends UserEvent {
  final String userId;

  const LoadUserStats(this.userId);

  @override
  List<Object?> get props => [userId];
}
