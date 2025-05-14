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
import '../../../presentation/widgets/schedule/calendar_view.dart';
import '../../../main.dart';
import 'create_schedule_page.dart';
import 'schedule_detail_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDate = DateTime.now();

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
                    String errorMessage = state.message;
                    
                    // Kiểm tra nếu là lỗi index
                    if (state.message.contains('The query requires an index')) {
                      errorMessage = 'Đang chuẩn bị dữ liệu lịch học. Vui lòng thử lại sau vài phút.';
                    }
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMessage),
                        backgroundColor: Colors.orange,
                        duration: const Duration(seconds: 5),
                        action: state.message.contains('The query requires an index')
                            ? SnackBarAction(
                                label: 'Thử lại',
                                onPressed: () {
                                  context.read<ScheduleBloc>().add(
                                    LoadUserSchedules(authState.user.uid),
                                  );
                                },
                              )
                            : null,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is ScheduleInitial) {
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
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Chưa có lịch học nào',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const CreateSchedulePage(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Tạo lịch học mới'),
                            ),
                          ],
                        ),
                      );
                    }

                    return CalendarView(
                      schedules: schedules,
                      onDateSelected: (date) {
                        setState(() {
                          _selectedDate = date;
                        });
                      },
                      onScheduleTap: (schedule) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ScheduleDetailPage(
                              scheduleId: schedule.id,
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state is ScheduleError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Không thể tải lịch học',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<ScheduleBloc>().add(
                                LoadUserSchedules(authState.user.uid),
                              );
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
                  }
                  return const Center(
                    child: Text('Không thể tải lịch học'),
                  );
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
}
