import 'package:equatable/equatable.dart';
import '../../../data/models/user_progress_model.dart';

abstract class UserProgressEvent extends Equatable {
  const UserProgressEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserProgress extends UserProgressEvent {
  final String userId;

  const LoadUserProgress(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadQuizProgress extends UserProgressEvent {
  final String userId;
  final String quizId;

  const LoadQuizProgress({
    required this.userId,
    required this.quizId,
  });

  @override
  List<Object?> get props => [userId, quizId];
}

class SaveUserProgress extends UserProgressEvent {
  final UserProgressModel progress;

  const SaveUserProgress(this.progress);

  @override
  List<Object?> get props => [progress];
}
