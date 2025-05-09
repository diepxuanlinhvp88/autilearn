import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../presentation/blocs/auth/auth_state.dart';
import '../../../presentation/blocs/schedule/schedule_bloc.dart';
import '../../../presentation/blocs/schedule/schedule_event.dart';
import '../../../presentation/blocs/schedule/schedule_state.dart';
import '../../../presentation/blocs/user/user_bloc.dart';
import '../../../presentation/blocs/user/user_state.dart';
import '../../../presentation/blocs/user/user_event.dart';
import '../../../presentation/widgets/schedule/schedule_item_card.dart';
import '../../../main.dart';
import 'schedule_detail_page.dart';
import 'create_schedule_page.dart';

class ScheduleListPage extends StatelessWidget {
  const ScheduleListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Đảm bảo UserBloc đã được tải
    if (context.read<UserBloc>().state is! UserProfileLoaded) {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        context.read<UserBloc>().add(LoadUserProfile(authState.user.uid));
      }
    }

    return BlocProvider<ScheduleBloc>(
      create: (context) => getIt<ScheduleBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lịch học'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateSchedulePage(),
                  ),
                );
              },
              tooltip: 'Tạo lịch học mới',
            ),
          ],
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is Authenticated) {
              return BlocConsumer<ScheduleBloc, ScheduleState>(
                listener: (context, state) {
                  if (state is ScheduleError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else if (state is ScheduleDeleted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã xóa lịch học'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    // Tải lại danh sách lịch học
                    context.read<ScheduleBloc>().add(LoadUserSchedules(authState.user.uid));
                  } else if (state is ScheduleCompleted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã đánh dấu hoàn thành'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    // Tải lại danh sách lịch học
                    context.read<ScheduleBloc>().add(LoadUserSchedules(authState.user.uid));
                  }
                },
                builder: (context, state) {
                  if (state is ScheduleInitial) {
                    // Tải danh sách lịch học khi trang được tạo
                    context.read<ScheduleBloc>().add(LoadUserSchedules(authState.user.uid));
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is ScheduleLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is UserSchedulesLoaded) {
                    final schedules = state.schedules;

                    if (schedules.isEmpty) {
                      return const Center(
                        child: Text('Chưa có lịch học nào'),
                      );
                    }

                    // Sắp xếp lịch học theo thời gian
                    schedules.sort((a, b) => a.startTime.compareTo(b.startTime));

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: schedules.length,
                      itemBuilder: (context, index) {
                        final schedule = schedules[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ScheduleItemCard(
                            schedule: schedule,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ScheduleDetailPage(
                                    scheduleId: schedule.id,
                                  ),
                                ),
                              );
                            },
                            onComplete: !schedule.isCompleted
                                ? () {
                                    context.read<ScheduleBloc>().add(MarkScheduleAsCompleted(schedule.id));
                                  }
                                : null,
                            onDelete: () {
                              _showDeleteConfirmation(context, schedule.id);
                            },
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: Text('Không thể tải danh sách lịch học'),
                    );
                  }
                },
              );
            } else {
              return const Center(
                child: Text('Vui lòng đăng nhập để xem lịch học'),
              );
            }
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String scheduleId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa lịch học này không?'),
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
              context.read<ScheduleBloc>().add(DeleteSchedule(scheduleId));
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
