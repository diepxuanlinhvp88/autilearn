import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/quiz_repository.dart';
import '../../../data/models/user_progress_model.dart';
import 'user_progress_event.dart';
import 'user_progress_state.dart';

class UserProgressBloc extends Bloc<UserProgressEvent, UserProgressState> {
  final QuizRepository _quizRepository;

  UserProgressBloc({required QuizRepository quizRepository})
      : _quizRepository = quizRepository,
        super(const UserProgressInitial()) {
    on<LoadUserProgress>(_onLoadUserProgress);
    on<LoadQuizProgress>(_onLoadQuizProgress);
    on<SaveUserProgress>(_onSaveUserProgress);
  }

  Future<void> _onLoadUserProgress(
    LoadUserProgress event,
    Emitter<UserProgressState> emit,
  ) async {
    emit(const UserProgressLoading());

    try {
      final result = await _quizRepository.getUserProgressByUserId(event.userId);
      result.fold(
        (failure) => emit(UserProgressError(failure.toString())),
        (progress) {
          // Calculate total questions from all progress
          final totalQuestions = progress.fold(0, (sum, p) => sum + (p.totalQuestions ?? 0));
          emit(UserProgressLoaded(progress: progress, totalQuestions: totalQuestions));
        },
      );
    } catch (e) {
      emit(UserProgressError(e.toString()));
    }
  }

  Future<void> _onLoadQuizProgress(
    LoadQuizProgress event,
    Emitter<UserProgressState> emit,
  ) async {
    emit(const UserProgressLoading());

    try {
      final result = await _quizRepository.getUserProgressByQuizId(event.userId, event.quizId);
      result.fold(
        (failure) => emit(UserProgressError(failure.toString())),
        (progress) => emit(QuizProgressLoaded(progress)),
      );
    } catch (e) {
      emit(UserProgressError(e.toString()));
    }
  }

  Future<void> _onSaveUserProgress(
    SaveUserProgress event,
    Emitter<UserProgressState> emit,
  ) async {
    emit(const UserProgressLoading());

    try {
      final result = await _quizRepository.saveUserProgress(event.progress);
      result.fold(
        (failure) => emit(UserProgressError(failure.toString())),
        (_) => emit(UserProgressSaved(event.progress.id)),
      );
    } catch (e) {
      emit(UserProgressError(e.toString()));
    }
  }
}
