import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../presentation/blocs/analytics/analytics_bloc.dart';
import '../../../presentation/blocs/analytics/analytics_event.dart';
import '../../../presentation/widgets/analytics/analytics_summary_card.dart';
import '../../../presentation/widgets/analytics/performance_chart.dart';
import '../../../presentation/widgets/analytics/quiz_distribution_chart.dart';
import '../../../presentation/widgets/analytics/progress_timeline_chart.dart';
import '../../../presentation/widgets/analytics/recent_performance_list.dart';
import '../../../data/models/analytics_model.dart';
import '../../../main.dart';
import 'package:intl/intl.dart';

class StudentDetailAnalyticsPage extends StatelessWidget {
  final StudentAnalytics studentAnalytics;

  const StudentDetailAnalyticsPage({
    Key? key,
    required this.studentAnalytics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AnalyticsBloc>(
      create: (context) => getIt<AnalyticsBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Phân tích: ${studentAnalytics.studentName}'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<AnalyticsBloc>().add(UpdateAnalyticsFromProgress(studentAnalytics.studentId));
              },
              tooltip: 'Cập nhật dữ liệu',
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            context.read<AnalyticsBloc>().add(UpdateAnalyticsFromProgress(studentAnalytics.studentId));
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thông tin học sinh
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            studentAnalytics.studentName.isNotEmpty
                                ? studentAnalytics.studentName[0].toUpperCase()
                                : 'S',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                studentAnalytics.studentName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'ID: ${studentAnalytics.studentId}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tổng quan
                AnalyticsSummaryCard(analytics: studentAnalytics.analytics),
                const SizedBox(height: 16),

                // Biểu đồ hiệu suất
                if (studentAnalytics.analytics.performanceByQuizType.isNotEmpty) ...[
                  PerformanceChart(
                    performanceByQuizType: studentAnalytics.analytics.performanceByQuizType,
                  ),
                  const SizedBox(height: 16),
                ],

                // Biểu đồ phân bố
                if (studentAnalytics.analytics.quizTypeDistribution.isNotEmpty) ...[
                  QuizDistributionChart(
                    quizTypeDistribution: studentAnalytics.analytics.quizTypeDistribution,
                  ),
                  const SizedBox(height: 16),
                ],

                // Biểu đồ tiến độ
                if (studentAnalytics.analytics.recentPerformance.isNotEmpty) ...[
                  ProgressTimelineChart(
                    recentPerformance: studentAnalytics.analytics.recentPerformance,
                  ),
                  const SizedBox(height: 16),
                ],

                // Danh sách hoạt động gần đây
                RecentPerformanceList(
                  recentPerformance: studentAnalytics.analytics.recentPerformance,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
