import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/badge_model.dart';
import '../../../data/models/quiz_model.dart';

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
  final BadgeModel? currentBadge;

  const UserProfileLoaded({
    required this.user,
    this.currentBadge,
  });

  @override
  List<Object?> get props => [user, currentBadge];
}

class UserStatsLoaded extends UserState {
  final List<QuizModel> createdQuizzes;
  final int totalQuizzes;
  final int completedQuizzes;
  final double averageScore;
  final int createdQuizCount;
  final int publishedQuizCount;
  final int totalQuestions;
  final int choicesQuizCount;
  final int pairingQuizCount;
  final int sequentialQuizCount;

  const UserStatsLoaded({
    required this.createdQuizzes,
    required this.totalQuizzes,
    required this.completedQuizzes,
    required this.averageScore,
    required this.createdQuizCount,
    required this.publishedQuizCount,
    required this.totalQuestions,
    required this.choicesQuizCount,
    required this.pairingQuizCount,
    required this.sequentialQuizCount,
  });

  @override
  List<Object?> get props => [
        createdQuizzes,
        totalQuizzes,
        completedQuizzes,
        averageScore,
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

  String get errorMessage => message;

  @override
  List<Object?> get props => [message];
}
