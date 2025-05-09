import 'package:flutter/material.dart';
import '../../../data/models/analytics_model.dart';
import 'package:intl/intl.dart';

class StudentPerformanceCard extends StatelessWidget {
  final StudentAnalytics studentAnalytics;
  final VoidCallback? onTap;

  const StudentPerformanceCard({
    Key? key,
    required this.studentAnalytics,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final analytics = studentAnalytics.analytics;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      studentAnalytics.studentName.isNotEmpty
                          ? studentAnalytics.studentName[0].toUpperCase()
                          : 'S',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          studentAnalytics.studentName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Đã làm ${analytics.totalQuizzesTaken} bài học',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getPerformanceColor(analytics.overallPerformance).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${(analytics.overallPerformance * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getPerformanceColor(analytics.overallPerformance),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: analytics.overallPerformance,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(_getPerformanceColor(analytics.overallPerformance)),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(
                    Icons.star,
                    'Sao',
                    '${analytics.totalStarsEarned}',
                    Colors.amber,
                  ),
                  _buildStatItem(
                    Icons.timer,
                    'Thời gian',
                    _formatTime(analytics.totalTimeSpentSeconds),
                    Colors.purple,
                  ),
                  _buildStatItem(
                    Icons.quiz,
                    'Câu hỏi',
                    '${analytics.totalCorrectAnswers}/${analytics.totalQuestions}',
                    Colors.blue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Color _getPerformanceColor(double performance) {
    if (performance >= 0.8) {
      return Colors.green;
    } else if (performance >= 0.6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
