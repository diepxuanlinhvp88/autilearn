import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentStatsCard extends StatelessWidget {
  final String studentId;

  const StudentStatsCard({
    Key? key,
    required this.studentId,
  }) : super(key: key);

  Future<Map<String, dynamic>> _loadStudentStats() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('student_stats')
          .doc(studentId)
          .get();
      
      if (snapshot.exists) {
        return snapshot.data() ?? {};
      }
      return {};
    } catch (e) {
      debugPrint('Error loading student stats: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadStudentStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final stats = snapshot.data ?? {};
        final completionRate = stats['completionRate'] ?? '0/0';
        final averageScore = stats['averageScore'] ?? '0/100';
        final studyTime = stats['totalStudyTime'] ?? '0 phút';

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Thống kê học tập',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        // Force rebuild to refresh data
                        (context as Element).markNeedsBuild();
                      },
                      tooltip: 'Làm mới',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatItem(
                      icon: Icons.assignment_turned_in,
                      label: 'Hoàn thành',
                      value: completionRate,
                      color: Colors.green,
                    ),
                    _buildStatItem(
                      icon: Icons.star,
                      label: 'Điểm số',
                      value: averageScore,
                      color: Colors.amber,
                    ),
                    _buildStatItem(
                      icon: Icons.timer,
                      label: 'Thời gian',
                      value: studyTime,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 