import 'package:equatable/equatable.dart';
import '../../../data/models/user_progress_model.dart';

abstract class UserProgressState extends Equatable {
  const UserProgressState();

  @override
  List<Object?> get props => [];
}

class UserProgressInitial extends UserProgressState {
  const UserProgressInitial();
}

class UserProgressLoading extends UserProgressState {
  const UserProgressLoading();
}

class UserProgressLoaded extends UserProgressState {
  final List<UserProgressModel> progress;
  final int totalQuestions;

  const UserProgressLoaded({
    required this.progress,
    required this.totalQuestions,
  });

  @override
  List<Object?> get props => [progress, totalQuestions];
}

class QuizProgressLoaded extends UserProgressState {
  final UserProgressModel progress;

  const QuizProgressLoaded(this.progress);

  @override
  List<Object?> get props => [progress];
}

class UserProgressSaved extends UserProgressState {
  final String progressId;

  const UserProgressSaved(this.progressId);

  @override
  List<Object?> get props => [progressId];
}

class UserProgressError extends UserProgressState {
  final String message;

  const UserProgressError(this.message);

  @override
  List<Object?> get props => [message];
}
