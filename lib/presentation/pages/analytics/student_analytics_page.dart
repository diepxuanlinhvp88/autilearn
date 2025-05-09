import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../presentation/blocs/auth/auth_state.dart';
import '../../../presentation/blocs/analytics/analytics_bloc.dart';
import '../../../presentation/blocs/analytics/analytics_event.dart';
import '../../../presentation/blocs/analytics/analytics_state.dart';
import '../../../presentation/widgets/analytics/analytics_summary_card.dart';
import '../../../presentation/widgets/analytics/performance_chart.dart';
import '../../../presentation/widgets/analytics/quiz_distribution_chart.dart';
import '../../../presentation/widgets/analytics/progress_timeline_chart.dart';
import '../../../presentation/widgets/analytics/recent_performance_list.dart';
import '../../../main.dart';

class StudentAnalyticsPage extends StatelessWidget {
  const StudentAnalyticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AnalyticsBloc>(
      create: (context) => getIt<AnalyticsBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Phân tích học tập'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                final authState = context.read<AuthBloc>().state;
                if (authState is Authenticated) {
                  context.read<AnalyticsBloc>().add(UpdateAnalyticsFromProgress(authState.user.uid));
                }
              },
              tooltip: 'Cập nhật dữ liệu',
            ),
          ],
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is Authenticated) {
              return BlocConsumer<AnalyticsBloc, AnalyticsState>(
                listener: (context, state) {
                  if (state is AnalyticsError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else if (state is AnalyticsUpdated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Dữ liệu đã được cập nhật'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is AnalyticsInitial) {
                    // Tải phân tích dữ liệu khi trang được tạo
                    context.read<AnalyticsBloc>().add(LoadUserAnalytics(authState.user.uid));
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is AnalyticsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is UserAnalyticsLoaded) {
                    final analytics = state.analytics;
                    
                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<AnalyticsBloc>().add(UpdateAnalyticsFromProgress(authState.user.uid));
                      },
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tổng quan
                            AnalyticsSummaryCard(analytics: analytics),
                            const SizedBox(height: 16),
                            
                            // Biểu đồ hiệu suất
                            if (analytics.performanceByQuizType.isNotEmpty) ...[
                              PerformanceChart(
                                performanceByQuizType: analytics.performanceByQuizType,
                              ),
                              const SizedBox(height: 16),
                            ],
                            
                            // Biểu đồ phân bố
                            if (analytics.quizTypeDistribution.isNotEmpty) ...[
                              QuizDistributionChart(
                                quizTypeDistribution: analytics.quizTypeDistribution,
                              ),
                              const SizedBox(height: 16),
                            ],
                            
                            // Biểu đồ tiến độ
                            if (analytics.recentPerformance.isNotEmpty) ...[
                              ProgressTimelineChart(
                                recentPerformance: analytics.recentPerformance,
                              ),
                              const SizedBox(height: 16),
                            ],
                            
                            // Danh sách hoạt động gần đây
                            RecentPerformanceList(
                              recentPerformance: analytics.recentPerformance,
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return const Center(
                      child: Text('Không thể tải dữ liệu phân tích'),
                    );
                  }
                },
              );
            } else {
              return const Center(
                child: Text('Vui lòng đăng nhập để xem phân tích dữ liệu'),
              );
            }
          },
        ),
      ),
    );
  }
}
