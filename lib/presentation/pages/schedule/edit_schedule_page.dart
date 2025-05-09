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

class EditSchedulePage extends StatefulWidget {
  final ScheduleModel schedule;

  const EditSchedulePage({
    Key? key,
    required this.schedule,
  }) : super(key: key);

  @override
  State<EditSchedulePage> createState() => _EditSchedulePageState();
}

class _EditSchedulePageState extends State<EditSchedulePage> {
  final _formKey = GlobalKey<FormState>();

  late String _title;
  late String _description;
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  late bool _isRecurring;
  late RecurrenceType _recurrenceType;
  late List<int> _recurrenceDays;
  DateTime? _recurrenceEndDate;

  late bool _hasReminder;
  late int _reminderMinutesBefore;

  late ScheduleType _type;
  late String _relatedId;

  @override
  void initState() {
    super.initState();
    _title = widget.schedule.title;
    _description = widget.schedule.description;
    _startDate = DateTime(
      widget.schedule.startTime.year,
      widget.schedule.startTime.month,
      widget.schedule.startTime.day,
    );
    _startTime = TimeOfDay(
      hour: widget.schedule.startTime.hour,
      minute: widget.schedule.startTime.minute,
    );
    _endTime = TimeOfDay(
      hour: widget.schedule.endTime.hour,
      minute: widget.schedule.endTime.minute,
    );

    _isRecurring = widget.schedule.isRecurring;
    _recurrenceType = widget.schedule.recurrenceType;
    _recurrenceDays = List<int>.from(widget.schedule.recurrenceDays);
    _recurrenceEndDate = widget.schedule.recurrenceEndDate;

    _hasReminder = widget.schedule.hasReminder;
    _reminderMinutesBefore = widget.schedule.reminderMinutesBefore;

    _type = widget.schedule.type;
    _relatedId = widget.schedule.relatedId;
  }

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
          title: const Text('Chỉnh sửa lịch học'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          actions: [
            BlocBuilder<ScheduleBloc, ScheduleState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: state is ScheduleLoading
                      ? null
                      : () => _saveSchedule(context),
                  tooltip: 'Lưu thay đổi',
                );
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
            } else if (state is ScheduleUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã cập nhật lịch học'),
                  backgroundColor: Colors.green,
                ),
              );

              Navigator.of(context).pop();
            }
          },
          builder: (context, state) {
            if (state is ScheduleLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                              'Thông tin cơ bản',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<ScheduleType>(
                              decoration: const InputDecoration(
                                labelText: 'Loại lịch học',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.category),
                              ),
                              value: _type,
                              items: ScheduleType.values.map((type) {
                                return DropdownMenuItem<ScheduleType>(
                                  value: type,
                                  child: Text(_getTypeText(type)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _type = value;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Tiêu đề',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.title),
                              ),
                              initialValue: _title,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập tiêu đề';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                _title = value;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Mô tả',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.description),
                              ),
                              initialValue: _description,
                              maxLines: 3,
                              onChanged: (value) {
                                _description = value;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
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
                              'Thời gian',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () => _selectDate(context),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Ngày',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  DateFormat('dd/MM/yyyy').format(_startDate),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _selectStartTime(context),
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: 'Giờ bắt đầu',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.access_time),
                                      ),
                                      child: Text(
                                        _startTime.format(context),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _selectEndTime(context),
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: 'Giờ kết thúc',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.access_time),
                                      ),
                                      child: Text(
                                        _endTime.format(context),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Lặp lại',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Switch(
                                  value: _isRecurring,
                                  onChanged: (value) {
                                    setState(() {
                                      _isRecurring = value;
                                    });
                                  },
                                  activeColor: Colors.blue,
                                ),
                              ],
                            ),
                            if (_isRecurring) ...[
                              const SizedBox(height: 16),
                              DropdownButtonFormField<RecurrenceType>(
                                decoration: const InputDecoration(
                                  labelText: 'Kiểu lặp lại',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.repeat),
                                ),
                                value: _recurrenceType,
                                items: RecurrenceType.values.map((type) {
                                  return DropdownMenuItem<RecurrenceType>(
                                    value: type,
                                    child: Text(_getRecurrenceTypeText(type)),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _recurrenceType = value;
                                    });
                                  }
                                },
                              ),
                              if (_recurrenceType == RecurrenceType.weekly) ...[
                                const SizedBox(height: 16),
                                const Text(
                                  'Chọn các ngày trong tuần:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  children: List.generate(7, (index) {
                                    final day = index + 1;
                                    final isSelected = _recurrenceDays.contains(day);
                                    return FilterChip(
                                      label: Text(_getDayShortName(day)),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        setState(() {
                                          if (selected) {
                                            _recurrenceDays.add(day);
                                          } else {
                                            _recurrenceDays.remove(day);
                                          }
                                        });
                                      },
                                      selectedColor: Colors.blue.shade100,
                                      checkmarkColor: Colors.blue,
                                    );
                                  }),
                                ),
                              ],
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: () => _selectRecurrenceEndDate(context),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Ngày kết thúc lặp lại (tùy chọn)',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.calendar_today),
                                  ),
                                  child: Text(
                                    _recurrenceEndDate != null
                                        ? DateFormat('dd/MM/yyyy').format(_recurrenceEndDate!)
                                        : 'Không có',
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Nhắc nhở',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Switch(
                                  value: _hasReminder,
                                  onChanged: (value) {
                                    setState(() {
                                      _hasReminder = value;
                                    });
                                  },
                                  activeColor: Colors.blue,
                                ),
                              ],
                            ),
                            if (_hasReminder) ...[
                              const SizedBox(height: 16),
                              DropdownButtonFormField<int>(
                                decoration: const InputDecoration(
                                  labelText: 'Nhắc trước',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.notifications),
                                ),
                                value: _reminderMinutesBefore,
                                items: [5, 10, 15, 30, 60, 120].map((minutes) {
                                  return DropdownMenuItem<int>(
                                    value: minutes,
                                    child: Text('$minutes phút'),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _reminderMinutesBefore = value;
                                    });
                                  }
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );

    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;

        // Nếu giờ kết thúc sớm hơn giờ bắt đầu, cập nhật giờ kết thúc
        if (_endTime.hour < _startTime.hour ||
            (_endTime.hour == _startTime.hour && _endTime.minute <= _startTime.minute)) {
          _endTime = TimeOfDay(
            hour: _startTime.hour + 1,
            minute: _startTime.minute,
          );
        }
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );

    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  Future<void> _selectRecurrenceEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _recurrenceEndDate ?? _startDate.add(const Duration(days: 30)),
      firstDate: _startDate,
      lastDate: _startDate.add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _recurrenceEndDate = picked;
      });
    }
  }

  void _saveSchedule(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      // Tạo DateTime cho thời gian bắt đầu và kết thúc
      final startTime = DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _startTime.hour,
        _startTime.minute,
      );

      final endTime = DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _endTime.hour,
        _endTime.minute,
      );

      final updatedSchedule = widget.schedule.copyWith(
        title: _title,
        description: _description,
        startTime: startTime,
        endTime: endTime,
        isRecurring: _isRecurring,
        recurrenceType: _recurrenceType,
        recurrenceDays: _recurrenceDays,
        recurrenceEndDate: _recurrenceEndDate,
        hasReminder: _hasReminder,
        reminderMinutesBefore: _reminderMinutesBefore,
        type: _type,
        relatedId: _relatedId,
        updatedAt: DateTime.now(),
      );

      context.read<ScheduleBloc>().add(UpdateSchedule(updatedSchedule));
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

  String _getRecurrenceTypeText(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.daily:
        return 'Hàng ngày';
      case RecurrenceType.weekly:
        return 'Hàng tuần';
      case RecurrenceType.monthly:
        return 'Hàng tháng';
      default:
        return '';
    }
  }

  String _getDayShortName(int day) {
    switch (day) {
      case 1:
        return 'T2';
      case 2:
        return 'T3';
      case 3:
        return 'T4';
      case 4:
        return 'T5';
      case 5:
        return 'T6';
      case 6:
        return 'T7';
      case 7:
        return 'CN';
      default:
        return '';
    }
  }
}
