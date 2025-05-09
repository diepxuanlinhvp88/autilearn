import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../presentation/blocs/auth/auth_state.dart';
import '../../../presentation/blocs/user/user_bloc.dart';
import '../../../presentation/blocs/user/user_state.dart';
import '../../../presentation/blocs/user/user_event.dart';
import '../../../core/constants/app_constants.dart';
import '../../../presentation/blocs/assessment/assessment_bloc.dart';
import '../../../presentation/blocs/assessment/assessment_event.dart';
import '../../../presentation/blocs/assessment/assessment_state.dart';
import '../../../presentation/widgets/assessment/assessment_summary_card.dart';
import '../../../data/models/skill_assessment_model.dart';
import '../../../main.dart';
import 'assessment_detail_page.dart';
import 'create_assessment_page.dart';

class AssessmentListPage extends StatelessWidget {
  final String? studentId;

  const AssessmentListPage({
    Key? key,
    this.studentId,
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
          title: const Text('Đánh giá kỹ năng'),
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
                  return IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CreateAssessmentPage(
                            studentId: studentId,
                          ),
                        ),
                      );
                    },
                    tooltip: 'Tạo đánh giá mới',
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is Authenticated) {
              return BlocConsumer<AssessmentBloc, AssessmentState>(
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

                    // Tải lại danh sách đánh giá
                    final userState = context.read<UserBloc>().state;
                    String userRole = AppConstants.roleStudent;
                    if (userState is UserProfileLoaded) {
                      userRole = userState.user.role;
                    }

                    if (userRole == AppConstants.roleTeacher) {
                      context.read<AssessmentBloc>().add(LoadTeacherAssessments(authState.user.uid));
                    } else {
                      context.read<AssessmentBloc>().add(LoadStudentAssessments(studentId ?? authState.user.uid));
                    }
                  }
                },
                builder: (context, state) {
                  if (state is AssessmentInitial) {
                    // Tải danh sách đánh giá khi trang được tạo
                    final userState = context.read<UserBloc>().state;
                    String role = AppConstants.roleStudent;
                    if (userState is UserProfileLoaded) {
                      role = userState.user.role;
                    }
                    if (role == AppConstants.roleTeacher && studentId == null) {
                      context.read<AssessmentBloc>().add(LoadTeacherAssessments(authState.user.uid));
                    } else {
                      context.read<AssessmentBloc>().add(LoadStudentAssessments(studentId ?? authState.user.uid));
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is AssessmentLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is StudentAssessmentsLoaded || state is TeacherAssessmentsLoaded) {
                    final List<SkillAssessmentModel> assessments;
                    if (state is StudentAssessmentsLoaded) {
                      assessments = state.assessments;
                    } else {
                      assessments = (state as TeacherAssessmentsLoaded).assessments;

                      // Lọc theo học sinh nếu có
                      if (studentId != null) {
                        assessments.retainWhere((assessment) => assessment.studentId == studentId);
                      }
                    }

                    if (assessments.isEmpty) {
                      return const Center(
                        child: Text('Chưa có đánh giá nào'),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: assessments.length,
                      itemBuilder: (context, index) {
                        final assessment = assessments[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: AssessmentSummaryCard(
                            assessment: assessment,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AssessmentDetailPage(
                                    assessmentId: assessment.id,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: Text('Không thể tải danh sách đánh giá'),
                    );
                  }
                },
              );
            } else {
              return const Center(
                child: Text('Vui lòng đăng nhập để xem đánh giá'),
              );
            }
          },
        ),
      ),
    );
  }
}
