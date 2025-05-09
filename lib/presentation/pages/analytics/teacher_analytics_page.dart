import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../presentation/blocs/auth/auth_state.dart';
import '../../../presentation/blocs/analytics/analytics_bloc.dart';
import '../../../presentation/blocs/analytics/analytics_event.dart';
import '../../../presentation/blocs/analytics/analytics_state.dart';
import '../../../presentation/widgets/analytics/student_performance_card.dart';
import '../../../data/models/analytics_model.dart';
import '../../../main.dart';
import 'student_detail_analytics_page.dart';
import 'package:intl/intl.dart';

class TeacherAnalyticsPage extends StatelessWidget {
  const TeacherAnalyticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AnalyticsBloc>(
      create: (context) => getIt<AnalyticsBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Phân tích học sinh'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                final authState = context.read<AuthBloc>().state;
                if (authState is Authenticated) {
                  context.read<AnalyticsBloc>().add(LoadStudentAnalytics(authState.user.uid));
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
                  }
                },
                builder: (context, state) {
                  if (state is AnalyticsInitial) {
                    // Tải phân tích dữ liệu học sinh khi trang được tạo
                    context.read<AnalyticsBloc>().add(LoadStudentAnalytics(authState.user.uid));
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is AnalyticsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is StudentAnalyticsLoaded) {
                    final studentAnalytics = state.studentAnalytics;

                    if (studentAnalytics.isEmpty) {
                      return const Center(
                        child: Text('Không có dữ liệu học sinh'),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<AnalyticsBloc>().add(LoadStudentAnalytics(authState.user.uid));
                      },
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thông tin tổng quan
                            Card(
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
                                            Icons.people,
                                            'Tổng số học sinh',
                                            '${studentAnalytics.length}',
                                            Colors.blue,
                                          ),
                                        ),
                                        Expanded(
                                          child: _buildSummaryItem(
                                            context,
                                            Icons.check_circle,
                                            'Hiệu suất trung bình',
                                            '${_calculateAveragePerformance(studentAnalytics)}%',
                                            Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Danh sách học sinh
                            const Text(
                              'Danh sách học sinh',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: studentAnalytics.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final student = studentAnalytics[index];
                                return StudentPerformanceCard(
                                  studentAnalytics: student,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => StudentDetailAnalyticsPage(
                                          studentAnalytics: student,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
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

  String _calculateAveragePerformance(List<StudentAnalytics> studentAnalytics) {
    if (studentAnalytics.isEmpty) {
      return '0.0';
    }

    double totalPerformance = 0;
    int count = 0;

    for (final student in studentAnalytics) {
      if (student.analytics.totalQuestions > 0) {
        totalPerformance += student.analytics.overallPerformance;
        count++;
      }
    }

    if (count == 0) {
      return '0.0';
    }

    return ((totalPerformance / count) * 100).toStringAsFixed(1);
  }
}
