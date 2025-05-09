import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart' show
  PieChart, PieChartData, PieTouchData, FlTouchEvent, PieChartSectionData;
import '../../../core/constants/app_constants.dart';

class QuizDistributionChart extends StatelessWidget {
  final Map<String, int> quizTypeDistribution;

  const QuizDistributionChart({
    Key? key,
    required this.quizTypeDistribution,
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
              'Phân bố loại bài học',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: quizTypeDistribution.isEmpty
                  ? const Center(
                      child: Text('Chưa có dữ liệu phân bố'),
                    )
                  : PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: _getSections(),
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: quizTypeDistribution.keys.map((type) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getQuizTypeColor(type),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_getQuizTypeText(type)} (${quizTypeDistribution[type]})',
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getSections() {
    final total = quizTypeDistribution.values.fold<int>(0, (sum, value) => sum + value);

    return quizTypeDistribution.entries.map((entry) {
      final type = entry.key;
      final count = entry.value;
      final percentage = total > 0 ? count / total : 0;

      return PieChartSectionData(
        color: _getQuizTypeColor(type),
        value: count.toDouble(),
        title: '${(percentage * 100).toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
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

  String _getQuizTypeText(String type) {
    switch (type) {
      case AppConstants.choicesQuiz:
        return 'Bài học lựa chọn';
      case AppConstants.pairingQuiz:
        return 'Bài học ghép đôi';
      case AppConstants.sequentialQuiz:
        return 'Bài học sắp xếp';
      case AppConstants.emotionsQuiz:
        return 'Nhận diện cảm xúc';
      default:
        return 'Khác';
    }
  }
}
