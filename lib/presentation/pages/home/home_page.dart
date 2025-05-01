import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../main.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../presentation/blocs/auth/auth_event.dart';
import '../../../presentation/blocs/auth/auth_state.dart';
import '../../../presentation/blocs/quiz/quiz_bloc.dart';
import '../../../presentation/blocs/quiz/quiz_event.dart';
import '../../../presentation/blocs/quiz/quiz_state.dart';
import '../../../app/routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => getIt<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider<QuizBloc>(
          create: (context) => getIt<QuizBloc>()..add(const LoadQuizzes(isPublished: true)),
        ),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is Authenticated) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('AutiLearn'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      context.read<AuthBloc>().add(const SignOutRequested());
                    },
                  ),
                ],
              ),
              body: _buildBody(authState),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Trang chủ',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.quiz),
                    label: 'Bài học',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Hồ sơ',
                  ),
                ],
              ),
            );
          } else if (authState is Unauthenticated) {
            // Redirect to login page
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed(AppRouter.login);
            });
          }

          // Show loading indicator while checking auth state
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(Authenticated authState) {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab(authState);
      case 1:
        return _buildQuizzesTab(authState);
      case 2:
        return _buildProfileTab(authState);
      default:
        return _buildHomeTab(authState);
    }
  }

  Widget _buildHomeTab(Authenticated authState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Xin chào, ${authState.user.displayName ?? 'Người dùng'}!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Các loại bài học',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuizTypeCard(
            title: 'Bài học lựa chọn',
            description: 'Chọn hình ảnh phù hợp với câu hỏi',
            icon: Icons.check_circle,
            color: Colors.blue,
            onTap: () {
              Navigator.of(context).pushNamed(AppRouter.choicesQuiz);
            },
          ),
          const SizedBox(height: 16),
          _buildQuizTypeCard(
            title: 'Bài học ghép đôi',
            description: 'Nối cặp hình ảnh hoặc từ vựng với định nghĩa',
            icon: Icons.compare_arrows,
            color: Colors.green,
            onTap: () {
              Navigator.of(context).pushNamed(AppRouter.pairingQuiz);
            },
          ),
          const SizedBox(height: 16),
          _buildQuizTypeCard(
            title: 'Bài học sắp xếp',
            description: 'Sắp xếp các hình ảnh theo đúng trình tự',
            icon: Icons.sort,
            color: Colors.orange,
            onTap: () {
              Navigator.of(context).pushNamed(AppRouter.sequentialQuiz);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuizTypeCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizzesTab(Authenticated authState) {
    return BlocBuilder<QuizBloc, QuizState>(
      builder: (context, state) {
        if (state is QuizLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is QuizzesLoaded) {
          if (state.quizzes.isEmpty) {
            return const Center(
              child: Text('Không có bài học nào'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: state.quizzes.length,
            itemBuilder: (context, index) {
              final quiz = state.quizzes[index];
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
                child: InkWell(
                  onTap: () {
                    // Navigate to the appropriate quiz page
                    switch (quiz.type) {
                      case AppConstants.choicesQuiz:
                        Navigator.of(context).pushNamed(AppRouter.choicesQuiz);
                        break;
                      case AppConstants.pairingQuiz:
                        Navigator.of(context).pushNamed(AppRouter.pairingQuiz);
                        break;
                      case AppConstants.sequentialQuiz:
                        Navigator.of(context).pushNamed(AppRouter.sequentialQuiz);
                        break;
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
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
                                    color: _getDifficultyColor(quiz.difficulty)
                                        .withOpacity(0.1),
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
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
    );
  }

  Widget _buildProfileTab(Authenticated authState) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(
              Icons.person,
              size: 50,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            authState.user.displayName ?? 'Người dùng',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            authState.user.email ?? '',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              context.read<AuthBloc>().add(const SignOutRequested());
            },
            child: const Text('Đăng xuất'),
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
