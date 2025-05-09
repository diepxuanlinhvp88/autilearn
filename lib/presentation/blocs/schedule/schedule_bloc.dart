import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/schedule_repository.dart';
import 'schedule_event.dart';
import 'schedule_state.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final ScheduleRepository scheduleRepository;

  ScheduleBloc({required this.scheduleRepository}) : super(const ScheduleInitial()) {
    on<LoadUserSchedules>(_onLoadUserSchedules);
    on<LoadUpcomingSchedules>(_onLoadUpcomingSchedules);
    on<LoadSchedule>(_onLoadSchedule);
    on<CreateSchedule>(_onCreateSchedule);
    on<UpdateSchedule>(_onUpdateSchedule);
    on<DeleteSchedule>(_onDeleteSchedule);
    on<MarkScheduleAsCompleted>(_onMarkScheduleAsCompleted);
  }

  Future<void> _onLoadUserSchedules(
    LoadUserSchedules event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(const ScheduleLoading());
    final result = await scheduleRepository.getUserSchedules(event.userId);

    await result.fold(
      (error) async {
        emit(ScheduleError('Không thể tải lịch học: $error'));
      },
      (schedules) async {
        emit(UserSchedulesLoaded(schedules));
      },
    );
  }

  Future<void> _onLoadUpcomingSchedules(
    LoadUpcomingSchedules event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(const ScheduleLoading());
    final result = await scheduleRepository.getUpcomingSchedules(event.userId);

    await result.fold(
      (error) async {
        emit(ScheduleError('Không thể tải lịch học sắp tới: $error'));
      },
      (schedules) async {
        emit(UpcomingSchedulesLoaded(schedules));
      },
    );
  }

  Future<void> _onLoadSchedule(
    LoadSchedule event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(const ScheduleLoading());
    final result = await scheduleRepository.getSchedule(event.scheduleId);

    await result.fold(
      (error) async {
        emit(ScheduleError('Không thể tải lịch học: $error'));
      },
      (schedule) async {
        emit(ScheduleLoaded(schedule));
      },
    );
  }

  Future<void> _onCreateSchedule(
    CreateSchedule event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(const ScheduleLoading());
    final result = await scheduleRepository.createSchedule(event.schedule);

    await result.fold(
      (error) async {
        emit(ScheduleError('Không thể tạo lịch học: $error'));
      },
      (scheduleId) async {
        emit(ScheduleCreated(scheduleId));
      },
    );
  }

  Future<void> _onUpdateSchedule(
    UpdateSchedule event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(const ScheduleLoading());
    final result = await scheduleRepository.updateSchedule(event.schedule);

    await result.fold(
      (error) async {
        emit(ScheduleError('Không thể cập nhật lịch học: $error'));
      },
      (_) async {
        emit(const ScheduleUpdated());
      },
    );
  }

  Future<void> _onDeleteSchedule(
    DeleteSchedule event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(const ScheduleLoading());
    final result = await scheduleRepository.deleteSchedule(event.scheduleId);

    await result.fold(
      (error) async {
        emit(ScheduleError('Không thể xóa lịch học: $error'));
      },
      (_) async {
        emit(const ScheduleDeleted());
      },
    );
  }

  Future<void> _onMarkScheduleAsCompleted(
    MarkScheduleAsCompleted event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(const ScheduleLoading());
    final result = await scheduleRepository.markScheduleAsCompleted(event.scheduleId);

    await result.fold(
      (error) async {
        emit(ScheduleError('Không thể đánh dấu lịch học đã hoàn thành: $error'));
      },
      (_) async {
        emit(const ScheduleCompleted());
      },
    );
  }
}
