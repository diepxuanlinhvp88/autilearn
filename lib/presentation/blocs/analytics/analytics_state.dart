import 'package:equatable/equatable.dart';
import '../../../data/models/analytics_model.dart';

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

class AnalyticsLoading extends AnalyticsState {
  const AnalyticsLoading();
}

class UserAnalyticsLoaded extends AnalyticsState {
  final AnalyticsModel analytics;

  const UserAnalyticsLoaded(this.analytics);

  @override
  List<Object?> get props => [analytics];
}

class StudentAnalyticsLoaded extends AnalyticsState {
  final List<StudentAnalytics> studentAnalytics;

  const StudentAnalyticsLoaded(this.studentAnalytics);

  @override
  List<Object?> get props => [studentAnalytics];
}

class AnalyticsUpdated extends AnalyticsState {
  const AnalyticsUpdated();
}

class AnalyticsError extends AnalyticsState {
  final String message;

  const AnalyticsError(this.message);

  @override
  List<Object?> get props => [message];
}
