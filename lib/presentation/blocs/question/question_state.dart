import 'package:equatable/equatable.dart';
import '../../../data/models/question_model.dart';

abstract class QuestionState extends Equatable {
  const QuestionState();

  @override
  List<Object?> get props => [];
}

class QuestionInitial extends QuestionState {}

class QuestionLoading extends QuestionState {}

class QuestionsLoaded extends QuestionState {
  final List<QuestionModel> questions;

  const QuestionsLoaded(this.questions);

  @override
  List<Object?> get props => [questions];
}

class QuestionCreated extends QuestionState {
  final QuestionModel question;

  const QuestionCreated(this.question);

  @override
  List<Object?> get props => [question];
}

class QuestionUpdated extends QuestionState {
  final QuestionModel question;

  const QuestionUpdated(this.question);

  @override
  List<Object?> get props => [question];
}

class QuestionDeleted extends QuestionState {
  final String questionId;

  const QuestionDeleted(this.questionId);

  @override
  List<Object?> get props => [questionId];
}

class QuestionError extends QuestionState {
  final String message;

  const QuestionError(this.message);

  @override
  List<Object?> get props => [message];
} 