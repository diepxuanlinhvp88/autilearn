import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/question_model.dart';
import '../../../data/models/quiz_model.dart';
import '../../../main.dart';
import '../../../presentation/blocs/quiz/quiz_bloc.dart';
import '../../../presentation/blocs/quiz/quiz_event.dart';
import '../../../presentation/blocs/quiz/quiz_state.dart';
import '../../../presentation/widgets/teacher/question_list_item.dart';
import '../../../app/routes.dart';

class QuestionListPage extends StatefulWidget {
  final String quizId;
  final String quizTitle;
  final String quizType;

  const QuestionListPage({
    super.key,
    required this.quizId,
    required this.quizTitle,
    required this.quizType,
  });

  @override
  State<QuestionListPage> createState() => _QuestionListPageState();
}

class _QuestionListPageState extends State<QuestionListPage> {
  List<QuestionModel> _questions = [];
  bool _isReordering = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QuizBloc>(
      create: (context) => getIt<QuizBloc>()..add(LoadQuestions(widget.quizId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Câu hỏi: ${widget.quizTitle}'),
          actions: [
            if (_questions.isNotEmpty)
              IconButton(
                icon: Icon(
                  _isReordering ? Icons.check : Icons.reorder,
                  color: _isReordering ? Colors.green : null,
                ),
                onPressed: () {
                  setState(() {
                    _isReordering = !_isReordering;
                  });
                },
                tooltip: _isReordering ? 'Hoàn tất sắp xếp' : 'Sắp xếp lại',
              ),
          ],
        ),
        body: BlocConsumer<QuizBloc, QuizState>(
          listener: (context, state) {
            if (state is QuestionsLoaded) {
              setState(() {
                _questions = state.questions;
              });
            } else if (state is QuizOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              // Reload questions after operation
              context.read<QuizBloc>().add(LoadQuestions(widget.quizId));
            } else if (state is QuizError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is QuizLoading && _questions.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (_questions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.question_mark,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Chưa có câu hỏi nào',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Hãy thêm câu hỏi đầu tiên cho bài học này',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _navigateToCreateQuestion(),
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm câu hỏi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (_isReordering) {
              return ReorderableListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _questions.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final item = _questions.removeAt(oldIndex);
                    _questions.insert(newIndex, item);
                    
                    // Update order for all questions
                    for (int i = 0; i < _questions.length; i++) {
                      _questions[i] = _questions[i].copyWith(order: i + 1);
                    }
                  });
                },
                itemBuilder: (context, index) {
                  final question = _questions[index];
                  return ListTile(
                    key: Key(question.id),
                    leading: CircleAvatar(
                      backgroundColor: _getTypeColor(question.type),
                      child: Text('${index + 1}'),
                    ),
                    title: Text(question.text),
                    trailing: const Icon(Icons.drag_handle),
                  );
                },
              );
            }

            return Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    final question = _questions[index];
                    return QuestionListItem(
                      question: question,
                      onEdit: () => _navigateToEditQuestion(question),
                      onDelete: () => _showDeleteConfirmation(question),
                      onReorder: null, // We're using ReorderableListView instead
                    );
                  },
                ),
                if (state is QuizLoading)
                  const Positioned.fill(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _navigateToCreateQuestion(),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: _isReordering
            ? BottomAppBar(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveReordering,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Lưu thứ tự mới'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _isReordering = false;
                              // Reload questions to discard changes
                              context.read<QuizBloc>().add(LoadQuestions(widget.quizId));
                            });
                          },
                          child: const Text('Hủy'),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
    );
  }

  void _navigateToCreateQuestion() {
    Navigator.of(context).pushNamed(
      AppRouter.createQuestion,
      arguments: {
        'quizId': widget.quizId,
        'quizType': widget.quizType,
        'order': _questions.length + 1,
      },
    );
  }

  void _navigateToEditQuestion(QuestionModel question) {
    Navigator.of(context).pushNamed(
      AppRouter.editQuestion,
      arguments: {
        'question': question,
      },
    );
  }

  void _showDeleteConfirmation(QuestionModel question) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa câu hỏi'),
        content: Text('Bạn có chắc chắn muốn xóa câu hỏi "${question.text}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<QuizBloc>().add(DeleteQuestion(question.id));
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _saveReordering() {
    // Update all questions with new order
    for (final question in _questions) {
      context.read<QuizBloc>().add(UpdateQuestion(question));
    }
    
    setState(() {
      _isReordering = false;
    });
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case AppConstants.choicesQuiz:
        return Colors.blue;
      case AppConstants.pairingQuiz:
        return Colors.green;
      case AppConstants.sequentialQuiz:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
