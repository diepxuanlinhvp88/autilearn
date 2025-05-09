import 'package:equatable/equatable.dart';
import '../../../data/models/schedule_model.dart';

abstract class ScheduleState extends Equatable {
  const ScheduleState();

  @override
  List<Object?> get props => [];
}

class ScheduleInitial extends ScheduleState {
  const ScheduleInitial();
}

class ScheduleLoading extends ScheduleState {
  const ScheduleLoading();
}

class UserSchedulesLoaded extends ScheduleState {
  final List<ScheduleModel> schedules;

  const UserSchedulesLoaded(this.schedules);

  @override
  List<Object?> get props => [schedules];
}

class UpcomingSchedulesLoaded extends ScheduleState {
  final List<ScheduleModel> schedules;

  const UpcomingSchedulesLoaded(this.schedules);

  @override
  List<Object?> get props => [schedules];
}

class ScheduleLoaded extends ScheduleState {
  final ScheduleModel schedule;

  const ScheduleLoaded(this.schedule);

  @override
  List<Object?> get props => [schedule];
}

class ScheduleCreated extends ScheduleState {
  final String scheduleId;

  const ScheduleCreated(this.scheduleId);

  @override
  List<Object?> get props => [scheduleId];
}

class ScheduleUpdated extends ScheduleState {
  const ScheduleUpdated();
}

class ScheduleDeleted extends ScheduleState {
  const ScheduleDeleted();
}

class ScheduleCompleted extends ScheduleState {
  const ScheduleCompleted();
}

class ScheduleError extends ScheduleState {
  final String message;

  const ScheduleError(this.message);

  @override
  List<Object?> get props => [message];
}
