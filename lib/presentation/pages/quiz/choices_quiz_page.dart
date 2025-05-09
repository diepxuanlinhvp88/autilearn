import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/question_model.dart';
import '../../../data/models/user_progress_model.dart';
import '../../../main.dart';
import '../../../presentation/blocs/quiz/quiz_bloc.dart';
import '../../../presentation/blocs/quiz/quiz_event.dart';
import '../../../presentation/blocs/quiz/quiz_state.dart';
import '../../../presentation/blocs/user/user_progress_bloc.dart';
import '../../../presentation/blocs/user/user_progress_event.dart';
import '../../../presentation/blocs/user/user_progress_state.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../presentation/blocs/auth/auth_state.dart';
import '../../../presentation/widgets/quiz/quiz_option_card.dart';
import '../../../core/services/audio_service.dart';
import '../../../presentation/widgets/common/confetti_animation.dart';
import '../quiz/quiz_result_page.dart';

class ChoicesQuizPage extends StatefulWidget {
  final String? quizId;

  const ChoicesQuizPage({super.key, this.quizId});

  @override
  State<ChoicesQuizPage> createState() => _ChoicesQuizPageState();
}

class _ChoicesQuizPageState extends State<ChoicesQuizPage> {
  int _currentQuestionIndex = 0;
  String? _selectedOptionId;
  bool _isAnswerChecked = false;
  bool _isCorrect = false;
  int _score = 0;
  int _totalQuestions = 0;
  List<QuestionModel> _questions = [];

