import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/schedule_model.dart';

class CalendarView extends StatefulWidget {
  final List<ScheduleModel> schedules;
  final Function(DateTime) onDateSelected;
  final Function(ScheduleModel)? onScheduleTap;

  const CalendarView({
    Key? key,
    required this.schedules,
    required this.onDateSelected,
    this.onScheduleTap,
  }) : super(key: key);

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late DateTime _selectedDate;
  late DateTime _currentMonth;
  late List<ScheduleModel> _schedulesForSelectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _currentMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    _updateSchedulesForSelectedDate();
  }

  @override
  void didUpdateWidget(CalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.schedules != oldWidget.schedules) {
      _updateSchedulesForSelectedDate();
    }
  }

  void _updateSchedulesForSelectedDate() {
    _schedulesForSelectedDate = widget.schedules.where((schedule) {
      final scheduleDate = DateTime(
        schedule.startTime.year,
        schedule.startTime.month,
        schedule.startTime.day,
      );
      final selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      );
      return scheduleDate.isAtSameMomentAs(selectedDate);
    }).toList();
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _updateSchedulesForSelectedDate();
    });
    widget.onDateSelected(date);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCalendarHeader(),
        _buildCalendarGrid(),
        const SizedBox(height: 16),
        _buildSchedulesList(),
      ],
    );
  }

  Widget _buildCalendarHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _previousMonth,
          ),
          Text(
            DateFormat('MMMM yyyy').format(_currentMonth),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;
    
    // Adjust for Monday as first day of week (1-7)
    final adjustedFirstWeekday = firstWeekday == 7 ? 0 : firstWeekday;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _weekdayHeader('T2'),
              _weekdayHeader('T3'),
              _weekdayHeader('T4'),
              _weekdayHeader('T5'),
              _weekdayHeader('T6'),
              _weekdayHeader('T7'),
              _weekdayHeader('CN'),
            ],
          ),
          const SizedBox(height: 8),
          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: 42, // 6 weeks * 7 days
            itemBuilder: (context, index) {
              final dayOffset = index - adjustedFirstWeekday;
              if (dayOffset < 0 || dayOffset >= daysInMonth) {
                return const SizedBox.shrink();
              }
              
              final day = dayOffset + 1;
              final date = DateTime(_currentMonth.year, _currentMonth.month, day);
              final isToday = _isToday(date);
              final isSelected = _isSameDay(date, _selectedDate);
              final hasSchedules = _hasSchedulesForDate(date);
              
              return GestureDetector(
                onTap: () => _selectDate(date),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue
                        : isToday
                            ? Colors.blue.withOpacity(0.1)
                            : null,
                    borderRadius: BorderRadius.circular(8),
                    border: isToday && !isSelected
                        ? Border.all(color: Colors.blue, width: 1)
                        : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        day.toString(),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : isToday
                                  ? Colors.blue
                                  : null,
                          fontWeight: isSelected || isToday ? FontWeight.bold : null,
                        ),
                      ),
                      if (hasSchedules)
                        Positioned(
                          bottom: 4,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _weekdayHeader(String text) {
    return SizedBox(
      width: 40,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSchedulesList() {
    if (_schedulesForSelectedDate.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Không có lịch học nào vào ngày ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Lịch học ngày ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _schedulesForSelectedDate.length,
          itemBuilder: (context, index) {
            final schedule = _schedulesForSelectedDate[index];
            return ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getTypeColor(schedule.type).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getTypeIcon(schedule.type),
                  color: _getTypeColor(schedule.type),
                ),
              ),
              title: Text(
                schedule.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: schedule.isCompleted ? TextDecoration.lineThrough : null,
                  color: schedule.isCompleted ? Colors.grey : Colors.black,
                ),
              ),
              subtitle: Text(
                '${DateFormat('HH:mm').format(schedule.startTime)} - ${DateFormat('HH:mm').format(schedule.endTime)}',
              ),
              onTap: widget.onScheduleTap != null
                  ? () => widget.onScheduleTap!(schedule)
                  : null,
            );
          },
        ),
      ],
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  bool _hasSchedulesForDate(DateTime date) {
    return widget.schedules.any((schedule) {
      final scheduleDate = DateTime(
        schedule.startTime.year,
        schedule.startTime.month,
        schedule.startTime.day,
      );
      final checkDate = DateTime(
        date.year,
        date.month,
        date.day,
      );
      return scheduleDate.isAtSameMomentAs(checkDate);
    });
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
