import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../presentation/blocs/auth/auth_state.dart';
import '../../../presentation/blocs/user/user_bloc.dart';
import '../../../presentation/blocs/user/user_state.dart';
import '../../../presentation/blocs/user/user_event.dart';
import '../../../core/constants/app_constants.dart';
import '../../../presentation/blocs/assessment/assessment_bloc.dart';
import '../../../presentation/blocs/assessment/assessment_event.dart';
import '../../../presentation/blocs/assessment/assessment_state.dart';
import '../../../presentation/widgets/assessment/skill_category_card.dart';
import '../../../data/models/skill_assessment_model.dart';
import '../../../main.dart';
import 'edit_assessment_page.dart';

class AssessmentDetailPage extends StatelessWidget {
  final String assessmentId;

  const AssessmentDetailPage({
    Key? key,
    required this.assessmentId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Đảm bảo UserBloc đã được tải
    if (context.read<UserBloc>().state is! UserProfileLoaded) {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        context.read<UserBloc>().add(LoadUserProfile(authState.user.uid));
      }
    }

    return BlocProvider<AssessmentBloc>(
      create: (context) => getIt<AssessmentBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết đánh giá'),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          actions: [
            BlocBuilder<UserBloc, UserState>(
              builder: (context, userState) {
                String role = AppConstants.roleStudent;
                if (userState is UserProfileLoaded) {
                  role = userState.user.role;
                }
                if (role == AppConstants.roleTeacher || role == AppConstants.roleParent) {
                  return BlocBuilder<AssessmentBloc, AssessmentState>(
                    builder: (context, state) {
                      if (state is AssessmentLoaded) {
                        return Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => EditAssessmentPage(
                                      assessment: state.assessment,
                                    ),
                                  ),
                                );
                              },
                              tooltip: 'Chỉnh sửa đánh giá',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _showDeleteConfirmation(context);
                              },
                              tooltip: 'Xóa đánh giá',
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocConsumer<AssessmentBloc, AssessmentState>(
          listener: (context, state) {
            if (state is AssessmentError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is AssessmentDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã xóa đánh giá'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(context).pop();
            }
          },
          builder: (context, state) {
            if (state is AssessmentInitial) {
              // Tải chi tiết đánh giá khi trang được tạo
              context.read<AssessmentBloc>().add(LoadAssessment(assessmentId));
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is AssessmentLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is AssessmentLoaded) {
              final assessment = state.assessment;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAssessmentHeader(context, assessment),
                    const SizedBox(height: 24),
                    ...assessment.skillCategories.entries.map((entry) {
                      final categoryKey = entry.key;
                      final category = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: SkillCategoryCard(
                          categoryKey: categoryKey,
                          category: category,
                          isEditable: false,
                        ),
                      );
                    }).toList(),
                    if (assessment.notes.isNotEmpty) ...[
                      const SizedBox(height: 16),
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
                                'Ghi chú',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                assessment.notes,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            } else {
              return const Center(
                child: Text('Không thể tải chi tiết đánh giá'),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildAssessmentHeader(BuildContext context, SkillAssessmentModel assessment) {
    // Tính điểm trung bình
    double averageLevel = 0;
    int totalSkills = 0;

    assessment.skillCategories.forEach((_, category) {
      category.skills.forEach((_, skill) {
        averageLevel += skill.level;
        totalSkills++;
      });
    });

    if (totalSkills > 0) {
      averageLevel /= totalSkills;
    }

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
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getAverageLevelColor(averageLevel).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      averageLevel.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getAverageLevelColor(averageLevel),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đánh giá ngày ${DateFormat('dd/MM/yyyy').format(assessment.assessmentDate)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Giáo viên: ${assessment.teacherId}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Học sinh: ${assessment.studentId}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Tổng quan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildStatItem(
                  'Danh mục',
                  '${assessment.skillCategories.length}',
                  Colors.blue,
                ),
                _buildStatItem(
                  'Kỹ năng',
                  '$totalSkills',
                  Colors.green,
                ),
                _buildStatItem(
                  'Điểm TB',
                  averageLevel.toStringAsFixed(1),
                  _getAverageLevelColor(averageLevel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getAverageLevelColor(double level) {
    if (level < 1.5) {
      return Colors.red;
    } else if (level < 2.5) {
      return Colors.orange;
    } else if (level < 3.5) {
      return Colors.yellow.shade700;
    } else if (level < 4.5) {
      return Colors.lightGreen;
    } else {
      return Colors.green;
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa đánh giá này không?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AssessmentBloc>().add(DeleteAssessment(assessmentId));
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
