import 'package:flutter/material.dart';
import '../../../data/models/analytics_model.dart';
import '../../../core/constants/app_constants.dart';
import 'package:intl/intl.dart' show DateFormat;

class RecentPerformanceList extends StatelessWidget {
  final List<QuizPerformance> recentPerformance;

  const RecentPerformanceList({
    Key? key,
    required this.recentPerformance,
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
              'Hoạt động gần đây',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            recentPerformance.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Chưa có hoạt động nào'),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentPerformance.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final performance = recentPerformance[index];
                      return _buildPerformanceItem(context, performance);
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceItem(BuildContext context, QuizPerformance performance) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _getQuizTypeColor(performance.quizType).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            _getQuizTypeIcon(performance.quizType),
            color: _getQuizTypeColor(performance.quizType),
            size: 24,
          ),
        ),
      ),
      title: Text(
        performance.quizTitle,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            'Điểm: ${performance.score}/${performance.totalQuestions} (${(performance.performancePercentage * 100).toStringAsFixed(1)}%)',
            style: TextStyle(
              color: _getPerformanceColor(performance.performancePercentage),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Ngày: ${DateFormat('dd/MM/yyyy HH:mm').format(performance.completedAt)}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            color: Colors.amber,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '${performance.starsEarned}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getQuizTypeColor(String type) {
    switch (type) {
      case AppConstants.choicesQuiz:
        return Colors.blue;
      case AppConstants.pairingQuiz:
        return Colors.green;
      case AppConstants.sequentialQuiz:
        return Colors.orange;
      case AppConstants.emotionsQuiz:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getQuizTypeIcon(String type) {
    switch (type) {
      case AppConstants.choicesQuiz:
        return Icons.check_circle;
      case AppConstants.pairingQuiz:
        return Icons.compare_arrows;
      case AppConstants.sequentialQuiz:
        return Icons.sort;
      case AppConstants.emotionsQuiz:
        return Icons.emoji_emotions;
      default:
        return Icons.quiz;
    }
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
}
