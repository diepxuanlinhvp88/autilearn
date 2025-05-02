import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/question_model.dart';
import '../../../main.dart';
import '../../../presentation/blocs/quiz/quiz_bloc.dart';
import '../../../presentation/blocs/quiz/quiz_event.dart';
import '../../../presentation/blocs/quiz/quiz_state.dart';
import '../../../presentation/widgets/quiz/sequential_item_card.dart';
import '../../../core/services/audio_service.dart';
import '../../../presentation/widgets/common/confetti_animation.dart';

class SequentialQuizPage extends StatefulWidget {
  const SequentialQuizPage({super.key});

  @override
  State<SequentialQuizPage> createState() => _SequentialQuizPageState();
}

class _SequentialQuizPageState extends State<SequentialQuizPage> {
  int _currentQuestionIndex = 0;
  bool _isAnswerChecked = false;
  bool _isCorrect = false;
  int _score = 0;
  int _totalQuestions = 0;
  List<QuestionModel> _questions = [];

  // Sequential state
  List<String> _userSequence = [];
  List<AnswerOption> _availableOptions = [];

  final AudioService _audioService = getIt<AudioService>();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<QuizBloc>(
          create:
              (context) =>
                  getIt<QuizBloc>()..add(
                    const LoadQuizzes(
                      type: 'sequential_quiz',
                      isPublished: true,
                    ),
                  ),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bài học sắp xếp'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sắp xếp các hình ảnh theo đúng trình tự'),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<QuizBloc, QuizState>(
          listener: (context, state) {
            if (state is QuizzesLoaded && state.quizzes.isNotEmpty) {
              // Load questions for the first quiz of type 'sequential'
              context.read<QuizBloc>().add(
                LoadQuestions(state.quizzes.first.id),
              );
            } else if (state is QuestionsLoaded) {
              setState(() {
                _questions = state.questions;
                _totalQuestions = state.questions.length;
                _resetQuestion();
              });
            }
          },
          builder: (context, state) {
            if (state is QuizLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is QuestionsLoaded || _questions.isNotEmpty) {
              if (_questions.isEmpty) {
                return const Center(child: Text('Không có câu hỏi nào'));
              }

              // For demo purposes, create sample questions if none are loaded
              if (_questions.isEmpty) {
                _questions = _createSampleQuestions();
                _totalQuestions = _questions.length;
                _resetQuestion();
              }

              final currentQuestion = _questions[_currentQuestionIndex];

              return Column(
                children: [
                  // Progress indicator
                  LinearProgressIndicator(
                    value: (_currentQuestionIndex + 1) / _totalQuestions,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.blue,
                    ),
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
                                  image: NetworkImage(
                                    currentQuestion.imageUrl!,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),
                          // Sequential instructions
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.5),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Hãy sắp xếp các mục theo đúng thứ tự. Chọn từ các mục bên dưới để thêm vào trình tự.',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // User sequence
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Trình tự của bạn:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (_userSequence.isEmpty)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text(
                                        'Chưa có mục nào được chọn',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  )
                                else if (_isAnswerChecked)
                                  // Use regular ListView when answer is checked to completely hide drag handles
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _userSequence.length,
                                    itemBuilder: (context, index) {
                                      final optionId = _userSequence[index];
                                      final option = currentQuestion.options
                                          .firstWhere((o) => o.id == optionId);

                                      bool isCorrectPosition = false;
                                      bool isWrongPosition = false;

                                      if (currentQuestion.correctSequence != null) {
                                        isCorrectPosition =
                                            currentQuestion.correctSequence![index] ==
                                            optionId;
                                        isWrongPosition = !isCorrectPosition;
                                      }

                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8.0,
                                        ),
                                        child: SequentialItemCard(
                                          option: option,
                                          index: index + 1,
                                          isCorrect: isCorrectPosition,
                                          isWrong: isWrongPosition,
                                          isDraggable: false,
                                          onRemove: null,
                                        ),
                                      );
                                    },
                                  )
                                else
                                  ReorderableListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: _userSequence.length,
                                    onReorder: (oldIndex, newIndex) {
                                      setState(() {
                                        if (oldIndex < newIndex) {
                                          newIndex -= 1;
                                        }
                                        final item = _userSequence
                                            .removeAt(oldIndex);
                                        _userSequence.insert(
                                          newIndex,
                                          item,
                                        );
                                      });
                                    },
                                    itemBuilder: (context, index) {
                                      final optionId = _userSequence[index];
                                      final option = currentQuestion.options
                                          .firstWhere((o) => o.id == optionId);

                                      return Padding(
                                        key: ValueKey(optionId),
                                        padding: const EdgeInsets.only(
                                          bottom: 8.0,
                                        ),
                                        child: SequentialItemCard(
                                          option: option,
                                          index: index + 1,
                                          isCorrect: false,
                                          isWrong: false,
                                          isDraggable: true,
                                          onRemove: () {
                                            setState(() {
                                              _userSequence.removeAt(
                                                index,
                                              );
                                              _availableOptions.add(
                                                option,
                                              );
                                              // Sort available options by original order
                                              _availableOptions.sort(
                                                (a, b) =>
                                                    currentQuestion
                                                        .options
                                                        .indexOf(a) -
                                                    currentQuestion
                                                        .options
                                                        .indexOf(b),
                                              );
                                            });
                                          },
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Available options
                          // Container(
                          //   padding: const EdgeInsets.all(16),
                          //   decoration: BoxDecoration(
                          //     color: Colors.grey[100],
                          //     borderRadius: BorderRadius.circular(12),
                          //     border: Border.all(color: Colors.grey[300]!),
                          //   ),
                          // child: Column(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          //     const Text(
                          //       'Các mục có sẵn:',
                          //       style: TextStyle(
                          //         fontSize: 16,
                          //         fontWeight: FontWeight.bold,
                          //       ),
                          //     ),
                          //     const SizedBox(height: 12),
                          //     if (_availableOptions.isEmpty)
                          //       const Center(
                          //         child: Padding(
                          //           padding: EdgeInsets.all(16.0),
                          //           child: Text(
                          //             'Đã sử dụng hết các mục',
                          //             style: TextStyle(
                          //               color: Colors.grey,
                          //               fontStyle: FontStyle.italic,
                          //             ),
                          //           ),
                          //         ),
                          //       )
                          //     else
                          //       Wrap(
                          //         spacing: 8,
                          //         runSpacing: 8,
                          //         children: _availableOptions.map((option) {
                          //           return InkWell(
                          //             onTap: _isAnswerChecked ? null : () {
                          //               setState(() {
                          //                 _userSequence.add(option.id);
                          //                 _availableOptions.remove(option);
                          //               });
                          //             },
                          //             borderRadius: BorderRadius.circular(8),
                          //             child: Container(
                          //               padding: const EdgeInsets.all(8),
                          //               decoration: BoxDecoration(
                          //                 color: Colors.white,
                          //                 borderRadius: BorderRadius.circular(8),
                          //                 border: Border.all(color: Colors.grey),
                          //               ),
                          //               child: Column(
                          //                 children: [
                          //                   if (option.imageUrl != null)
                          //                     ClipRRect(
                          //                       borderRadius: BorderRadius.circular(4),
                          //                       child: Image.network(
                          //                         option.imageUrl!,
                          //                         width: 80,
                          //                         height: 80,
                          //                         fit: BoxFit.cover,
                          //                       ),
                          //                     ),
                          //                   if (option.imageUrl != null)
                          //                     const SizedBox(height: 4),
                          //                   Text(
                          //                     option.text,
                          //                     style: const TextStyle(
                          //                       fontSize: 14,
                          //                     ),
                          //                   ),
                          //                 ],
                          //               ),
                          //             ),
                          //           );
                          //         }).toList(),
                          //       ),
                          //   ],
                          // ),
                          // ),
                          const SizedBox(height: 24),
                          // Feedback message
                          if (_isAnswerChecked)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color:
                                    _isCorrect
                                        ? Colors.green[100]
                                        : Colors.red[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _isCorrect
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color:
                                        _isCorrect ? Colors.green : Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _isCorrect
                                          ? 'Chúc mừng! Bạn đã sắp xếp đúng thứ tự.'
                                          : 'Thứ tự chưa đúng. Hãy thử lại nhé!',
                                      style: TextStyle(
                                        color:
                                            _isCorrect
                                                ? Colors.green
                                                : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),
                          // Hint
                          if (_isAnswerChecked &&
                              !_isCorrect &&
                              currentQuestion.hint != null)
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
                        // if (!_isAnswerChecked)
                        //   Expanded(
                        //     child: OutlinedButton(
                        //       onPressed: _userSequence.isEmpty ? null : () {
                        //         setState(() {
                        //           _resetQuestion();
                        //         });
                        //       },
                        //       child: const Text('Bắt đầu lại'),
                        //     ),
                        //   ),
                        // if (!_isAnswerChecked)
                        //   const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                _userSequence.length !=
                                        currentQuestion.options.length
                                    ? null
                                    : () {
                                      if (_isAnswerChecked) {
                                        // Move to next question or finish quiz
                                        if (_currentQuestionIndex <
                                            _totalQuestions - 1) {
                                          setState(() {
                                            _currentQuestionIndex++;
                                            _resetQuestion();
                                          });
                                        } else {
                                          // Show completion dialog
                                          _showCompletionDialog();
                                        }
                                      } else {
                                        // Check answer
                                        final correctSequence =
                                            currentQuestion.correctSequence ??
                                            [];
                                        bool isCorrect = true;

                                        if (correctSequence.length !=
                                            _userSequence.length) {
                                          isCorrect = false;
                                        } else {
                                          for (
                                            int i = 0;
                                            i < correctSequence.length;
                                            i++
                                          ) {
                                            if (correctSequence[i] !=
                                                _userSequence[i]) {
                                              isCorrect = false;
                                              break;
                                            }
                                          }
                                        }

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
                              backgroundColor:
                                  _isAnswerChecked ? Colors.blue : Colors.green,
                            ),
                            child: Text(
                              _isAnswerChecked
                                  ? (_currentQuestionIndex < _totalQuestions - 1
                                      ? 'Câu tiếp theo'
                                      : 'Hoàn thành')
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
              return Center(child: Text(state.message));
            }

            return const Center(child: Text('Không có dữ liệu'));
          },
        ),
      ),
    );
  }

  void _resetQuestion() {
    if (_questions.isEmpty) return;

    final currentQuestion = _questions[_currentQuestionIndex];
    _userSequence = currentQuestion.options.map((option) => option.id).toList();
    _availableOptions = []; // No available options since all are prepopulated
    _isAnswerChecked = false;
    _isCorrect = false;
  }

  void _showCompletionDialog() {
    // Play success sound
    _audioService.playSuccessSound();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => ConfettiAnimation(
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
                  color: Colors.orange,
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
                      return Transform.scale(scale: value, child: child);
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: Colors.orange,
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
                    tween: Tween<double>(
                      begin: 0,
                      end: _score / _totalQuestions,
                    ),
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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getScoreColor(value),
                              ),
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
                      _resetQuestion();
                      _score = 0;
                    });
                  },
                  child: const Text('Làm lại'),
                ),
              ],
            ),
          ),
    );
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
        quizId: 'sample_sequential_quiz_id',
        text: 'Hãy sắp xếp các bước đánh răng theo đúng thứ tự',
        type: 'sequential',
        options: [
          const AnswerOption(
            id: 'S1',
            text: 'Lấy bàn chải đánh răng',
            imageUrl: 'https://via.placeholder.com/200x200?text=Toothbrush',
          ),
          const AnswerOption(
            id: 'S2',
            text: 'Bóp kem đánh răng lên bàn chải',
            imageUrl: 'https://via.placeholder.com/200x200?text=Toothpaste',
          ),
          const AnswerOption(
            id: 'S3',
            text: 'Chải răng',
            imageUrl: 'https://via.placeholder.com/200x200?text=Brushing',
          ),
          const AnswerOption(
            id: 'S4',
            text: 'Súc miệng với nước',
            imageUrl: 'https://via.placeholder.com/200x200?text=Rinsing',
          ),
        ],
        correctSequence: ['S1', 'S2', 'S3', 'S4'],
        order: 1,
        hint: 'Hãy nghĩ về thứ tự các bước khi bạn đánh răng mỗi ngày',
      ),
      QuestionModel(
        id: '2',
        quizId: 'sample_sequential_quiz_id',
        text: 'Hãy sắp xếp các số theo thứ tự từ nhỏ đến lớn',
        type: 'sequential',
        options: [
          const AnswerOption(
            id: 'S1',
            text: '1',
            imageUrl: 'https://via.placeholder.com/200x200?text=1',
          ),
          const AnswerOption(
            id: 'S2',
            text: '2',
            imageUrl: 'https://via.placeholder.com/200x200?text=2',
          ),
          const AnswerOption(
            id: 'S3',
            text: '3',
            imageUrl: 'https://via.placeholder.com/200x200?text=3',
          ),
          const AnswerOption(
            id: 'S4',
            text: '4',
            imageUrl: 'https://via.placeholder.com/200x200?text=4',
          ),
          const AnswerOption(
            id: 'S5',
            text: '5',
            imageUrl: 'https://via.placeholder.com/200x200?text=5',
          ),
        ],
        correctSequence: ['S1', 'S2', 'S3', 'S4', 'S5'],
        order: 2,
        hint: 'Hãy đếm từ 1 đến 5',
      ),
    ];
  }
}
