import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../teacher/create_quiz_page.dart';
import '../teacher/manage_quizzes_page.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/quiz_model.dart';
import '../../../main.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../presentation/blocs/auth/auth_event.dart';
import '../../../presentation/blocs/auth/auth_state.dart';
import '../../../presentation/blocs/quiz/quiz_bloc.dart';
import '../../../presentation/blocs/quiz/quiz_event.dart';
import '../../../presentation/blocs/quiz/quiz_state.dart';
import '../../../presentation/blocs/user/user_bloc.dart';
import '../../../presentation/blocs/user/user_progress_bloc.dart';
import '../../../presentation/blocs/user/user_progress_event.dart';
import '../../../presentation/blocs/user/user_progress_state.dart';
import '../../../data/models/user_progress_model.dart';
import '../../../data/repositories/quiz_repository.dart';
import '../../../presentation/blocs/user/user_event.dart';
import '../../../presentation/blocs/user/user_state.dart';
import '../../../data/models/user_model.dart';
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
        BlocProvider<UserBloc>(
          create: (context) => getIt<UserBloc>(),
        ),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is Authenticated) {
            // Tự động tải thông tin người dùng (chỉ gọi một lần khi UserBloc đang ở trạng thái ban đầu)
            if (context.read<UserBloc>().state is UserInitial) {
              print('HomePage: Loading user profile once');
              context.read<UserBloc>().add(LoadUserProfile(authState.user.uid));
            }
            return Scaffold(
              appBar: AppBar(
                title: const Text('AutiLearn'),
                actions: [
                  // Nút tạo bài học cho giáo viên và phụ huynh
                  BlocBuilder<UserBloc, UserState>(
                    builder: (context, userState) {
                      // Chỉ hiển thị loading nếu UserBloc đang ở trạng thái ban đầu
                      if (userState is UserInitial) {
                        return const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2));
                      }

                      if (userState is UserError) {
                        print('Error getting user profile: ${userState.message}');
                        return const SizedBox.shrink();
                      }

                      // Hiển thị nút tạo bài học nếu là giáo viên hoặc phụ huynh
                      if (userState is UserProfileLoaded &&
                          (userState.user.role == AppConstants.roleTeacher ||
                           userState.user.role == AppConstants.roleParent)) {
                        print('Showing create quiz button for role: ${userState.user.role}');
                        return IconButton(
                          icon: const Icon(Icons.add_circle),
                          tooltip: 'Tạo bài học mới',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const CreateQuizPage(),
                              ),
                            );
                          },
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with welcome message and avatar
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xin chào,',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        BlocBuilder<UserBloc, UserState>(
                          builder: (context, userState) {
                            // Trigger loading user profile
                            if (userState is UserInitial) {
                              context.read<UserBloc>().add(LoadUserProfile(authState.user.uid));
                            }

                            String roleName = '';
                            if (userState is UserProfileLoaded) {
                              switch (userState.user.role) {
                                case AppConstants.roleTeacher:
                                  roleName = ' (Giáo viên)';
                                  break;
                                case AppConstants.roleParent:
                                  roleName = ' (Phụ huynh)';
                                  break;
                                case AppConstants.roleStudent:
                                  roleName = ' (Học sinh)';
                                  break;
                              }
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  authState.user.displayName ?? 'Người dùng',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (roleName.isNotEmpty)
                                  Text(
                                    roleName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        (authState.user.displayName?.isNotEmpty ?? false)
                            ? authState.user.displayName![0].toUpperCase()
                            : 'A',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Hãy cùng học hôm nay!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Categories section
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Các loại bài học',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Quiz type cards in a grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.9,
                  children: [
                    _buildQuizTypeCardNew(
                      title: 'Bài học lựa chọn',
                      icon: Icons.check_circle,
                      color: Colors.blue,
                      onTap: () {
                        // Truyền null để hiển thị tất cả bài học loại này
                        Navigator.of(context).pushNamed(AppRouter.choicesQuiz, arguments: null);
                      },
                    ),
                    _buildQuizTypeCardNew(
                      title: 'Bài học ghép đôi',
                      icon: Icons.compare_arrows,
                      color: Colors.green,
                      onTap: () {
                        // Truyền null để hiển thị tất cả bài học loại này
                        Navigator.of(context).pushNamed(AppRouter.pairingQuiz, arguments: null);
                      },
                    ),
                    _buildQuizTypeCardNew(
                      title: 'Bài học sắp xếp',
                      icon: Icons.sort,
                      color: Colors.orange,
                      onTap: () {
                        // Truyền null để hiển thị tất cả bài học loại này
                        Navigator.of(context).pushNamed(AppRouter.sequentialQuiz, arguments: null);
                      },
                    ),
                    _buildQuizTypeCardNew(
                      title: 'Bài học mới',
                      icon: Icons.lightbulb,
                      color: Colors.purple,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tính năng đang phát triển'),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Nút tạo bài học cho giáo viên và phụ huynh
                // Hiển thị công cụ giáo viên từ UserBloc
                BlocBuilder<UserBloc, UserState>(
                  builder: (context, userState) {
                    // Chỉ hiển thị loading nếu UserBloc đang ở trạng thái ban đầu
                    if (userState is UserInitial) {
                      return const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2));
                    }

                    if (userState is UserError) {
                      print('Error getting user profile: ${userState.message}');
                      return const SizedBox.shrink();
                    }

                    // Hiển thị công cụ giáo viên nếu là giáo viên hoặc phụ huynh
                    if (userState is UserProfileLoaded &&
                        (userState.user.role == AppConstants.roleTeacher ||
                         userState.user.role == AppConstants.roleParent)) {
                      print('Showing teacher tools for role: ${userState.user.role}');
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Công cụ giáo viên',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const CreateQuizPage(),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.purple.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.create,
                                        color: Colors.purple,
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Tạo bài học mới',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Tạo bài học tùy chỉnh cho trẻ',
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
                          ),
                          const SizedBox(height: 12),
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const ManageQuizzesPage(),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.library_books,
                                        color: Colors.blue,
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Quản lý bài học',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Xem và chỉnh sửa bài học đã tạo',
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
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // Recent activities section
                const Text(
                  'Hoạt động gần đây',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Activity cards
                _buildActivityCard(
                  title: 'Bài học lựa chọn: Động vật',
                  subtitle: 'Hoàn thành: 80%',
                  icon: Icons.check_circle,
                  color: Colors.blue,
                  progress: 0.8,
                ),
                const SizedBox(height: 12),
                _buildActivityCard(
                  title: 'Bài học ghép đôi: Màu sắc',
                  subtitle: 'Hoàn thành: 60%',
                  icon: Icons.compare_arrows,
                  color: Colors.green,
                  progress: 0.6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizTypeCardNew({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 40,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivities(String userId) {
    return BlocProvider(
      create: (context) => getIt<UserProgressBloc>()..add(LoadUserProgress(userId)),
      child: BlocBuilder<UserProgressBloc, UserProgressState>(
        builder: (context, state) {
          if (state is UserProgressLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is UserProgressLoaded) {
            final progressList = state.progressList;

            if (progressList.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'Chưa có hoạt động nào gần đây',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              );
            }

            // Chỉ hiển thị 5 hoạt động gần nhất
            final recentActivities = progressList.take(5).toList();

            return Column(
              children: recentActivities.map((progress) {
                // Tìm quiz tương ứng
                return FutureBuilder<QuizModel?>(
                  future: _getQuizById(progress.quizId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox.shrink();
                    }

                    final quiz = snapshot.data!;
                    IconData icon;
                    Color color;

                    switch (quiz.type) {
                      case AppConstants.choicesQuiz:
                        icon = Icons.check_circle;
                        color = Colors.blue;
                        break;
                      case AppConstants.pairingQuiz:
                        icon = Icons.compare_arrows;
                        color = Colors.green;
                        break;
                      case AppConstants.sequentialQuiz:
                        icon = Icons.sort;
                        color = Colors.orange;
                        break;
                      default:
                        icon = Icons.quiz;
                        color = Colors.purple;
                    }

                    final percentComplete = progress.score / progress.totalQuestions;
                    final formattedDate = _formatDate(progress.completedAt);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildActivityCard(
                        title: quiz.title,
                        subtitle: 'Hoàn thành: ${(percentComplete * 100).toInt()}% - $formattedDate',
                        icon: icon,
                        color: color,
                        progress: percentComplete,
                        onTap: () {
                          // Mở bài học tương ứng với quiz ID
                          switch (quiz.type) {
                            case AppConstants.choicesQuiz:
                              Navigator.of(context).pushNamed(AppRouter.choicesQuiz, arguments: quiz.id);
                              break;
                            case AppConstants.pairingQuiz:
                              Navigator.of(context).pushNamed(AppRouter.pairingQuiz, arguments: quiz.id);
                              break;
                            case AppConstants.sequentialQuiz:
                              Navigator.of(context).pushNamed(AppRouter.sequentialQuiz, arguments: quiz.id);
                              break;
                          }
                        },
                      ),
                    );
                  },
                );
              }).toList(),
            );
          } else if (state is UserProgressError) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Lỗi: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            );
          }

          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Đang tải hoạt động gần đây...',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Hàm lấy thông tin quiz từ ID
  Future<QuizModel?> _getQuizById(String quizId) async {
    final result = await getIt<QuizRepository>().getQuizById(quizId);
    return result.fold(
      (error) => null,
      (quiz) => quiz,
    );
  }

  // Hàm định dạng ngày tháng
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildActivityCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required double progress,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onTap != null)
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
                borderRadius: BorderRadius.circular(4),
                minHeight: 8,
              ),
            ],
          ),
        ),
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
    return BlocProvider(
      create: (context) => getIt<QuizBloc>()..add(const LoadQuizzes(isPublished: true)),
      child: BlocBuilder<QuizBloc, QuizState>(
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
                  Image.asset(
                    'assets/images/empty_lessons.png',
                    height: 150,
                    width: 150,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có bài học nào',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hãy khám phá các bài học ở trang chủ',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Group quizzes by category
          final Map<String?, List<QuizModel>> quizzesByCategory = {};
          for (final quiz in state.quizzes) {
            if (!quizzesByCategory.containsKey(quiz.category)) {
              quizzesByCategory[quiz.category] = [];
            }
            quizzesByCategory[quiz.category]!.add(quiz);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      const Text(
                        'Tìm kiếm bài học...',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Categories
                ...quizzesByCategory.entries.map((entry) {
                  final category = entry.key ?? 'Khác';
                  final categoryQuizzes = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 220,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categoryQuizzes.length,
                          itemBuilder: (context, index) {
                            final quiz = categoryQuizzes[index];
                            return _buildQuizCard(context, quiz);
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                }).toList(),
              ],
            ),
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

    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Navigate to the appropriate quiz page with quiz ID
          switch (quiz.type) {
            case AppConstants.choicesQuiz:
              Navigator.of(context).pushNamed(AppRouter.choicesQuiz, arguments: quiz.id);
              break;
            case AppConstants.pairingQuiz:
              Navigator.of(context).pushNamed(AppRouter.pairingQuiz, arguments: quiz.id);
              break;
            case AppConstants.sequentialQuiz:
              Navigator.of(context).pushNamed(AppRouter.sequentialQuiz, arguments: quiz.id);
              break;
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quiz image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: quiz.imageUrl != null
                ? Image.network(
                    quiz.imageUrl!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 120,
                    width: double.infinity,
                    color: quizColor.withOpacity(0.2),
                    child: Icon(
                      quizIcon,
                      size: 40,
                      color: quizColor,
                    ),
                  ),
            ),
            // Quiz info
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quiz type and difficulty
                  Row(
                    children: [
                      Icon(quizIcon, size: 16, color: quizColor),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _getQuizTypeText(quiz.type),
                          style: TextStyle(
                            fontSize: 12,
                            color: quizColor,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(quiz.difficulty).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getDifficultyText(quiz.difficulty),
                          style: TextStyle(
                            fontSize: 10,
                            color: _getDifficultyColor(quiz.difficulty),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Quiz title
                  Text(
                    quiz.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Quiz stats
                  Row(
                    children: [
                      Icon(
                        Icons.question_answer,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${quiz.questionCount}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.child_care,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${quiz.ageRangeMin}-${quiz.ageRangeMax}',
                        style: TextStyle(
                          fontSize: 12,
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
          const SizedBox(height: 8),

          // User role
          BlocBuilder<UserBloc, UserState>(
            builder: (context, userState) {
              if (userState is UserInitial) {
                context.read<UserBloc>().add(LoadUserProfile(authState.user.uid));
                return const SizedBox.shrink();
              }

              if (userState is UserProfileLoaded) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getRoleIcon(userState.user.role),
                        color: Colors.purple,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getRoleName(userState.user.role),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),

          const SizedBox(height: 24),
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

  String _getRoleName(String roleKey) {
    switch (roleKey) {
      case AppConstants.roleParent:
        return 'Phụ huynh';
      case AppConstants.roleTeacher:
        return 'Giáo viên';
      case AppConstants.roleStudent:
        return 'Học sinh';
      default:
        return 'Người dùng';
    }
  }

  IconData _getRoleIcon(String roleKey) {
    switch (roleKey) {
      case AppConstants.roleParent:
        return Icons.family_restroom;
      case AppConstants.roleTeacher:
        return Icons.school;
      case AppConstants.roleStudent:
        return Icons.face;
      default:
        return Icons.person;
    }
  }
}
