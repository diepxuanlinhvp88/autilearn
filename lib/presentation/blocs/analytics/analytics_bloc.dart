import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/analytics_repository.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsRepository analyticsRepository;

  AnalyticsBloc({required this.analyticsRepository}) : super(const AnalyticsInitial()) {
    on<LoadUserAnalytics>(_onLoadUserAnalytics);
    on<UpdateUserAnalytics>(_onUpdateUserAnalytics);
    on<LoadStudentAnalytics>(_onLoadStudentAnalytics);
    on<UpdateAnalyticsFromProgress>(_onUpdateAnalyticsFromProgress);
  }

  Future<void> _onLoadUserAnalytics(
    LoadUserAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());
    final result = await analyticsRepository.getUserAnalytics(event.userId);

    await result.fold(
      (error) async {
        emit(AnalyticsError('Không thể tải phân tích dữ liệu: $error'));
      },
      (analytics) async {
        emit(UserAnalyticsLoaded(analytics));
      },
    );
  }

  Future<void> _onUpdateUserAnalytics(
    UpdateUserAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());
    final result = await analyticsRepository.updateUserAnalytics(event.analytics);

    await result.fold(
      (error) async {
        emit(AnalyticsError('Không thể cập nhật phân tích dữ liệu: $error'));
      },
      (_) async {
        emit(const AnalyticsUpdated());
        add(LoadUserAnalytics(event.analytics.userId));
      },
    );
  }

  Future<void> _onLoadStudentAnalytics(
    LoadStudentAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());
    final result = await analyticsRepository.getStudentAnalytics(event.teacherId);

    await result.fold(
      (error) async {
        emit(AnalyticsError('Không thể tải phân tích dữ liệu học sinh: $error'));
      },
      (studentAnalytics) async {
        emit(StudentAnalyticsLoaded(studentAnalytics));
      },
    );
  }

  Future<void> _onUpdateAnalyticsFromProgress(
    UpdateAnalyticsFromProgress event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());
    final result = await analyticsRepository.updateAnalyticsFromProgress(event.userId);

    await result.fold(
      (error) async {
        emit(AnalyticsError('Không thể cập nhật phân tích dữ liệu từ tiến trình: $error'));
      },
      (_) async {
        emit(const AnalyticsUpdated());
        add(LoadUserAnalytics(event.userId));
      },
    );
  }
}
