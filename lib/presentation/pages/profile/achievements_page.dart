import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../main.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../presentation/blocs/auth/auth_state.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  // Sample achievements data
  final List<Map<String, dynamic>> _achievements = [
    {
      'id': '1',
      'title': 'Bắt đầu hành trình',
      'description': 'Hoàn thành bài học đầu tiên',
      'icon': Icons.play_circle_filled,
      'color': Colors.blue,
      'isUnlocked': true,
      'progress': 1.0,
    },
    {
      'id': '2',
      'title': 'Nhà thông thái',
      'description': 'Hoàn thành 5 bài học lựa chọn',
      'icon': Icons.check_circle,
      'color': Colors.green,
      'isUnlocked': true,
      'progress': 1.0,
    },
    {
      'id': '3',
      'title': 'Bậc thầy ghép đôi',
      'description': 'Hoàn thành 5 bài học ghép đôi',
      'icon': Icons.compare_arrows,
      'color': Colors.purple,
      'isUnlocked': false,
      'progress': 0.6,
    },
    {
      'id': '4',
      'title': 'Chuyên gia sắp xếp',
      'description': 'Hoàn thành 5 bài học sắp xếp',
      'icon': Icons.sort,
      'color': Colors.orange,
      'isUnlocked': false,
      'progress': 0.2,
    },
    {
      'id': '5',
      'title': 'Siêu sao học tập',
      'description': 'Đạt điểm tuyệt đối trong 3 bài học liên tiếp',
      'icon': Icons.star,
      'color': Colors.amber,
      'isUnlocked': false,
      'progress': 0.3,
    },
    {
      'id': '6',
      'title': 'Người kiên trì',
      'description': 'Học tập 7 ngày liên tiếp',
      'icon': Icons.calendar_today,
      'color': Colors.teal,
      'isUnlocked': false,
      'progress': 0.4,
    },
    {
      'id': '7',
      'title': 'Nhà vô địch',
      'description': 'Hoàn thành tất cả bài học',
      'icon': Icons.emoji_events,
      'color': Colors.deepOrange,
      'isUnlocked': false,
      'progress': 0.1,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => getIt<AuthBloc>(),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Thành tích của tôi'),
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              body: Column(
                children: [
                  // Stats header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          title: 'Tổng thành tích',
                          value: _achievements.length.toString(),
                          icon: Icons.emoji_events,
                        ),
                        _buildStatItem(
                          title: 'Đã đạt được',
                          value: _achievements.where((a) => a['isUnlocked'] == true).length.toString(),
                          icon: Icons.check_circle,
                        ),
                        _buildStatItem(
                          title: 'Đang thực hiện',
                          value: _achievements.where((a) => a['isUnlocked'] == false).length.toString(),
                          icon: Icons.pending_actions,
                        ),
                      ],
                    ),
                  ),
                  
                  // Achievements list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _achievements.length,
                      itemBuilder: (context, index) {
                        final achievement = _achievements[index];
                        return _buildAchievementCard(achievement);
                      },
                    ),
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

  Widget _buildStatItem({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.purple,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    final bool isUnlocked = achievement['isUnlocked'];
    final double progress = achievement['progress'];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                // Achievement icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUnlocked 
                        ? achievement['color'] 
                        : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    achievement['icon'],
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Achievement details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement['title'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked 
                              ? Colors.black 
                              : Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        achievement['description'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Achievement status
                if (isUnlocked)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
              ],
            ),
            // Progress bar for locked achievements
            if (!isUnlocked) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          achievement['color'],
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: achievement['color'],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
