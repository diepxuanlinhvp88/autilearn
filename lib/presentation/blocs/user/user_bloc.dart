import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/quiz_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;
  final QuizRepository quizRepository;

  UserBloc({
    required this.userRepository,
    required this.quizRepository,
  }) : super(const UserInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<LoadUserStats>(_onLoadUserStats);
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserState> emit,
  ) async {
    // Kiểm tra xem đã có dữ liệu người dùng chưa
    if (state is UserProfileLoaded) {
      print('User profile already loaded, skipping fetch');
      return;
    }

    print('Loading user profile for userId: ${event.userId}');
    emit(const UserLoading());
    final result = await userRepository.getUserById(event.userId);

    result.fold(
      (error) {
        print('Error loading user profile: $error');

        // Nếu lỗi là 'User not found', tạo người dùng mới trong Firestore
        if (error == 'User not found') {
          // Không emit lỗi, để trang hiển thị bình thường
          // Và để SplashPage hoặc LoginPage tạo người dùng
          emit(const UserInitial());
        } else {
          emit(UserError(error));
        }
      },
      (user) {
        print('User profile loaded: ${user.name}, role: ${user.role}');
        emit(UserProfileLoaded(user));
      },
    );
  }

  Future<void> _onLoadUserStats(
    LoadUserStats event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());

    // Lấy danh sách bài học đã tạo
    final quizzesResult = await quizRepository.getQuizzes(creatorId: event.userId);

    quizzesResult.fold(
      (error) => emit(UserError(error)),
      (quizzes) {
        // Tính toán các thống kê
        final createdQuizCount = quizzes.length;
        final publishedQuizCount = quizzes.where((quiz) => quiz.isPublished).length;

        // Tính tổng số câu hỏi
        int totalQuestions = 0;
        for (final quiz in quizzes) {
          totalQuestions += quiz.questionCount;
        }

        // Phân loại bài học theo loại
        final choicesQuizCount = quizzes.where((quiz) => quiz.type == 'choices_quiz').length;
        final pairingQuizCount = quizzes.where((quiz) => quiz.type == 'pairing_quiz').length;
        final sequentialQuizCount = quizzes.where((quiz) => quiz.type == 'sequential_quiz').length;

        emit(UserStatsLoaded(
          createdQuizCount: createdQuizCount,
          publishedQuizCount: publishedQuizCount,
          totalQuestions: totalQuestions,
          choicesQuizCount: choicesQuizCount,
          pairingQuizCount: pairingQuizCount,
          sequentialQuizCount: sequentialQuizCount,
        ));
      },
    );
  }
}
