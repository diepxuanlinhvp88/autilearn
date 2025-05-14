import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../presentation/blocs/auth/auth_state.dart';
import '../../../presentation/blocs/teacher_student/teacher_student_bloc.dart';
import '../../../presentation/blocs/teacher_student/teacher_student_event.dart';
import '../../../presentation/blocs/teacher_student/teacher_student_state.dart';
import '../../../data/models/user_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/teacher_student_repository.dart';
import '../../widgets/student/student_stats_card.dart';
import '../../widgets/student/student_progress_chart.dart';

class ManageStudentsPage extends StatelessWidget {
  const ManageStudentsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) {
          return const Center(child: CircularProgressIndicator());
        }

        return BlocProvider<TeacherStudentBloc>(
          create: (context) => TeacherStudentBloc(
            repository: context.read<TeacherStudentRepository>(),
          )..add(LoadTeacherStudents(authState.user.uid)),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Quản lý học sinh'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: () {
                    _showAddStudentDialog(context, authState.user.uid);
                  },
                  tooltip: 'Thêm học sinh',
                ),
              ],
            ),
            body: BlocBuilder<TeacherStudentBloc, TeacherStudentState>(
              builder: (context, state) {
                if (state is TeacherStudentLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is TeacherStudentError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Đã xảy ra lỗi: ${state.message}',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<TeacherStudentBloc>().add(
                              LoadTeacherStudents(authState.user.uid),
                            );
                          },
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is TeacherStudentsLoaded) {
                  if (state.students.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.people_outline,
                            size: 100,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Chưa có học sinh nào được liên kết',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              _showAddStudentDialog(context, authState.user.uid);
                            },
                            icon: const Icon(Icons.person_add),
                            label: const Text('Thêm học sinh'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.students.length,
                    itemBuilder: (context, index) {
                      final student = state.students[index];
                      return _buildStudentCard(context, student, authState.user.uid);
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildStudentCard(BuildContext context, UserModel student, String teacherId) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple.shade100,
              child: Text(
                student.name[0].toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ),
            title: Text(
              student.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(student.email),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.analytics_outlined),
                  onPressed: () {
                    _showStudentDetailsDialog(context, student);
                  },
                  tooltip: 'Xem chi tiết',
                ),
                IconButton(
                  icon: const Icon(Icons.link_off),
                  onPressed: () {
                    _showUnlinkConfirmation(context, student, teacherId);
                  },
                  tooltip: 'Hủy liên kết',
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StudentStatsCard(studentId: student.id),
                const SizedBox(height: 16),
                StudentProgressChart(studentId: student.id),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddStudentDialog(BuildContext context, String teacherId) {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm học sinh'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Nhập email của học sinh để thêm vào danh sách của bạn',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email học sinh',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  if (!value.contains('@')) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                // TODO: Implement student linking by email
                context.read<TeacherStudentBloc>().add(
                  LinkTeacherStudent(
                    teacherId: teacherId,
                    studentId: emailController.text,
                  ),
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showUnlinkConfirmation(BuildContext context, UserModel student, String teacherId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy liên kết'),
        content: Text('Bạn có chắc chắn muốn hủy liên kết với học sinh ${student.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Không'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TeacherStudentBloc>().add(
                UnlinkTeacherStudent(
                  teacherId: teacherId,
                  studentId: student.id,
                ),
              );
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Có'),
          ),
        ],
      ),
    );
  }

  void _showStudentDetailsDialog(BuildContext context, UserModel student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chi tiết học sinh: ${student.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email'),
                subtitle: Text(student.email),
              ),
              const Divider(),
              const ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text('Ngày tham gia'),
                subtitle: Text('01/01/2024'), // TODO: Use actual date
              ),
              const Divider(),
              const ListTile(
                leading: Icon(Icons.star),
                title: Text('Điểm tích lũy'),
                subtitle: Text('250'), // TODO: Use actual points
              ),
              const Divider(),
              const ListTile(
                leading: Icon(Icons.emoji_events),
                title: Text('Huy hiệu đạt được'),
                subtitle: Text('5'), // TODO: Use actual badges count
              ),
              const Divider(),
              const ListTile(
                leading: Icon(Icons.timeline),
                title: Text('Tiến độ học tập'),
                subtitle: Text('75%'), // TODO: Use actual progress
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to detailed analytics page
              Navigator.of(context).pop();
            },
            child: const Text('Xem phân tích chi tiết'),
          ),
        ],
      ),
    );
  }
} 