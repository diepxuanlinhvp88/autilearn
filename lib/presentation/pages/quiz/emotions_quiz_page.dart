import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/question_model.dart';
import '../../../data/models/user_progress_model.dart';
import '../../../main.dart';
import '../../../core/services/audio_service.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/quiz/quiz_bloc.dart';
import '../../blocs/quiz/quiz_event.dart';
import '../../blocs/quiz/quiz_state.dart';
import '../../blocs/user/user_progress_bloc.dart';
import '../../blocs/user/user_progress_event.dart';
import 'quiz_result_page.dart';

class EmotionsQuizPage extends StatefulWidget {
  final String? quizId;

  const EmotionsQuizPage({Key? key, this.quizId}) : super(key: key);

  @override
  State<EmotionsQuizPage> createState() => _EmotionsQuizPageState();
}

class _EmotionsQuizPageState extends State<EmotionsQuizPage> {
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
              // Load all published quizzes of type 'emotions_quiz'
              bloc.add(const LoadQuizzes(type: AppConstants.emotionsQuiz, isPublished: true));
            }
            return bloc;
          },
        ),
        BlocProvider<UserProgressBloc>(
          create: (context) => getIt<UserProgressBloc>(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bài học nhận diện cảm xúc'),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chọn hình ảnh phù hợp với cảm xúc được mô tả'),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<QuizBloc, QuizState>(
          listener: (context, state) {
            if (state is QuizzesLoaded && state.quizzes.isNotEmpty) {
              // Load questions for the first quiz of type 'emotions'
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

              final currentQuestion = _questions[_currentQuestionIndex];
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Progress indicator
                      LinearProgressIndicator(
                        value: (_currentQuestionIndex + 1) / _totalQuestions,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
                        minHeight: 10,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Câu hỏi ${_currentQuestionIndex + 1}/$_totalQuestions',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Question text
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                currentQuestion.text,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (currentQuestion.imageUrl != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: currentQuestion.imageUrl!,
                                      height: 150,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                      errorWidget: (context, url, error) => const Icon(
                                        Icons.error,
                                        color: Colors.red,
                                        size: 50,
                                      ),
                                    ),
                                  ),
                                ),
                              if (currentQuestion.hint != null && currentQuestion.hint!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.lightbulb_outline,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Gợi ý: ${currentQuestion.hint}',
                                          style: const TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: Colors.grey,
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
                      const SizedBox(height: 24),

                      // Options grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: currentQuestion.options.length,
                        itemBuilder: (context, index) {
                          final option = currentQuestion.options[index];
                          final isSelected = _selectedOptionId == option.id;
                          final isCorrect = _isAnswerChecked && option.id == currentQuestion.correctOptionId;
                          final isWrong = _isAnswerChecked && isSelected && !isCorrect;

                          Color borderColor = Colors.grey;
                          if (isSelected) {
                            borderColor = Colors.blue;
                          }
                          if (isCorrect) {
                            borderColor = Colors.green;
                          }
                          if (isWrong) {
                            borderColor = Colors.red;
                          }

                          return GestureDetector(
                            onTap: _isAnswerChecked
                                ? null
                                : () {
                                    setState(() {
                                      _selectedOptionId = option.id;
                                    });
                                  },
                            child: Card(
                              elevation: isSelected ? 8 : 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: borderColor,
                                  width: 3,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(13),
                                      ),
                                      child: option.imageUrl != null
                                          ? CachedNetworkImage(
                                              imageUrl: option.imageUrl!,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => const Center(
                                                child: CircularProgressIndicator(),
                                              ),
                                              errorWidget: (context, url, error) => const Icon(
                                                Icons.error,
                                                color: Colors.red,
                                                size: 50,
                                              ),
                                            )
                                          : Container(
                                              color: Colors.grey[200],
                                              child: const Center(
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey,
                                                  size: 50,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      option.text,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isSelected || isCorrect ? FontWeight.bold : FontWeight.normal,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  if (isCorrect)
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 8.0),
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      ),
                                    ),
                                  if (isWrong)
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 8.0),
                                      child: Icon(
                                        Icons.cancel,
                                        color: Colors.red,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Action buttons
                      if (!_isAnswerChecked)
                        ElevatedButton(
                          onPressed: _selectedOptionId == null
                              ? null
                              : () {
                                  _checkAnswer();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Kiểm tra',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        ElevatedButton(
                          onPressed: () {
                            _nextQuestion();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            _currentQuestionIndex < _totalQuestions - 1 ? 'Câu tiếp theo' : 'Xem kết quả',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            } else if (state is QuizError) {
              return Center(
                child: Text('Lỗi: ${state.message}'),
              );
            } else {
              return const Center(
                child: Text('Không có dữ liệu'),
              );
            }
          },
        ),
      ),
    );
  }

  void _checkAnswer() {
    if (_selectedOptionId == null) return;

    final currentQuestion = _questions[_currentQuestionIndex];
    final isCorrect = _selectedOptionId == currentQuestion.correctOptionId;

    setState(() {
      _isAnswerChecked = true;
      _isCorrect = isCorrect;
      if (isCorrect) {
        _score++;
        // Play correct sound
        _audioService.playCorrectSound();
      } else {
        // Play wrong sound
        _audioService.playWrongSound();
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _totalQuestions - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionId = null;
        _isAnswerChecked = false;
        _isCorrect = false;
      });
    } else {
      _showResult();
    }
  }

  void _showResult() async {
    // Play success sound
    _audioService.playSuccessSound();

    // Save progress if user is authenticated
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated && widget.quizId != null) {
      final userId = authState.user.uid;
      final quizId = widget.quizId!;

      // Create list of question attempts
      final attempts = <QuestionAttempt>[];

      // Calculate stars based on score
      final percentage = _score / _totalQuestions;
      int starsEarned = 0;
      if (percentage >= 0.8) {
        starsEarned = 3;
      } else if (percentage >= 0.6) {
        starsEarned = 2;
      } else if (percentage >= 0.4) {
        starsEarned = 1;
      }

      // Create progress model
      final progress = UserProgressModel(
        id: '',
        userId: userId,
        quizId: widget.quizId ?? '',
        score: _score,
        isCompleted: true,
        startedAt: DateTime.now(),
        completedAt: DateTime.now(),
        answers: Map.fromEntries(
          attempts.asMap().entries.map(
            (entry) => MapEntry(entry.key.toString(), entry.value.toMap()),
          ),
        ),
        totalQuestions: _totalQuestions,
        timeSpentSeconds: 0,
        starsEarned: starsEarned,
      );

      // Save progress
      context.read<UserProgressBloc>().add(SaveUserProgress(progress));
    }

    // Navigate to result page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizResultPage(
          score: _score,
          totalQuestions: _totalQuestions,
          onRetry: () {
            Navigator.of(context).pop();
            setState(() {
              _currentQuestionIndex = 0;
              _selectedOptionId = null;
              _isAnswerChecked = false;
              _isCorrect = false;
              _score = 0;
            });
          },
          onHome: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
    );
  }
}


