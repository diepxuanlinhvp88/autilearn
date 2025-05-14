import 'dart:math' as Math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/quiz_model.dart';
import '../../../data/repositories/quiz_repository.dart';
import 'quiz_event.dart';
import 'quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final QuizRepository quizRepository;

  QuizBloc({required this.quizRepository}) : super(QuizInitial()) {
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

  Future<void> _onLoadQuizzes(LoadQuizzes event, Emitter<QuizState> emit) async {
    emit(QuizLoading());
    try {
      final result = await quizRepository.getQuizzes(
        isPublished: event.isPublished,
        creatorId: event.creatorId,
      );
      result.fold(
        (error) => emit(QuizError(error.toString())),
        (quizzes) => emit(QuizzesLoaded(quizzes)),
      );
    } catch (e) {
      emit(QuizError(e.toString()));
    }
  }

  Future<void> _onLoadQuizById(
    LoadQuizById event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());
    final result = await quizRepository.getQuizById(event.quizId);

    result.fold(
      (error) => emit(QuizError(error.toString())),
      (quiz) => emit(QuizLoaded(quiz)),
    );
  }

  Future<void> _onCreateQuiz(CreateQuiz event, Emitter<QuizState> emit) async {
    emit(QuizLoading());
    try {
      // 1. Create quiz and get ID
      final result = await quizRepository.createQuiz(event.quiz);
      
      await result.fold(
        (error) async {
          emit(QuizError(error.toString()));
          return null;
        },
        (quizId) async {
          // 2. Get the created quiz
          final quizResult = await quizRepository.getQuizById(quizId);
          
          return quizResult.fold(
            (error) => emit(QuizError(error.toString())),
            (quiz) => emit(QuizCreated(quiz)),
          );
        },
      );
    } catch (e) {
      emit(QuizError(e.toString()));
    }
  }

  Future<void> _onUpdateQuiz(UpdateQuiz event, Emitter<QuizState> emit) async {
    emit(QuizLoading());
    try {
      // 1. Update quiz
      final result = await quizRepository.updateQuiz(event.quiz);
      
      await result.fold(
        (error) async {
          emit(QuizError(error.toString()));
          return null;
        },
        (success) async {
          if (success) {
            // 2. Get the updated quiz
            final quizResult = await quizRepository.getQuizById(event.quiz.id);
            
            return quizResult.fold(
              (error) => emit(QuizError(error.toString())),
              (quiz) => emit(QuizUpdated(quiz)),
            );
          } else {
            emit(QuizError('Failed to update quiz'));
          }
        },
      );
    } catch (e) {
      emit(QuizError(e.toString()));
    }
  }

  Future<void> _onDeleteQuiz(DeleteQuiz event, Emitter<QuizState> emit) async {
    emit(QuizLoading());
    try {
      final result = await quizRepository.deleteQuiz(event.quizId);
      result.fold(
        (error) => emit(QuizError(error.toString())),
        (_) => emit(QuizDeleted(event.quizId)),
      );
    } catch (e) {
      emit(QuizError(e.toString()));
    }
  }

  Future<void> _onLoadQuestions(
    LoadQuestions event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());
    print('Loading questions for quiz ID: ${event.quizId}');

    // 1. Get questions
    final result = await quizRepository.getQuestionsByQuizId(event.quizId);

    await result.fold(
      (error) async {
        print('Error loading questions: $error');
        emit(QuizError(error.toString()));
        return null;
      },
      (questions) async {
        print('Loaded ${questions.length} questions');

        // 2. Get the quiz
        final quizResult = await quizRepository.getQuizById(event.quizId);

        return await quizResult.fold(
          (error) {
            print('Error getting quiz: $error');
            emit(QuestionsLoaded(questions));
            return null;
          },
          (quiz) async {
            // 3. Check if question count needs updating
            if (quiz.questionCount != questions.length) {
              print('Updating quiz question count from ${quiz.questionCount} to ${questions.length}');

              // 4. Update question count
              final updatedQuiz = quiz.copyWith(
                questionCount: questions.length,
                updatedAt: DateTime.now(),
              );

              // 5. Save updated quiz
              await quizRepository.updateQuiz(updatedQuiz);
            }

            emit(QuestionsLoaded(questions));
            return questions;
          },
        );
      },
    );
  }

  Future<void> _onCreateQuestion(
    CreateQuestion event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());
    print('Creating question for quiz ID: ${event.question.quizId}');

    // 1. Create question
    final result = await quizRepository.createQuestion(event.question);

    await result.fold(
      (error) async {
        print('Error creating question: $error');
        emit(QuizError(error.toString()));
        return null;
      },
      (questionId) async {
        print('Question created with ID: $questionId');

        // 2. Get the quiz
        final quizResult = await quizRepository.getQuizById(event.question.quizId);

        return await quizResult.fold(
          (error) {
            print('Error getting quiz: $error');
            emit(QuizError(error.toString()));
            return null;
          },
          (quiz) async {
            // 3. Update question count
            final updatedQuiz = quiz.copyWith(
              questionCount: quiz.questionCount + 1,
              updatedAt: DateTime.now(),
            );

            print('Updating quiz with new question count: ${updatedQuiz.questionCount}');

            // 4. Save updated quiz
            final updateResult = await quizRepository.updateQuiz(updatedQuiz);

            return updateResult.fold(
              (error) {
                print('Error updating quiz: $error');
                emit(QuizError(error.toString()));
                return null;
              },
              (success) {
                print('Quiz updated successfully');
                emit(QuizOperationSuccess('Question created successfully'));
                return questionId;
              },
            );
          },
        );
      },
    );
  }

  Future<void> _onUpdateQuestion(
    UpdateQuestion event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());
    print('QuizBloc: Updating question with ID: ${event.question.id}');
    print('QuizBloc: Question data: ${event.question}');

    final result = await quizRepository.updateQuestion(event.question);

    result.fold(
      (error) {
        print('QuizBloc: Error updating question: $error');
        emit(QuizError(error.toString()));
      },
      (success) {
        print('QuizBloc: Question updated successfully');
        emit(QuizOperationSuccess('Question updated successfully'));
      },
    );
  }

  Future<void> _onDeleteQuestion(
    DeleteQuestion event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());
    print('Deleting question with ID: ${event.questionId}');

    // 1. Get the question to find its quiz ID
    final questionResult = await quizRepository.getQuestionById(event.questionId);

    await questionResult.fold(
      (error) async {
        print('Error getting question: $error');
        emit(QuizError(error.toString()));
        return null;
      },
      (question) async {
        final quizId = question.quizId;
        print('Question belongs to quiz ID: $quizId');

        // 2. Delete the question
        final deleteResult = await quizRepository.deleteQuestion(event.questionId);

        return await deleteResult.fold(
          (error) {
            print('Error deleting question: $error');
            emit(QuizError(error.toString()));
            return null;
          },
          (success) async {
            // 3. Get the quiz
            final quizResult = await quizRepository.getQuizById(quizId);

            return await quizResult.fold(
              (error) {
                print('Error getting quiz: $error');
                emit(QuizError(error.toString()));
                return null;
              },
              (quiz) async {
                // 4. Update question count
                final updatedQuiz = quiz.copyWith(
                  questionCount: Math.max(0, quiz.questionCount - 1),
                  updatedAt: DateTime.now(),
                );

                print('Updating quiz with new question count: ${updatedQuiz.questionCount}');

                // 5. Save updated quiz
                final updateResult = await quizRepository.updateQuiz(updatedQuiz);

                return updateResult.fold(
                  (error) {
                    print('Error updating quiz: $error');
                    emit(QuizError(error.toString()));
                    return null;
                  },
                  (success) {
                    print('Quiz updated successfully');
                    emit(QuizOperationSuccess('Question deleted successfully'));
                    return true;
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
