import 'package:dartz/dartz.dart';
import '../datasources/firebase_datasource.dart';
import '../models/schedule_model.dart';

class ScheduleRepository {
  final FirebaseDataSource _firebaseDataSource;

  ScheduleRepository({required FirebaseDataSource firebaseDataSource})
      : _firebaseDataSource = firebaseDataSource;

  // Lấy danh sách lịch học của người dùng
  Future<Either<String, List<ScheduleModel>>> getUserSchedules(String userId) async {
    return _firebaseDataSource.getUserSchedules(userId);
  }

  // Lấy danh sách lịch học sắp tới
  Future<Either<String, List<ScheduleModel>>> getUpcomingSchedules(String userId) async {
    return _firebaseDataSource.getUpcomingSchedules(userId);
  }

  // Lấy chi tiết lịch học
  Future<Either<String, ScheduleModel>> getSchedule(String scheduleId) async {
    return _firebaseDataSource.getSchedule(scheduleId);
  }

  // Tạo lịch học mới
  Future<Either<String, String>> createSchedule(ScheduleModel schedule) async {
    return _firebaseDataSource.createSchedule(schedule);
  }

  // Cập nhật lịch học
  Future<Either<String, bool>> updateSchedule(ScheduleModel schedule) async {
    return _firebaseDataSource.updateSchedule(schedule);
  }

  // Xóa lịch học
  Future<Either<String, bool>> deleteSchedule(String scheduleId) async {
    return _firebaseDataSource.deleteSchedule(scheduleId);
  }

  // Đánh dấu lịch học đã hoàn thành
  Future<Either<String, bool>> markScheduleAsCompleted(String scheduleId) async {
    return _firebaseDataSource.markScheduleAsCompleted(scheduleId);
  }
}
