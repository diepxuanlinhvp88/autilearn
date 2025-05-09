import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/schedule_model.dart';

class ScheduleItemCard extends StatelessWidget {
  final ScheduleModel schedule;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onDelete;

  const ScheduleItemCard({
    Key? key,
    required this.schedule,
    this.onTap,
    this.onComplete,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: schedule.isCompleted ? TextDecoration.lineThrough : null,
                            color: schedule.isCompleted ? Colors.grey : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${DateFormat('HH:mm').format(schedule.startTime)} - ${DateFormat('HH:mm').format(schedule.endTime)}, ${DateFormat('dd/MM/yyyy').format(schedule.startTime)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (schedule.isRecurring)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _getRecurrenceText(),
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!schedule.isCompleted && onComplete != null)
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline),
                      color: Colors.green,
                      onPressed: onComplete,
                      tooltip: 'Đánh dấu đã hoàn thành',
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red,
                      onPressed: onDelete,
                      tooltip: 'Xóa lịch học',
                    ),
                ],
              ),
              if (schedule.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 66),
                  child: Text(
                    schedule.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (schedule.hasReminder)
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 66),
                  child: Row(
                    children: [
                      Icon(
                        Icons.notifications,
                        size: 16,
                        color: Colors.amber.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Nhắc nhở ${schedule.reminderMinutesBefore} phút trước',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRecurrenceText() {
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
}
