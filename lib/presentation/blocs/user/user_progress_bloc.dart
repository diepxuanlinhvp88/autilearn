import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/quiz_repository.dart';
import 'user_progress_event.dart';
import 'user_progress_state.dart';

class UserProgressBloc extends Bloc<UserProgressEvent, UserProgressState> {
  final QuizRepository quizRepository;

  UserProgressBloc({required this.quizRepository}) : super(const UserProgressInitial()) {
    on<LoadUserProgress>(_onLoadUserProgress);
    on<LoadUserProgressByQuiz>(_onLoadUserProgressByQuiz);
    on<SaveUserProgress>(_onSaveUserProgress);
  }

  Future<void> _onLoadUserProgress(
    LoadUserProgress event,
    Emitter<UserProgressState> emit,
  ) async {
    emit(const UserProgressLoading());
    final result = await quizRepository.getUserProgressByUserId(event.userId);

    result.fold(
      (error) => emit(UserProgressError(error)),
      (progressList) => emit(UserProgressLoaded(progressList)),
    );
  }

  Future<void> _onLoadUserProgressByQuiz(
    LoadUserProgressByQuiz event,
    Emitter<UserProgressState> emit,
  ) async {
    emit(const UserProgressLoading());
    final result = await quizRepository.getUserProgressByQuizId(
      event.userId,
      event.quizId,
    );

    result.fold(
      (error) => emit(UserProgressError(error)),
      (progress) => emit(SingleUserProgressLoaded(progress)),
    );
  }

  Future<void> _onSaveUserProgress(
    SaveUserProgress event,
    Emitter<UserProgressState> emit,
  ) async {
    emit(const UserProgressLoading());
    final result = await quizRepository.saveUserProgress(event.progress);

    result.fold(
      (error) => emit(UserProgressError(error)),
      (progressId) => emit(UserProgressSaved(progressId)),
    );
  }
}
