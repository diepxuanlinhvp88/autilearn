import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {
  const UserInitial();
}

class UserLoading extends UserState {
  const UserLoading();
}

class UserProfileLoaded extends UserState {
  final UserModel user;

  const UserProfileLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class UserStatsLoaded extends UserState {
  final int createdQuizCount;
  final int publishedQuizCount;
  final int totalQuestions;
  final int choicesQuizCount;
  final int pairingQuizCount;
  final int sequentialQuizCount;

  const UserStatsLoaded({
    required this.createdQuizCount,
    required this.publishedQuizCount,
    required this.totalQuestions,
    required this.choicesQuizCount,
    required this.pairingQuizCount,
    required this.sequentialQuizCount,
  });

  @override
  List<Object?> get props => [
        createdQuizCount,
        publishedQuizCount,
        totalQuestions,
        choicesQuizCount,
        pairingQuizCount,
        sequentialQuizCount,
      ];
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}
