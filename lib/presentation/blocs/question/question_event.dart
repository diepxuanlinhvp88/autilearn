import 'package:equatable/equatable.dart';
import '../../../data/models/question_model.dart';

abstract class QuestionEvent extends Equatable {
  const QuestionEvent();

  @override
  List<Object?> get props => [];
}

class LoadQuestions extends QuestionEvent {
  final String quizId;

  const LoadQuestions(this.quizId);

  @override
  List<Object?> get props => [quizId];
}

class CreateQuestion extends QuestionEvent {
  final QuestionModel question;

  const CreateQuestion(this.question);

  @override
  List<Object?> get props => [question];
}

class UpdateQuestion extends QuestionEvent {
  final QuestionModel question;

  const UpdateQuestion(this.question);

  @override
  List<Object?> get props => [question];
}

class DeleteQuestion extends QuestionEvent {
  final String questionId;

  const DeleteQuestion(this.questionId);

  @override
  List<Object?> get props => [questionId];
}

class UpdateQuestionsOrder extends QuestionEvent {
  final List<QuestionModel> questions;

  const UpdateQuestionsOrder(this.questions);

  @override
  List<Object?> get props => [questions];
} 