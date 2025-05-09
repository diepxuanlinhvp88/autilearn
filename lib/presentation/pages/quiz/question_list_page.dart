import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../presentation/blocs/question/question_bloc.dart';
import '../../../presentation/blocs/question/question_event.dart';
import '../../../presentation/blocs/question/question_state.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../presentation/blocs/auth/auth_state.dart';
import '../../../presentation/blocs/user/user_bloc.dart';
import '../../../presentation/blocs/user/user_state.dart';
import '../../../presentation/blocs/user/user_event.dart';
import '../../../data/models/question_model.dart';
import '../../../app/routes.dart';
import '../../../main.dart';

class QuestionListPage extends StatelessWidget {
  final String quizId;
  final String quizTitle;
  final String quizType;

  const QuestionListPage({
    Key? key,
    required this.quizId,
    required this.quizTitle,
    required this.quizType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Đảm bảo UserBloc đã được tải
    if (context.read<UserBloc>().state is! UserProfileLoaded) {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        context.read<UserBloc>().add(LoadUserProfile(authState.user.uid));
      }
    }
    
    return BlocProvider<QuestionBloc>(
      create: (context) => getIt<QuestionBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Câu hỏi: $quizTitle'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppRouter.createQuestion,
                  arguments: {
                    'quizId': quizId,
                    'quizType': quizType,
                  },
                );
              },
              tooltip: 'Tạo câu hỏi mới',
            ),
          ],
        ),
        body: BlocConsumer<QuestionBloc, QuestionState>(
          listener: (context, state) {
            if (state is QuestionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is QuestionDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã xóa câu hỏi'),
                  backgroundColor: Colors.green,
                ),
              );
              
              // Tải lại danh sách câu hỏi
              context.read<QuestionBloc>().add(LoadQuestions(quizId));
            }
          },
          builder: (context, state) {
            if (state is QuestionInitial) {
              // Tải danh sách câu hỏi khi trang được tạo
              context.read<QuestionBloc>().add(LoadQuestions(quizId));
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is QuestionLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is QuestionsLoaded) {
              final questions = state.questions;
              
              if (questions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Bài học này chưa có câu hỏi nào',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            AppRouter.createQuestion,
                            arguments: {
                              'quizId': quizId,
                              'quizType': quizType,
                            },
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Tạo câu hỏi mới'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              // Sắp xếp câu hỏi theo thứ tự
              questions.sort((a, b) => a.order.compareTo(b.order));
              
              return ReorderableListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: questions.length,
                onReorder: (oldIndex, newIndex) {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  
                  final List<QuestionModel> updatedQuestions = List.from(questions);
                  final item = updatedQuestions.removeAt(oldIndex);
                  updatedQuestions.insert(newIndex, item);
                  
                  // Cập nhật thứ tự
                  for (int i = 0; i < updatedQuestions.length; i++) {
                    updatedQuestions[i] = updatedQuestions[i].copyWith(order: i);
                  }
                  
                  // Lưu thứ tự mới
                  context.read<QuestionBloc>().add(UpdateQuestionsOrder(updatedQuestions));
                },
                itemBuilder: (context, index) {
                  final question = questions[index];
                  return _buildQuestionCard(context, question, index);
                },
              );
            } else {
              return const Center(
                child: Text('Không thể tải danh sách câu hỏi'),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context, QuestionModel question, int index) {
    return Card(
      key: ValueKey(question.id),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRouter.editQuestion,
            arguments: {
              'question': question,
              'quizType': quizType,
            },
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      question.text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.of(context).pushNamed(
                          AppRouter.editQuestion,
                          arguments: {
                            'question': question,
                            'quizType': quizType,
                          },
                        );
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(context, question.id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Chỉnh sửa'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Xóa'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (question.imageUrl.isNotEmpty) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    question.imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Text('Không thể tải hình ảnh'),
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _buildQuestionDetails(question),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionDetails(QuestionModel question) {
    switch (quizType) {
      case 'choices_quiz':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Các lựa chọn:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...question.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isCorrect = question.correctOptionIndex == index;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCorrect ? Colors.green : Colors.grey,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: isCorrect
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.green,
                              )
                            : Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 14,
                          color: isCorrect ? Colors.green : Colors.black,
                          fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        );
      case 'pairing_quiz':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Các cặp ghép đôi:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...question.pairs.asMap().entries.map((entry) {
              final index = entry.key;
              final pair = entry.value;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.blue,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        pair.first,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        pair.second,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        );
      case 'sequential_quiz':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thứ tự đúng:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...question.sequence.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.orange,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        );
      case 'emotions_quiz':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cảm xúc đúng:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.purple,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    question.emotion,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _showDeleteConfirmation(BuildContext context, String questionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa câu hỏi này không?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<QuestionBloc>().add(DeleteQuestion(questionId, quizId));
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
}
