import 'package:flutter/material.dart';
import '../../../data/models/analytics_model.dart';

class AnalyticsSummaryCard extends StatelessWidget {
  final AnalyticsModel analytics;

  const AnalyticsSummaryCard({
    Key? key,
    required this.analytics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    Icons.quiz,
                    'Bài học đã làm',
                    '${analytics.totalQuizzesTaken}',
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    Icons.check_circle,
                    'Tỷ lệ đúng',
                    '${(analytics.overallPerformance * 100).toStringAsFixed(1)}%',
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    Icons.star,
                    'Sao đã kiếm được',
                    '${analytics.totalStarsEarned}',
                    Colors.amber,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    Icons.timer,
                    'Thời gian học tập',
                    _formatTime(analytics.totalTimeSpentSeconds),
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 30,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
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
