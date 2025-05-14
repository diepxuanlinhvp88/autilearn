import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class StudentProgressChart extends StatelessWidget {
  final String studentId;

  const StudentProgressChart({
    Key? key,
    required this.studentId,
  }) : super(key: key);

  Future<List<Map<String, dynamic>>> _loadProgressData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('student_progress')
          .doc(studentId)
          .collection('weekly_data')
          .orderBy('week')
          .limitToLast(5)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('Error loading progress data: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadProgressData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final progressData = snapshot.data ?? [];
        final spots = List<FlSpot>.generate(
          progressData.length,
          (index) => FlSpot(
            index.toDouble(),
            (progressData[index]['score'] as num?)?.toDouble() ?? 0.0,
          ),
        );

        if (spots.isEmpty) {
          spots.addAll(const [
            FlSpot(0, 0),
            FlSpot(1, 0),
            FlSpot(2, 0),
            FlSpot(3, 0),
            FlSpot(4, 0),
          ]);
        }

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
                      'Tiến độ học tập',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        (context as Element).markNeedsBuild();
                      },
                      tooltip: 'Làm mới',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: 20,
                        verticalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.shade200,
                            strokeWidth: 1,
                          );
                        },
                        getDrawingVerticalLine: (value) {
                          return FlLine(
                            color: Colors.grey.shade200,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 20,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final weekNum = value.toInt() + 1;
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Tuần $weekNum',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      minX: 0,
                      maxX: spots.length.toDouble() - 1,
                      minY: 0,
                      maxY: 100,
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: Theme.of(context).primaryColor,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: Theme.of(context).primaryColor,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLegendItem(
                      context: context,
                      label: 'Điểm trung bình',
                      value: _calculateAverage(progressData),
                      color: Theme.of(context).primaryColor,
                    ),
                    _buildLegendItem(
                      context: context,
                      label: 'Tăng trưởng',
                      value: _calculateGrowth(progressData),
                      color: Colors.green,
                    ),
                    _buildLegendItem(
                      context: context,
                      label: 'Xếp hạng',
                      value: progressData.isNotEmpty ? progressData.last['rank']?.toString() ?? 'N/A' : 'N/A',
                      color: Colors.orange,
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

  String _calculateAverage(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return '0/100';
    final scores = data.map((e) => (e['score'] as num?)?.toDouble() ?? 0.0).toList();
    final average = scores.reduce((a, b) => a + b) / scores.length;
    return '${average.toStringAsFixed(1)}/100';
  }

  String _calculateGrowth(List<Map<String, dynamic>> data) {
    if (data.length < 2) return '0%';
    final firstScore = data.first['score'] as num? ?? 0;
    final lastScore = data.last['score'] as num? ?? 0;
    if (firstScore == 0) return '0%';
    final growth = ((lastScore - firstScore) / firstScore * 100);
    final sign = growth >= 0 ? '+' : '';
    return '$sign${growth.toStringAsFixed(1)}%';
  }

  Widget _buildLegendItem({
    required BuildContext context,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
} 