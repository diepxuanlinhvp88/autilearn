import 'package:equatable/equatable.dart';
import '../../../data/models/analytics_model.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserAnalytics extends AnalyticsEvent {
  final String userId;

  const LoadUserAnalytics(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UpdateUserAnalytics extends AnalyticsEvent {
  final AnalyticsModel analytics;

  const UpdateUserAnalytics(this.analytics);

  @override
  List<Object?> get props => [analytics];
}

class LoadStudentAnalytics extends AnalyticsEvent {
  final String teacherId;

  const LoadStudentAnalytics(this.teacherId);

  @override
  List<Object?> get props => [teacherId];
}

class UpdateAnalyticsFromProgress extends AnalyticsEvent {
  final String userId;

  const UpdateAnalyticsFromProgress(this.userId);

  @override
  List<Object?> get props => [userId];
}
