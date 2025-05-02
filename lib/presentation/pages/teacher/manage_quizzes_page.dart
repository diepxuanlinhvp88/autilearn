import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../teacher/create_quiz_page.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/quiz_model.dart';
import '../../../main.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../presentation/blocs/auth/auth_state.dart';
import '../../../presentation/blocs/quiz/quiz_bloc.dart';
import '../../../presentation/blocs/quiz/quiz_event.dart';
import '../../../presentation/blocs/quiz/quiz_state.dart';
import '../../../app/routes.dart';

class ManageQuizzesPage extends StatefulWidget {
  const ManageQuizzesPage({super.key});

  @override
  State<ManageQuizzesPage> createState() => _ManageQuizzesPageState();
}

class _ManageQuizzesPageState extends State<ManageQuizzesPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<QuizBloc>(
      create: (context) => getIt<QuizBloc>(),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
        if (authState is Authenticated) {
          // Load quizzes created by this user
          context.read<QuizBloc>().add(LoadQuizzes(creatorId: authState.user.uid));

          return Scaffold(
            appBar: AppBar(
              title: const Text('Quản lý bài học'),

            ),
            body: BlocConsumer<QuizBloc, QuizState>(
              listener: (context, state) {
                if (state is QuizOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Reload quizzes after operation
                  context.read<QuizBloc>().add(LoadQuizzes(creatorId: authState.user.uid));
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
                            const Icon(
                              Icons.quiz,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Bạn chưa tạo bài học nào',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Hãy tạo bài học đầu tiên của bạn',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pushNamed(AppRouter.createQuiz);
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Tạo bài học mới'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.quizzes.length,
                      itemBuilder: (context, index) {
                        final quiz = state.quizzes[index];
                        return _buildQuizCard(context, quiz);
                      },
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
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreateQuizPage(),
                    ),
                  );
                },
                child: const Icon(Icons.add),
              ),
            );
          } else {
            // Redirect to login page if not authenticated
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed(AppRouter.login);
            });
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildQuizCard(BuildContext context, QuizModel quiz) {
    IconData quizIcon;
    Color quizColor;

    switch (quiz.type) {
      case AppConstants.choicesQuiz:
        quizIcon = Icons.check_circle;
        quizColor = Colors.blue;
        break;
      case AppConstants.pairingQuiz:
        quizIcon = Icons.compare_arrows;
        quizColor = Colors.green;
        break;
      case AppConstants.sequentialQuiz:
        quizIcon = Icons.sort;
        quizColor = Colors.orange;
        break;
      default:
        quizIcon = Icons.quiz;
        quizColor = Colors.purple;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (quiz.imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                quiz.imageUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(quizIcon, color: quizColor),
                    const SizedBox(width: 8),
                    Text(
                      _getQuizTypeText(quiz.type),
                      style: TextStyle(
                        color: quizColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(quiz.difficulty).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getDifficultyText(quiz.difficulty),
                        style: TextStyle(
                          color: _getDifficultyColor(quiz.difficulty),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  quiz.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  quiz.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.question_answer,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${quiz.questionCount} câu hỏi',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.child_care,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${quiz.ageRangeMin}-${quiz.ageRangeMax} tuổi',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Navigate to edit quiz page
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Chỉnh sửa'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Navigate to question list page
                          Navigator.of(context).pushNamed(
                            AppRouter.questionList,
                            arguments: {
                              'quizId': quiz.id,
                              'quizTitle': quiz.title,
                              'quizType': quiz.type,
                            },
                          );
                        },
                        icon: const Icon(Icons.question_answer),
                        label: const Text('Câu hỏi'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Toggle publish status
                          final updatedQuiz = quiz.copyWith(
                            isPublished: !quiz.isPublished,
                            updatedAt: DateTime.now(),
                          );
                          context.read<QuizBloc>().add(UpdateQuiz(updatedQuiz));
                        },
                        icon: Icon(quiz.isPublished ? Icons.unpublished : Icons.publish),
                        label: Text(quiz.isPublished ? 'Hủy xuất bản' : 'Xuất bản'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: quiz.isPublished ? Colors.orange : Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        // Show delete confirmation dialog
                        _showDeleteConfirmationDialog(context, quiz);
                      },
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                      tooltip: 'Xóa bài học',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, QuizModel quiz) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa bài học "${quiz.title}" không?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<QuizBloc>().add(DeleteQuiz(quiz.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  String _getQuizTypeText(String type) {
    switch (type) {
      case AppConstants.choicesQuiz:
        return 'Bài học lựa chọn';
      case AppConstants.pairingQuiz:
        return 'Bài học ghép đôi';
      case AppConstants.sequentialQuiz:
        return 'Bài học sắp xếp';
      default:
        return 'Bài học';
    }
  }

  String _getDifficultyText(String difficulty) {
    switch (difficulty) {
      case AppConstants.difficultyEasy:
        return 'Dễ';
      case AppConstants.difficultyMedium:
        return 'Trung bình';
      case AppConstants.difficultyHard:
        return 'Khó';
      default:
        return 'Không xác định';
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case AppConstants.difficultyEasy:
        return Colors.green;
      case AppConstants.difficultyMedium:
        return Colors.orange;
      case AppConstants.difficultyHard:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
