import 'package:equatable/equatable.dart';
import '../../../data/models/quiz_model.dart';
import '../../../data/models/question_model.dart';

abstract class QuizEvent extends Equatable {
  const QuizEvent();

  @override
  List<Object?> get props => [];
}

class LoadQuizzes extends QuizEvent {
  final String? type;
  final String? difficulty;
  final String? category;
  final bool? isPublished;
  final String? creatorId;

  const LoadQuizzes({
    this.type,
    this.difficulty,
    this.category,
    this.isPublished,
    this.creatorId,
  });

  @override
  List<Object?> get props => [type, difficulty, category, isPublished, creatorId];
}

class LoadQuizById extends QuizEvent {
  final String quizId;

  const LoadQuizById(this.quizId);

  @override
  List<Object?> get props => [quizId];
}

class CreateQuiz extends QuizEvent {
  final QuizModel quiz;

  const CreateQuiz(this.quiz);

  @override
  List<Object?> get props => [quiz];
}

class UpdateQuiz extends QuizEvent {
  final QuizModel quiz;

  const UpdateQuiz(this.quiz);

  @override
  List<Object?> get props => [quiz];
}

class DeleteQuiz extends QuizEvent {
  final String quizId;

  const DeleteQuiz(this.quizId);

  @override
  List<Object?> get props => [quizId];
}

class LoadQuestions extends QuizEvent {
  final String quizId;

  const LoadQuestions(this.quizId);

  @override
  List<Object?> get props => [quizId];
}

class CreateQuestion extends QuizEvent {
  final QuestionModel question;

  const CreateQuestion(this.question);

  @override
  List<Object?> get props => [question];
}

class UpdateQuestion extends QuizEvent {
  final QuestionModel question;

  const UpdateQuestion(this.question);

  @override
  List<Object?> get props => [question];
}

class DeleteQuestion extends QuizEvent {
  final String questionId;

  const DeleteQuestion(this.questionId);

  @override
  List<Object?> get props => [questionId];
}
