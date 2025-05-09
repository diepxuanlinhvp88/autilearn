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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
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
                  } else {
                    return const Center(
                      child: Text('Không thể tải lịch học'),
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
}
