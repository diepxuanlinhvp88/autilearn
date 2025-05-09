import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../presentation/blocs/schedule/schedule_bloc.dart';
import '../../../presentation/blocs/schedule/schedule_event.dart';
import '../../../presentation/blocs/schedule/schedule_state.dart';
import '../../../presentation/blocs/user/user_bloc.dart';
import '../../../presentation/blocs/user/user_state.dart';
import '../../../presentation/blocs/user/user_event.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../presentation/blocs/auth/auth_state.dart';
import '../../../data/models/schedule_model.dart';
import '../../../main.dart';
import 'edit_schedule_page.dart';

class ScheduleDetailPage extends StatelessWidget {
  final String scheduleId;

  const ScheduleDetailPage({
    Key? key,
    required this.scheduleId,
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

    return BlocProvider<ScheduleBloc>(
      create: (context) => getIt<ScheduleBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết lịch học'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          actions: [
            BlocBuilder<ScheduleBloc, ScheduleState>(
              builder: (context, state) {
                if (state is ScheduleLoaded) {
                  return Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EditSchedulePage(
                                schedule: state.schedule,
                              ),
                            ),
                          );
                        },
                        tooltip: 'Chỉnh sửa lịch học',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _showDeleteConfirmation(context);
                        },
                        tooltip: 'Xóa lịch học',
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocConsumer<ScheduleBloc, ScheduleState>(
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
              Navigator.of(context).pop();
            } else if (state is ScheduleCompleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã đánh dấu hoàn thành'),
                  backgroundColor: Colors.green,
                ),
              );
              context.read<ScheduleBloc>().add(LoadSchedule(scheduleId));
            }
          },
          builder: (context, state) {
            if (state is ScheduleInitial) {
              // Tải chi tiết lịch học khi trang được tạo
              context.read<ScheduleBloc>().add(LoadSchedule(scheduleId));
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is ScheduleLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is ScheduleLoaded) {
              final schedule = state.schedule;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildScheduleHeader(context, schedule),
                    const SizedBox(height: 24),
                    if (schedule.description.isNotEmpty) ...[
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
                                'Mô tả',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                schedule.description,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (schedule.isRecurring) ...[
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
                                'Lặp lại',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getRecurrenceText(schedule),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              if (schedule.recurrenceEndDate != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Kết thúc vào: ${DateFormat('dd/MM/yyyy').format(schedule.recurrenceEndDate!)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (schedule.hasReminder) ...[
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
                                'Nhắc nhở',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Nhắc nhở ${schedule.reminderMinutesBefore} phút trước khi bắt đầu',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (!schedule.isCompleted) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.read<ScheduleBloc>().add(MarkScheduleAsCompleted(scheduleId));
                          },
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Đánh dấu đã hoàn thành'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            } else {
              return const Center(
                child: Text('Không thể tải chi tiết lịch học'),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildScheduleHeader(BuildContext context, ScheduleModel schedule) {
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
                    color: _getTypeColor(schedule.type).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      _getTypeIcon(schedule.type),
                      color: _getTypeColor(schedule.type),
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          decoration: schedule.isCompleted ? TextDecoration.lineThrough : null,
                          color: schedule.isCompleted ? Colors.grey : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getTypeText(schedule.type),
                        style: TextStyle(
                          fontSize: 14,
                          color: _getTypeColor(schedule.type),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (schedule.isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.green,
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      'Đã hoàn thành',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Ngày',
                    DateFormat('dd/MM/yyyy').format(schedule.startTime),
                    Icons.calendar_today,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Thời gian',
                    '${DateFormat('HH:mm').format(schedule.startTime)} - ${DateFormat('HH:mm').format(schedule.endTime)}',
                    Icons.access_time,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.blue,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getRecurrenceText(ScheduleModel schedule) {
    switch (schedule.recurrenceType) {
      case RecurrenceType.daily:
        return 'Lặp lại hàng ngày';
      case RecurrenceType.weekly:
        final days = schedule.recurrenceDays.map((day) => _getDayName(day)).join(', ');
        return 'Lặp lại hàng tuần vào $days';
      case RecurrenceType.monthly:
        return 'Lặp lại hàng tháng vào ngày ${schedule.startTime.day}';
      default:
        return '';
    }
  }

  String _getDayName(int day) {
    switch (day) {
      case 1:
        return 'Thứ 2';
      case 2:
        return 'Thứ 3';
      case 3:
        return 'Thứ 4';
      case 4:
        return 'Thứ 5';
      case 5:
        return 'Thứ 6';
      case 6:
        return 'Thứ 7';
      case 7:
        return 'Chủ nhật';
      default:
        return '';
    }
  }

  Color _getTypeColor(ScheduleType type) {
    switch (type) {
      case ScheduleType.lesson:
        return Colors.blue;
      case ScheduleType.assessment:
        return Colors.purple;
      case ScheduleType.therapy:
        return Colors.green;
      case ScheduleType.reminder:
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(ScheduleType type) {
    switch (type) {
      case ScheduleType.lesson:
        return Icons.school;
      case ScheduleType.assessment:
        return Icons.assessment;
      case ScheduleType.therapy:
        return Icons.medical_services;
      case ScheduleType.reminder:
        return Icons.notifications;
      default:
        return Icons.event;
    }
  }

  String _getTypeText(ScheduleType type) {
    switch (type) {
      case ScheduleType.lesson:
        return 'Bài học';
      case ScheduleType.assessment:
        return 'Đánh giá';
      case ScheduleType.therapy:
        return 'Trị liệu';
      case ScheduleType.reminder:
        return 'Nhắc nhở';
      default:
        return 'Sự kiện';
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
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
