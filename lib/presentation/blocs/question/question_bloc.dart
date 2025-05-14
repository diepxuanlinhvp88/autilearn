import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/quiz_repository.dart';
import 'question_event.dart';
import 'question_state.dart';

class QuestionBloc extends Bloc<QuestionEvent, QuestionState> {
  final QuizRepository quizRepository;

  QuestionBloc({required this.quizRepository}) : super(QuestionInitial()) {
    on<LoadQuestions>(_onLoadQuestions);
    on<CreateQuestion>(_onCreateQuestion);
    on<UpdateQuestion>(_onUpdateQuestion);
    on<DeleteQuestion>(_onDeleteQuestion);
    on<UpdateQuestionsOrder>(_onUpdateQuestionsOrder);
  }

  Future<void> _onLoadQuestions(
    LoadQuestions event,
    Emitter<QuestionState> emit,
  ) async {
    emit(QuestionLoading());
    try {
      final result = await quizRepository.getQuestionsByQuizId(event.quizId);
      result.fold(
        (error) => emit(QuestionError(error.toString())),
        (questions) => emit(QuestionsLoaded(questions)),
      );
    } catch (e) {
      emit(QuestionError(e.toString()));
    }
  }

  Future<void> _onCreateQuestion(
    CreateQuestion event,
    Emitter<QuestionState> emit,
  ) async {
    emit(QuestionLoading());
    try {
      final result = await quizRepository.createQuestion(event.question);
      result.fold(
        (error) => emit(QuestionError(error.toString())),
        (questionId) async {
          final questionResult = await quizRepository.getQuestionById(questionId);
          questionResult.fold(
            (error) => emit(QuestionError(error.toString())),
            (question) => emit(QuestionCreated(question)),
          );
        },
      );
    } catch (e) {
      emit(QuestionError(e.toString()));
    }
  }

  Future<void> _onUpdateQuestion(
    UpdateQuestion event,
    Emitter<QuestionState> emit,
  ) async {
    emit(QuestionLoading());
    try {
      final result = await quizRepository.updateQuestion(event.question);
      result.fold(
        (error) => emit(QuestionError(error.toString())),
        (success) async {
          if (success) {
            final questionResult = await quizRepository.getQuestionById(event.question.id);
            questionResult.fold(
              (error) => emit(QuestionError(error.toString())),
              (question) => emit(QuestionUpdated(question)),
            );
          } else {
            emit(const QuestionError('Failed to update question'));
          }
        },
      );
    } catch (e) {
      emit(QuestionError(e.toString()));
    }
  }

  Future<void> _onDeleteQuestion(
    DeleteQuestion event,
    Emitter<QuestionState> emit,
  ) async {
    emit(QuestionLoading());
    try {
      final result = await quizRepository.deleteQuestion(event.questionId);
      result.fold(
        (error) => emit(QuestionError(error.toString())),
        (success) => emit(QuestionDeleted(event.questionId)),
      );
    } catch (e) {
      emit(QuestionError(e.toString()));
    }
  }

  Future<void> _onUpdateQuestionsOrder(
    UpdateQuestionsOrder event,
    Emitter<QuestionState> emit,
  ) async {
    emit(QuestionLoading());
    try {
      bool allSuccess = true;
      for (var question in event.questions) {
        final result = await quizRepository.updateQuestion(question);
        result.fold(
          (error) {
            allSuccess = false;
            emit(QuestionError(error.toString()));
            return;
          },
          (success) {
            if (!success) {
              allSuccess = false;
              emit(const QuestionError('Failed to update question order'));
              return;
            }
          },
        );
        if (!allSuccess) break;
      }
      if (allSuccess) {
        emit(QuestionsLoaded(event.questions));
      }
    } catch (e) {
      emit(QuestionError(e.toString()));
    }
  }
} 