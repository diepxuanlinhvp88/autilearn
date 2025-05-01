import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/quiz_repository.dart';
import 'quiz_event.dart';
import 'quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final QuizRepository quizRepository;

  QuizBloc({required this.quizRepository}) : super(const QuizInitial()) {
    on<LoadQuizzes>(_onLoadQuizzes);
    on<LoadQuizById>(_onLoadQuizById);
    on<CreateQuiz>(_onCreateQuiz);
    on<UpdateQuiz>(_onUpdateQuiz);
    on<DeleteQuiz>(_onDeleteQuiz);
    on<LoadQuestions>(_onLoadQuestions);
    on<CreateQuestion>(_onCreateQuestion);
    on<UpdateQuestion>(_onUpdateQuestion);
    on<DeleteQuestion>(_onDeleteQuestion);
  }

  Future<void> _onLoadQuizzes(
    LoadQuizzes event,
    Emitter<QuizState> emit,
  ) async {
    emit(const QuizLoading());
    final result = await quizRepository.getQuizzes(
      type: event.type,
      difficulty: event.difficulty,
      category: event.category,
      isPublished: event.isPublished,
      creatorId: event.creatorId,
    );

    result.fold(
      (error) => emit(QuizError(error)),
      (quizzes) => emit(QuizzesLoaded(quizzes)),
    );
  }

  Future<void> _onLoadQuizById(
    LoadQuizById event,
    Emitter<QuizState> emit,
  ) async {
    emit(const QuizLoading());
    final result = await quizRepository.getQuizById(event.quizId);

    result.fold(
      (error) => emit(QuizError(error)),
      (quiz) => emit(QuizLoaded(quiz)),
    );
  }

  Future<void> _onCreateQuiz(
    CreateQuiz event,
    Emitter<QuizState> emit,
  ) async {
    emit(const QuizLoading());
    final result = await quizRepository.createQuiz(event.quiz);

    result.fold(
      (error) => emit(QuizError(error)),
      (quizId) => emit(QuizOperationSuccess('Quiz created successfully')),
    );
  }

  Future<void> _onUpdateQuiz(
    UpdateQuiz event,
    Emitter<QuizState> emit,
  ) async {
    emit(const QuizLoading());
    final result = await quizRepository.updateQuiz(event.quiz);

    result.fold(
      (error) => emit(QuizError(error)),
      (success) => emit(QuizOperationSuccess('Quiz updated successfully')),
    );
  }

  Future<void> _onDeleteQuiz(
    DeleteQuiz event,
    Emitter<QuizState> emit,
  ) async {
    emit(const QuizLoading());
    final result = await quizRepository.deleteQuiz(event.quizId);

    result.fold(
      (error) => emit(QuizError(error)),
      (success) => emit(QuizOperationSuccess('Quiz deleted successfully')),
    );
  }

  Future<void> _onLoadQuestions(
    LoadQuestions event,
    Emitter<QuizState> emit,
  ) async {
    emit(const QuizLoading());
    final result = await quizRepository.getQuestionsByQuizId(event.quizId);

    result.fold(
      (error) => emit(QuizError(error)),
      (questions) => emit(QuestionsLoaded(questions)),
    );
  }

  Future<void> _onCreateQuestion(
    CreateQuestion event,
    Emitter<QuizState> emit,
  ) async {
    emit(const QuizLoading());
    final result = await quizRepository.createQuestion(event.question);

    result.fold(
      (error) => emit(QuizError(error)),
      (questionId) => emit(QuizOperationSuccess('Question created successfully')),
    );
  }

  Future<void> _onUpdateQuestion(
    UpdateQuestion event,
    Emitter<QuizState> emit,
  ) async {
    emit(const QuizLoading());
    final result = await quizRepository.updateQuestion(event.question);

    result.fold(
      (error) => emit(QuizError(error)),
      (success) => emit(QuizOperationSuccess('Question updated successfully')),
    );
  }

  Future<void> _onDeleteQuestion(
    DeleteQuestion event,
    Emitter<QuizState> emit,
  ) async {
    emit(const QuizLoading());
    final result = await quizRepository.deleteQuestion(event.questionId);

    result.fold(
      (error) => emit(QuizError(error)),
      (success) => emit(QuizOperationSuccess('Question deleted successfully')),
    );
  }
}
