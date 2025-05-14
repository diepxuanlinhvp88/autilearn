import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../presentation/blocs/quiz/quiz_bloc.dart';
import '../../../presentation/blocs/quiz/quiz_event.dart';
import '../../../presentation/blocs/quiz/quiz_state.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../presentation/blocs/auth/auth_state.dart';
import '../../../presentation/blocs/user/user_bloc.dart';
import '../../../presentation/blocs/user/user_state.dart';
import '../../../presentation/blocs/user/user_event.dart';
import '../../../data/models/quiz_model.dart';
import '../../../app/routes.dart';
import '../../../main.dart';

class ManageQuizzesPage extends StatefulWidget {
  const ManageQuizzesPage({Key? key}) : super(key: key);

  @override
  _ManageQuizzesPageState createState() => _ManageQuizzesPageState();
}

class _ManageQuizzesPageState extends State<ManageQuizzesPage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<QuizBloc>().add(LoadQuizzes(creatorId: authState.user.uid));
    }
  }

  void _refreshQuizzes() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<QuizBloc>().add(LoadQuizzes(creatorId: authState.user.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý bài học'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.createQuiz).then((_) {
                _refreshQuizzes();
              });
            },
            tooltip: 'Tạo bài học mới',
          ),
        ],
      ),
      body: BlocConsumer<QuizBloc, QuizState>(
        listener: (context, state) {
          if (state is QuizError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is QuizDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã xóa bài học'),
                backgroundColor: Colors.green,
              ),
            );
            _refreshQuizzes();
          }
        },
        builder: (context, state) {
          if (state is QuizLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is QuizzesLoaded) {
            if (state.quizzes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.quiz,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có bài học nào',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRouter.createQuiz).then((_) {
                          _refreshQuizzes();
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Tạo bài học mới'),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.quizzes.length,
              itemBuilder: (context, index) {
                return _buildQuizCard(context, state.quizzes[index]);
              },
            );
          }
          return const Center(
            child: Text('Không thể tải danh sách bài học'),
          );
        },
      ),
    );
  }

  Widget _buildQuizCard(BuildContext context, QuizModel quiz) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRouter.questionList,
            arguments: {
              'quizId': quiz.id,
              'quizTitle': quiz.title,
              'quizType': quiz.type,
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
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getQuizTypeColor(quiz.type).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        _getQuizTypeIcon(quiz.type),
                        color: _getQuizTypeColor(quiz.type),
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quiz.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getQuizTypeText(quiz.type),
                          style: TextStyle(
                            fontSize: 14,
                            color: _getQuizTypeColor(quiz.type),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.of(context).pushNamed(
                          AppRouter.editQuiz,
                          arguments: quiz,
                        );
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(context, quiz.id);
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
              const SizedBox(height: 16),
              Text(
                quiz.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Số câu hỏi: ${quiz.questionCount}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        AppRouter.questionList,
                        arguments: {
                          'quizId': quiz.id,
                          'quizTitle': quiz.title,
                          'quizType': quiz.type,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Xem câu hỏi'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getQuizTypeColor(String type) {
    switch (type) {
      case 'choices_quiz':
        return Colors.blue;
      case 'pairing_quiz':
        return Colors.green;
      case 'sequential_quiz':
        return Colors.orange;
      case 'emotions_quiz':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getQuizTypeIcon(String type) {
    switch (type) {
      case 'choices_quiz':
        return Icons.check_circle;
      case 'pairing_quiz':
        return Icons.compare_arrows;
      case 'sequential_quiz':
        return Icons.sort;
      case 'emotions_quiz':
        return Icons.emoji_emotions;
      default:
        return Icons.help;
    }
  }

  String _getQuizTypeText(String type) {
    switch (type) {
      case 'choices_quiz':
        return 'Bài học lựa chọn';
      case 'pairing_quiz':
        return 'Bài học ghép đôi';
      case 'sequential_quiz':
        return 'Bài học sắp xếp';
      case 'emotions_quiz':
        return 'Bài học nhận diện cảm xúc';
      default:
        return 'Bài học khác';
    }
  }

  void _showDeleteConfirmation(BuildContext context, String quizId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa bài học này không?'),
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
              context.read<QuizBloc>().add(DeleteQuiz(quizId));
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
