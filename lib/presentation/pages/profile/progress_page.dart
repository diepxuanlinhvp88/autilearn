import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../main.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../presentation/blocs/auth/auth_state.dart';
import '../../../core/constants/app_constants.dart';
import '../../../app/routes.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sample progress data
  final List<Map<String, dynamic>> _quizProgress = [
    {
      'id': '1',
      'title': 'Nhận biết động vật',
      'type': AppConstants.choicesQuiz,
      'score': 8,
      'totalQuestions': 10,
      'completedAt': DateTime.now().subtract(const Duration(days: 1)),
      'timeSpentSeconds': 120,
    },
    {
      'id': '2',
      'title': 'Ghép đôi màu sắc',
      'type': AppConstants.pairingQuiz,
      'score': 6,
      'totalQuestions': 8,
      'completedAt': DateTime.now().subtract(const Duration(days: 2)),
      'timeSpentSeconds': 180,
    },
    {
      'id': '3',
      'title': 'Quy trình đánh răng',
      'type': AppConstants.sequentialQuiz,
      'score': 5,
      'totalQuestions': 5,
      'completedAt': DateTime.now().subtract(const Duration(days: 3)),
      'timeSpentSeconds': 150,
    },
    {
      'id': '4',
      'title': 'Nhận biết hoa quả',
      'type': AppConstants.choicesQuiz,
      'score': 7,
      'totalQuestions': 10,
      'completedAt': DateTime.now().subtract(const Duration(days: 4)),
      'timeSpentSeconds': 200,
    },
    {
      'id': '5',
      'title': 'Ghép đôi đồ vật',
      'type': AppConstants.pairingQuiz,
      'score': 8,
      'totalQuestions': 10,
      'completedAt': DateTime.now().subtract(const Duration(days: 5)),
      'timeSpentSeconds': 220,
    },
  ];

  // Weekly activity data
  final List<Map<String, dynamic>> _weeklyActivity = [
    {'day': 'T2', 'quizzes': 2, 'score': 15},
    {'day': 'T3', 'quizzes': 1, 'score': 8},
    {'day': 'T4', 'quizzes': 3, 'score': 22},
    {'day': 'T5', 'quizzes': 0, 'score': 0},
    {'day': 'T6', 'quizzes': 2, 'score': 18},
    {'day': 'T7', 'quizzes': 4, 'score': 30},
    {'day': 'CN', 'quizzes': 1, 'score': 7},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => getIt<AuthBloc>(),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Tiến trình học tập'),
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: const [
                    Tab(text: 'Hoạt động'),
                    Tab(text: 'Thống kê'),
                  ],
                ),
              ),
              body: TabBarView(
                controller: _tabController,
                children: [
                  // Activity tab
                  _buildActivityTab(),

                  // Statistics tab
                  _buildStatisticsTab(),
                ],
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: 2, // Index for profile tab
                onTap: (index) {
                  if (index != 2) { // If not profile tab
                    Navigator.of(context).pushReplacementNamed(AppRouter.home);
                    // Sau khi chuyển đến trang Home, cần cập nhật selectedIndex
                    // Điều này sẽ được xử lý trong HomePage
                  }
                },
                selectedItemColor: Colors.blue,
                unselectedItemColor: Colors.grey,
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
                type: BottomNavigationBarType.fixed,
                elevation: 10,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    activeIcon: Icon(Icons.home_filled),
                    label: 'Trang chủ',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.quiz_outlined),
                    activeIcon: Icon(Icons.quiz),
                    label: 'Bài học',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: 'Hồ sơ',
                  ),
                ],
              ),
            );
          } else {
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

  Widget _buildActivityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekly activity chart
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hoạt động trong tuần',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: _weeklyActivity.map((day) {
                        final double height = day['score'] * 5.0;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  height: height,
                                  decoration: BoxDecoration(
                                    color: day['quizzes'] > 0
                                        ? Colors.purple
                                        : Colors.grey.shade300,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(8),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  day['day'],
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${day['quizzes']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Recent activities
          const Text(
            'Hoạt động gần đây',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _quizProgress.length,
            itemBuilder: (context, index) {
              final progress = _quizProgress[index];
              return _buildProgressCard(progress);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    // Calculate statistics
    int totalQuizzes = _quizProgress.length;
    int totalQuestions = _quizProgress.fold(0, (sum, item) => sum + (item['totalQuestions'] as int));
    int totalCorrect = _quizProgress.fold(0, (sum, item) => sum + (item['score'] as int));
    double averageScore = totalQuizzes > 0
        ? _quizProgress.fold(0.0, (sum, item) => sum + (item['score'] as int) / (item['totalQuestions'] as int)) / totalQuizzes
        : 0.0;

    // Count by quiz type
    int choicesCount = _quizProgress.where((q) => q['type'] == AppConstants.choicesQuiz).length;
    int pairingCount = _quizProgress.where((q) => q['type'] == AppConstants.pairingQuiz).length;
    int sequentialCount = _quizProgress.where((q) => q['type'] == AppConstants.sequentialQuiz).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall stats
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tổng quan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        title: 'Bài học',
                        value: totalQuizzes.toString(),
                        icon: Icons.quiz,
                        color: Colors.blue,
                      ),
                      _buildStatItem(
                        title: 'Câu hỏi',
                        value: totalQuestions.toString(),
                        icon: Icons.question_answer,
                        color: Colors.orange,
                      ),
                      _buildStatItem(
                        title: 'Đúng',
                        value: totalCorrect.toString(),
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tỷ lệ đúng',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: totalQuestions > 0 ? totalCorrect / totalQuestions : 0,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tỷ lệ: ${totalQuestions > 0 ? (totalCorrect / totalQuestions * 100).toStringAsFixed(1) : 0}%',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Quiz types distribution
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Phân bố loại bài học',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuizTypeProgress(
                    title: 'Bài học lựa chọn',
                    count: choicesCount,
                    total: totalQuizzes,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildQuizTypeProgress(
                    title: 'Bài học ghép đôi',
                    count: pairingCount,
                    total: totalQuizzes,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildQuizTypeProgress(
                    title: 'Bài học sắp xếp',
                    count: sequentialCount,
                    total: totalQuizzes,
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Average score
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Điểm trung bình',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${(averageScore * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                            const Text(
                              'Điểm số',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(Map<String, dynamic> progress) {
    final int score = progress['score'];
    final int total = progress['totalQuestions'];
    final double percentage = score / total;
    final String formattedDate = _formatDate(progress['completedAt']);
    final String formattedTime = _formatTime(progress['timeSpentSeconds']);

    Color typeColor;
    IconData typeIcon;

    switch (progress['type']) {
      case AppConstants.choicesQuiz:
        typeColor = Colors.blue;
        typeIcon = Icons.check_circle;
        break;
      case AppConstants.pairingQuiz:
        typeColor = Colors.green;
        typeIcon = Icons.compare_arrows;
        break;
      case AppConstants.sequentialQuiz:
        typeColor = Colors.orange;
        typeIcon = Icons.sort;
        break;
      default:
        typeColor = Colors.purple;
        typeIcon = Icons.quiz;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    typeIcon,
                    color: typeColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        progress['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hoàn thành: $formattedDate • $formattedTime',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getScoreColor(percentage).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$score/$total',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(percentage),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(percentage)),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildQuizTypeProgress({
    required String title,
    required int count,
    required int total,
    required Color color,
  }) {
    final double percentage = total > 0 ? count / total : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$count/$total',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
