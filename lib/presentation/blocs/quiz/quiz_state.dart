import 'package:equatable/equatable.dart';
import '../../../data/models/quiz_model.dart';
import '../../../data/models/question_model.dart';

abstract class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object?> get props => [];
}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

class QuizzesLoaded extends QuizState {
  final List<QuizModel> quizzes;

  const QuizzesLoaded(this.quizzes);

  @override
  List<Object?> get props => [quizzes];
}

class QuizCreated extends QuizState {
  final QuizModel quiz;

  const QuizCreated(this.quiz);

  @override
  List<Object?> get props => [quiz];
}

class QuizUpdated extends QuizState {
  final QuizModel quiz;

  const QuizUpdated(this.quiz);

  @override
  List<Object?> get props => [quiz];
}

class QuizDeleted extends QuizState {
  final String quizId;

  const QuizDeleted(this.quizId);

  @override
  List<Object?> get props => [quizId];
}

class QuizLoaded extends QuizState {
  final QuizModel quiz;

  const QuizLoaded(this.quiz);

  @override
  List<Object?> get props => [quiz];
}

class QuestionsLoaded extends QuizState {
  final List<QuestionModel> questions;

  const QuestionsLoaded(this.questions);

  @override
  List<Object?> get props => [questions];
}

class QuizOperationSuccess extends QuizState {
  final String message;
  final dynamic data;

  const QuizOperationSuccess(this.message, {this.data});

  @override
  List<Object?> get props => [message, data];
}

class QuizError extends QuizState {
  final String message;

  const QuizError(this.message);

  @override
  List<Object?> get props => [message];
}