  final AudioService _audioService = getIt<AudioService>();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<QuizBloc>(
          create: (context) {
            final bloc = getIt<QuizBloc>();
            if (widget.quizId != null) {
              // Load questions for the specific quiz
              bloc.add(LoadQuestions(widget.quizId!));
            } else {
              // Load all published quizzes of type 'choices_quiz'
              bloc.add(const LoadQuizzes(type: 'choices_quiz', isPublished: true));
            }
            return bloc;
          },
        ),
        BlocProvider<UserProgressBloc>(
          create: (context) => getIt<UserProgressBloc>(),
        ),
      ],
      child: BlocListener<UserProgressBloc, UserProgressState>(
        listener: (context, state) {
          if (state is UserProgressSaved) {
            print('ChoicesQuizPage: User progress saved successfully with ID: ${state.progressId}');
          } else if (state is UserProgressError) {
            print('ChoicesQuizPage: Error saving user progress: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi khi lưu tiến trình: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
        appBar: AppBar(
          title: const Text('Bài học lựa chọn'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chọn hình ảnh phù hợp với câu hỏi'),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<QuizBloc, QuizState>(
          listener: (context, state) {
            if (state is QuizzesLoaded && state.quizzes.isNotEmpty) {
              // Load questions for the first quiz of type 'choices'
              context.read<QuizBloc>().add(LoadQuestions(state.quizzes.first.id));
            } else if (state is QuestionsLoaded) {
              setState(() {
                _questions = state.questions;
                _totalQuestions = state.questions.length;
              });
            }
          },
          builder: (context, state) {
            if (state is QuizLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is QuestionsLoaded || _questions.isNotEmpty) {
              if (_questions.isEmpty) {
                return const Center(
                  child: Text('Không có câu hỏi nào'),
                );
              }

              // For demo purposes, create sample questions if none are loaded
              // and no specific quiz ID was provided
              if (_questions.isEmpty && widget.quizId == null) {
                _questions = _createSampleQuestions();
                _totalQuestions = _questions.length;
              }

              final currentQuestion = _questions[_currentQuestionIndex];
              return Column(
                children: [
                  // Progress indicator
                  LinearProgressIndicator(
                    value: (_currentQuestionIndex + 1) / _totalQuestions,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Câu hỏi ${_currentQuestionIndex + 1}/$_totalQuestions',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Điểm: $_score',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Question
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Question text
                          Text(
                            currentQuestion.text,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Question image if available
                          if (currentQuestion.imageUrl != null)
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: NetworkImage(currentQuestion.imageUrl!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),
                          // Options
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.0,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: currentQuestion.options.length,
                            itemBuilder: (context, index) {
                              final option = currentQuestion.options[index];
                              bool isSelected = option.id == _selectedOptionId;
                              bool isCorrect = _isAnswerChecked && option.id == currentQuestion.correctOptionId;
                              bool isWrong = _isAnswerChecked && isSelected && !isCorrect;

                              return QuizOptionCard(
                                option: option,
                                isSelected: isSelected,
                                isCorrect: isCorrect,
                                isWrong: isWrong,
                                onTap: _isAnswerChecked
                                    ? null
                                    : () {
                                        setState(() {
                                          _selectedOptionId = option.id;
                                        });
                                      },
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          // Feedback message
                          if (_isAnswerChecked)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _isCorrect ? Colors.green[100] : Colors.red[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _isCorrect ? Icons.check_circle : Icons.cancel,
                                    color: _isCorrect ? Colors.green : Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _isCorrect
                                          ? 'Chúc mừng! Bạn đã trả lời đúng.'
                                          : 'Sai rồi! Hãy thử lại nhé.',
                                      style: TextStyle(
                                        color: _isCorrect ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),
                          // Hint
                          if (_isAnswerChecked && !_isCorrect && currentQuestion.hint != null)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.lightbulb,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Gợi ý: ${currentQuestion.hint}',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Bottom buttons
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        if (_currentQuestionIndex > 0 && !_isAnswerChecked)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _currentQuestionIndex--;
                                  _selectedOptionId = null;
                                  _isAnswerChecked = false;
                                });
                              },
                              child: const Text('Quay lại'),
                            ),
                          ),
                        if (_currentQuestionIndex > 0 && !_isAnswerChecked)
                          const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _selectedOptionId == null
                                ? null
                                : () {
                                    if (_isAnswerChecked) {
                                      // Move to next question or finish quiz
                                      if (_currentQuestionIndex < _totalQuestions - 1) {
                                        setState(() {
                                          _currentQuestionIndex++;
                                          _selectedOptionId = null;
                                          _isAnswerChecked = false;
                                        });
                                      } else {
                                        // Show completion dialog
                                        _showCompletionDialog();
                                      }
                                    } else {
                                      // Check answer
                                      final isCorrect = _selectedOptionId == currentQuestion.correctOptionId;
                                      setState(() {
                                        _isAnswerChecked = true;
                                        _isCorrect = isCorrect;
                                        if (isCorrect) {
                                          _score++;
                                          _audioService.playCorrectSound();
                                        } else {
                                          _audioService.playWrongSound();
                                        }
                                      });
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isAnswerChecked ? Colors.blue : Colors.green,
                            ),
                            child: Text(
                              _isAnswerChecked
                                  ? (_currentQuestionIndex < _totalQuestions - 1 ? 'Câu tiếp theo' : 'Hoàn thành')
                                  : 'Kiểm tra',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else if (state is QuizError) {
              return Center(
                child: Text(state.message),
              );
            }

            return const Center(
              child: Text('Không có dữ liệu'),
            );
          },
        ),
      ),
    ));
  }

  void _showCompletionDialog() {
    // Play success sound
    try {
      _audioService.playSuccessSound();
      print('ChoicesQuizPage: Success sound played');
    } catch (e) {
      print('ChoicesQuizPage: Error playing success sound: $e');
    }

    // In ra thông báo để gỡ lỗi
    print('ChoicesQuizPage: Showing completion dialog');
    print('ChoicesQuizPage: Score: $_score/$_totalQuestions');

    // Lưu tiến trình người dùng vào Firebase
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final userId = authState.user.uid;
      final quizId = widget.quizId;

      if (quizId != null) {
        // Tạo danh sách các lần thử câu hỏi
        final attempts = <QuestionAttempt>[];

        // Tính số sao dựa trên điểm số
        final percentage = _score / _totalQuestions;
        int starsEarned = 0;
        if (percentage >= 0.8) {
          starsEarned = 3;
        } else if (percentage >= 0.6) {
          starsEarned = 2;
        } else if (percentage >= 0.4) {
          starsEarned = 1;
        }

        // Tạo mô hình tiến trình
        final progress = UserProgressModel(
          id: '', // ID sẽ được tạo bởi Firebase
          userId: userId,
          quizId: quizId,
          score: _score,
          totalQuestions: _totalQuestions,
          attempts: attempts,
          completedAt: DateTime.now(),
          timeSpentSeconds: 0, // Có thể thêm tính năng đo thời gian sau
          starsEarned: starsEarned,
        );

        // Lưu tiến trình vào Firebase
        try {
          context.read<UserProgressBloc>().add(SaveUserProgress(progress));
          print('ChoicesQuizPage: Saving user progress to Firebase');
        } catch (e) {
          print('ChoicesQuizPage: Error saving user progress: $e');
        }
      }
    }

    // Chuyển đến trang kết quả thay vì hiển thị hộp thoại
    print('ChoicesQuizPage: Navigating to result page');
    try {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => QuizResultPage(
            score: _score,
            totalQuestions: _totalQuestions,
            onRetry: () {
              print('ChoicesQuizPage: onRetry callback called');
              // Sử dụng BuildContext từ trang hiện tại
              Navigator.of(context).pop();
              // Đặt lại trạng thái
              setState(() {
                _currentQuestionIndex = 0;
                _selectedOptionId = null;
                _isAnswerChecked = false;
                _isCorrect = false;
                _score = 0;
              });
            },
            onHome: () {
              print('ChoicesQuizPage: onHome callback called');
              // Sử dụng BuildContext từ trang hiện tại
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ),
      );
    } catch (e) {
      print('ChoicesQuizPage: Error navigating to result page: $e');
      // Nếu có lỗi, hiển thị thông báo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 0.8) {
      return Colors.green;
    } else if (percentage >= 0.6) {
      return Colors.amber;
    } else {
      return Colors.red;
    }
  }

  List<QuestionModel> _createSampleQuestions() {
    return [
      QuestionModel(
        id: '1',
        quizId: 'sample_quiz_id',
        text: 'Đâu là con mèo?',
        type: 'choices',
        options: [
          const AnswerOption(
            id: 'A',
            text: 'Mèo',
            imageUrl: 'https://placekitten.com/200/200',
          ),
          const AnswerOption(
            id: 'B',
            text: 'Chó',
            imageUrl: 'https://placedog.net/200/200',
          ),
          const AnswerOption(
            id: 'C',
            text: 'Gà',
            imageUrl: 'https://via.placeholder.com/200x200?text=Chicken',
          ),
          const AnswerOption(
            id: 'D',
            text: 'Vịt',
            imageUrl: 'https://via.placeholder.com/200x200?text=Duck',
          ),
        ],
        correctOptionId: 'A',
        order: 1,
        hint: 'Con vật này kêu "meo meo"',
      ),
      QuestionModel(
        id: '2',
        quizId: 'sample_quiz_id',
        text: 'Đâu là màu đỏ?',
        type: 'choices',
        options: [
          const AnswerOption(
            id: 'A',
            text: 'Xanh',
            imageUrl: 'https://via.placeholder.com/200x200/0000FF/FFFFFF?text=Blue',
          ),
          const AnswerOption(
            id: 'B',
            text: 'Đỏ',
            imageUrl: 'https://via.placeholder.com/200x200/FF0000/FFFFFF?text=Red',
          ),
          const AnswerOption(
            id: 'C',
            text: 'Vàng',
            imageUrl: 'https://via.placeholder.com/200x200/FFFF00/000000?text=Yellow',
          ),
          const AnswerOption(
            id: 'D',
            text: 'Xanh lá',
            imageUrl: 'https://via.placeholder.com/200x200/00FF00/FFFFFF?text=Green',
          ),
        ],
        correctOptionId: 'B',
        order: 2,
        hint: 'Màu này giống màu của quả táo chín',
      ),
    ];
  }
}
