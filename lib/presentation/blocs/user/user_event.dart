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
  final int points;

  const LoadUserStats(this.userId, {this.points = 0});

  @override
  List<Object?> get props => [userId, points];
}

class UpdateUserPoints extends UserEvent {
  final String userId;
  final int newPoints;

  const UpdateUserPoints({
    required this.userId,
    required this.newPoints,
  });

  @override
  List<Object?> get props => [userId, newPoints];
}
