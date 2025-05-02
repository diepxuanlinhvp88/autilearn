import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/question_model.dart';
import '../../../main.dart';
import '../../../presentation/blocs/quiz/quiz_bloc.dart';
import '../../../presentation/blocs/quiz/quiz_event.dart';
import '../../../presentation/blocs/quiz/quiz_state.dart';
import '../../../presentation/widgets/quiz/pairing_item_card.dart';
import '../../../core/services/audio_service.dart';
import '../../../presentation/widgets/common/confetti_animation.dart';

class PairingQuizPage extends StatefulWidget {
  final String? quizId;

  const PairingQuizPage({super.key, this.quizId});

  @override
  State<PairingQuizPage> createState() => _PairingQuizPageState();
}

class _PairingQuizPageState extends State<PairingQuizPage> {
  int _currentQuestionIndex = 0;
  bool _isAnswerChecked = false;
  bool _isCorrect = false;
  int _score = 0;
  int _totalQuestions = 0;
  List<QuestionModel> _questions = [];

  // Pairing state
  String? _selectedLeftItemId;
  String? _selectedRightItemId;
  Map<String, String> _userPairs = {};

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
              // Load all published quizzes of type 'pairing_quiz'
              bloc.add(const LoadQuizzes(type: 'pairing_quiz', isPublished: true));
            }
            return bloc;
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bài học ghép đôi'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nối cặp hình ảnh hoặc từ vựng với định nghĩa'),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<QuizBloc, QuizState>(
          listener: (context, state) {
            if (state is QuizzesLoaded && state.quizzes.isNotEmpty) {
              // Load questions for the first quiz of type 'pairing'
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

              // Split options into left and right columns
              final leftOptions = currentQuestion.options.where((option) =>
                option.id.startsWith('L')).toList();
              final rightOptions = currentQuestion.options.where((option) =>
                option.id.startsWith('R')).toList();

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
                          // Pairing instructions
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.withOpacity(0.5)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Hãy chọn một mục ở cột trái, sau đó chọn mục tương ứng ở cột phải để ghép đôi.',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Pairing columns
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left column
                              Expanded(
                                child: Column(
                                  children: [
                                    const Text(
                                      'Cột A',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    ...leftOptions.map((option) {
                                      final isPaired = _userPairs.containsKey(option.id);
                                      final isSelected = option.id == _selectedLeftItemId;
                                      final pairedRightId = _userPairs[option.id];
                                      final isCorrectPair = _isAnswerChecked &&
                                        currentQuestion.correctPairs?[option.id] == pairedRightId;
                                      final isWrongPair = _isAnswerChecked && isPaired && !isCorrectPair;

                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: PairingItemCard(
                                          option: option,
                                          isSelected: isSelected,
                                          isPaired: isPaired,
                                          isCorrect: isCorrectPair,
                                          isWrong: isWrongPair,
                                          onTap: _isAnswerChecked ? null : () {
                                            setState(() {
                                              _selectedLeftItemId = option.id;
                                              _selectedRightItemId = null;
                                            });
                                          },
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                              // Connection lines
                              if (_userPairs.isNotEmpty)
                                SizedBox(
                                  width: 40,
                                  child: CustomPaint(
                                    size: Size(40, leftOptions.length * 100.0),
                                    painter: ConnectionPainter(
                                      leftOptions: leftOptions,
                                      rightOptions: rightOptions,
                                      userPairs: _userPairs,
                                      isAnswerChecked: _isAnswerChecked,
                                      correctPairs: currentQuestion.correctPairs ?? {},
                                    ),
                                  ),
                                ),
                              // Right column
                              Expanded(
                                child: Column(
                                  children: [
                                    const Text(
                                      'Cột B',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    ...rightOptions.map((option) {
                                      final isPaired = _userPairs.containsValue(option.id);
                                      final isSelected = option.id == _selectedRightItemId;
                                      final pairedLeftId = _userPairs.entries
                                        .firstWhere((entry) => entry.value == option.id,
                                          orElse: () => const MapEntry('', '')).key;
                                      final isCorrectPair = _isAnswerChecked &&
                                        currentQuestion.correctPairs?[pairedLeftId] == option.id;
                                      final isWrongPair = _isAnswerChecked && isPaired && !isCorrectPair;

                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: PairingItemCard(
                                          option: option,
                                          isSelected: isSelected,
                                          isPaired: isPaired,
                                          isCorrect: isCorrectPair,
                                          isWrong: isWrongPair,
                                          onTap: _isAnswerChecked || _selectedLeftItemId == null ? null : () {
                                            setState(() {
                                              _selectedRightItemId = option.id;
                                              // Create pair
                                              if (_selectedLeftItemId != null) {
                                                _userPairs[_selectedLeftItemId!] = option.id;
                                                _selectedLeftItemId = null;
                                                _selectedRightItemId = null;
                                              }
                                            });
                                          },
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                            ],
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
                                          ? 'Chúc mừng! Bạn đã ghép đúng tất cả các cặp.'
                                          : 'Có một số cặp chưa đúng. Hãy thử lại nhé!',
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
                        if (!_isAnswerChecked)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _userPairs.isEmpty ? null : () {
                                setState(() {
                                  // Reset the last pair
                                  if (_userPairs.isNotEmpty) {
                                    _userPairs.remove(_userPairs.keys.last);
                                  }
                                });
                              },
                              child: const Text('Xóa cặp cuối'),
                            ),
                          ),
                        if (!_isAnswerChecked)
                          const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _userPairs.length != leftOptions.length
                                ? null
                                : () {
                                    if (_isAnswerChecked) {
                                      // Move to next question or finish quiz
                                      if (_currentQuestionIndex < _totalQuestions - 1) {
                                        setState(() {
                                          _currentQuestionIndex++;
                                          _userPairs = {};
                                          _selectedLeftItemId = null;
                                          _selectedRightItemId = null;
                                          _isAnswerChecked = false;
                                        });
                                      } else {
                                        // Show completion dialog
                                        _showCompletionDialog();
                                      }
                                    } else {
                                      // Check answer
                                      final correctPairs = currentQuestion.correctPairs ?? {};
                                      bool allCorrect = true;

                                      for (final entry in _userPairs.entries) {
                                        if (correctPairs[entry.key] != entry.value) {
                                          allCorrect = false;
                                          break;
                                        }
                                      }

                                      setState(() {
                                        _isAnswerChecked = true;
                                        _isCorrect = allCorrect;
                                        if (allCorrect) {
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
    );
  }

  void _showCompletionDialog() {
    // Play success sound
    _audioService.playSuccessSound();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfettiAnimation(
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Hoàn thành bài học!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trophy animation
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Colors.green,
                    size: 64,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Score animation
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: _score),
                duration: const Duration(milliseconds: 1500),
                builder: (context, value, child) {
                  return Text(
                    'Điểm của bạn: $value/$_totalQuestions',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              // Percentage animation
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: _score / _totalQuestions),
                duration: const Duration(milliseconds: 1500),
                builder: (context, value, child) {
                  return Column(
                    children: [
                      Text(
                        'Tỷ lệ đúng: ${(value * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: value,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(value)),
                          minHeight: 10,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Quay lại trang chủ'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _currentQuestionIndex = 0;
                _userPairs = {};
                _selectedLeftItemId = null;
                _selectedRightItemId = null;
                _isAnswerChecked = false;
                _isCorrect = false;
                _score = 0;
              });
            },
            child: const Text('Làm lại'),
          ),
        ],
      ),
    ));
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
        quizId: 'sample_pairing_quiz_id',
        text: 'Hãy ghép đôi các con vật với tiếng kêu của chúng',
        type: 'pairing',
        options: [
          const AnswerOption(
            id: 'L1',
            text: 'Mèo',
            imageUrl: 'https://placekitten.com/200/200',
          ),
          const AnswerOption(
            id: 'L2',
            text: 'Chó',
            imageUrl: 'https://placedog.net/200/200',
          ),
          const AnswerOption(
            id: 'L3',
            text: 'Gà',
            imageUrl: 'https://via.placeholder.com/200x200?text=Chicken',
          ),
          const AnswerOption(
            id: 'R1',
            text: 'Meo meo',
          ),
          const AnswerOption(
            id: 'R2',
            text: 'Gâu gâu',
          ),
          const AnswerOption(
            id: 'R3',
            text: 'Ò ó o',
          ),
        ],
        correctPairs: {
          'L1': 'R1',
          'L2': 'R2',
          'L3': 'R3',
        },
        order: 1,
        hint: 'Hãy nghĩ về âm thanh mà mỗi con vật tạo ra',
      ),
      QuestionModel(
        id: '2',
        quizId: 'sample_pairing_quiz_id',
        text: 'Hãy ghép đôi các màu sắc với đồ vật tương ứng',
        type: 'pairing',
        options: [
          const AnswerOption(
            id: 'L1',
            text: 'Đỏ',
            imageUrl: 'https://via.placeholder.com/200x200/FF0000/FFFFFF?text=Red',
          ),
          const AnswerOption(
            id: 'L2',
            text: 'Vàng',
            imageUrl: 'https://via.placeholder.com/200x200/FFFF00/000000?text=Yellow',
          ),
          const AnswerOption(
            id: 'L3',
            text: 'Xanh lá',
            imageUrl: 'https://via.placeholder.com/200x200/00FF00/FFFFFF?text=Green',
          ),
          const AnswerOption(
            id: 'R1',
            text: 'Quả táo',
            imageUrl: 'https://via.placeholder.com/200x200?text=Apple',
          ),
          const AnswerOption(
            id: 'R2',
            text: 'Quả chuối',
            imageUrl: 'https://via.placeholder.com/200x200?text=Banana',
          ),
          const AnswerOption(
            id: 'R3',
            text: 'Cây cỏ',
            imageUrl: 'https://via.placeholder.com/200x200?text=Grass',
          ),
        ],
        correctPairs: {
          'L1': 'R1',
          'L2': 'R2',
          'L3': 'R3',
        },
        order: 2,
        hint: 'Hãy nghĩ về màu sắc tự nhiên của mỗi đồ vật',
      ),
    ];
  }
}

class ConnectionPainter extends CustomPainter {
  final List<AnswerOption> leftOptions;
  final List<AnswerOption> rightOptions;
  final Map<String, String> userPairs;
  final bool isAnswerChecked;
  final Map<String, String> correctPairs;

  ConnectionPainter({
    required this.leftOptions,
    required this.rightOptions,
    required this.userPairs,
    required this.isAnswerChecked,
    required this.correctPairs,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double itemHeight = size.height / leftOptions.length;

    for (int i = 0; i < leftOptions.length; i++) {
      final leftOption = leftOptions[i];
      if (userPairs.containsKey(leftOption.id)) {
        final rightId = userPairs[leftOption.id]!;
        final rightIndex = rightOptions.indexWhere((option) => option.id == rightId);

        if (rightIndex != -1) {
          final startY = i * itemHeight + itemHeight / 2;
          final endY = rightIndex * itemHeight + itemHeight / 2;

          final paint = Paint()
            ..color = isAnswerChecked
                ? (correctPairs[leftOption.id] == rightId ? Colors.green : Colors.red)
                : Colors.blue
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke;

          final path = Path();
          path.moveTo(0, startY);
          path.cubicTo(
            size.width * 0.5, startY,
            size.width * 0.5, endY,
            size.width, endY,
          );

          canvas.drawPath(path, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
