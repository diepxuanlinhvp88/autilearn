import 'package:equatable/equatable.dart';
import '../../../data/models/schedule_model.dart';

abstract class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserSchedules extends ScheduleEvent {
  final String userId;

  const LoadUserSchedules(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadUpcomingSchedules extends ScheduleEvent {
  final String userId;

  const LoadUpcomingSchedules(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadSchedule extends ScheduleEvent {
  final String scheduleId;

  const LoadSchedule(this.scheduleId);

  @override
  List<Object?> get props => [scheduleId];
}

class CreateSchedule extends ScheduleEvent {
  final ScheduleModel schedule;

  const CreateSchedule(this.schedule);

  @override
  List<Object?> get props => [schedule];
}

class UpdateSchedule extends ScheduleEvent {
  final ScheduleModel schedule;

  const UpdateSchedule(this.schedule);

  @override
  List<Object?> get props => [schedule];
}

class DeleteSchedule extends ScheduleEvent {
  final String scheduleId;

  const DeleteSchedule(this.scheduleId);

  @override
  List<Object?> get props => [scheduleId];
}

class MarkScheduleAsCompleted extends ScheduleEvent {
  final String scheduleId;

  const MarkScheduleAsCompleted(this.scheduleId);

  @override
  List<Object?> get props => [scheduleId];
}
