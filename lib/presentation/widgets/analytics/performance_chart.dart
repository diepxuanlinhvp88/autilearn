import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart' show
  BarChart, BarChartData, BarChartAlignment, BarTouchData, BarTouchTooltipData,
  BarTooltipItem, FlTitlesData, AxisTitles, SideTitles, FlGridData, FlLine,
  FlBorderData, BarChartGroupData, BarChartRodData;
import '../../../core/constants/app_constants.dart';

class PerformanceChart extends StatelessWidget {
  final Map<String, double> performanceByQuizType;

  const PerformanceChart({
    Key? key,
    required this.performanceByQuizType,
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
              'Hiệu suất theo loại bài học',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: performanceByQuizType.isEmpty
                  ? const Center(
                      child: Text('Chưa có dữ liệu hiệu suất'),
                    )
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 1,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBgColor: Colors.blueGrey,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final quizType = _getQuizTypeList()[groupIndex];
                              final value = performanceByQuizType[quizType] ?? 0;
                              return BarTooltipItem(
                                '${_getQuizTypeText(quizType)}\n${(value * 100).toStringAsFixed(1)}%',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final quizTypes = _getQuizTypeList();
                                if (value >= 0 && value < quizTypes.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      _getQuizTypeShortText(quizTypes[value.toInt()]),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value == 0 || value == 0.5 || value == 1) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Text(
                                      '${(value * 100).toInt()}%',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          horizontalInterval: 0.25,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.shade300,
                              strokeWidth: 1,
                            );
                          },
                        ),
                        borderData: FlBorderData(
                          show: false,
                        ),
                        barGroups: _getBarGroups(),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: _getQuizTypeList().map((type) {
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
                      _getQuizTypeText(type),
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

  List<String> _getQuizTypeList() {
    return performanceByQuizType.keys.toList();
  }

  List<BarChartGroupData> _getBarGroups() {
    final quizTypes = _getQuizTypeList();
    return List.generate(quizTypes.length, (index) {
      final quizType = quizTypes[index];
      final value = performanceByQuizType[quizType] ?? 0;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            color: _getQuizTypeColor(quizType),
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });
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

  String _getQuizTypeShortText(String type) {
    switch (type) {
      case AppConstants.choicesQuiz:
        return 'Lựa chọn';
      case AppConstants.pairingQuiz:
        return 'Ghép đôi';
      case AppConstants.sequentialQuiz:
        return 'Sắp xếp';
      case AppConstants.emotionsQuiz:
        return 'Cảm xúc';
      default:
        return 'Khác';
    }
  }
}
