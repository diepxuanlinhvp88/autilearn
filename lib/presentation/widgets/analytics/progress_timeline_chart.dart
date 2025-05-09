import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart' show
  LineChart, LineChartData, LineTouchData, LineTouchTooltipData, LineTooltipItem,
  FlTitlesData, AxisTitles, SideTitles, FlGridData, FlLine, FlBorderData,
  LineChartBarData, FlSpot, FlDotData, FlDotCirclePainter, BarAreaData;
import '../../../data/models/analytics_model.dart';
import 'package:intl/intl.dart';

class ProgressTimelineChart extends StatelessWidget {
  final List<QuizPerformance> recentPerformance;

  const ProgressTimelineChart({
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
              'Tiến độ theo thời gian',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: recentPerformance.isEmpty
                  ? const Center(
                      child: Text('Chưa có dữ liệu tiến độ'),
                    )
                  : LineChart(
                      LineChartData(
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            tooltipBgColor: Colors.blueGrey,
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                final index = spot.x.toInt();
                                if (index >= 0 && index < recentPerformance.length) {
                                  final performance = recentPerformance[index];
                                  return LineTooltipItem(
                                    '${performance.quizTitle}\n${DateFormat('dd/MM/yyyy').format(performance.completedAt)}\nĐiểm: ${performance.score}/${performance.totalQuestions}',
                                    const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }
                                return null;
                              }).toList();
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < recentPerformance.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      DateFormat('dd/MM').format(recentPerformance[index].completedAt),
                                      style: const TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                              reservedSize: 30,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value % 0.2 == 0) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Text(
                                      '${(value * 100).toInt()}%',
                                      style: const TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                              reservedSize: 40,
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
                          horizontalInterval: 0.2,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.shade300,
                              strokeWidth: 1,
                            );
                          },
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        minX: 0,
                        maxX: recentPerformance.length.toDouble() - 1,
                        minY: 0,
                        maxY: 1,
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(recentPerformance.length, (index) {
                              final performance = recentPerformance[index];
                              return FlSpot(
                                index.toDouble(),
                                performance.performancePercentage,
                              );
                            }),
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: Colors.blue,
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.blue.withOpacity(0.2),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
