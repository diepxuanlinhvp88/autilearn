import 'package:dartz/dartz.dart';
import '../datasources/firebase_datasource.dart';
import '../models/analytics_model.dart';
import '../../core/error/failures.dart';

class AnalyticsRepository {
  final FirebaseDataSource _firebaseDataSource;

  AnalyticsRepository({required FirebaseDataSource firebaseDataSource})
      : _firebaseDataSource = firebaseDataSource;

  // Lấy phân tích dữ liệu của người dùng
  Future<Either<Failure, AnalyticsModel>> getUserAnalytics(String userId) async {
    return _firebaseDataSource.getUserAnalytics(userId);
  }

  // Cập nhật phân tích dữ liệu của người dùng
  Future<Either<Failure, bool>> updateUserAnalytics(AnalyticsModel analytics) async {
    return _firebaseDataSource.updateUserAnalytics(analytics);
  }

  // Lấy phân tích dữ liệu của học sinh (cho giáo viên)
  Future<Either<Failure, List<StudentAnalytics>>> getStudentAnalytics(String teacherId) async {
    return _firebaseDataSource.getStudentAnalytics(teacherId);
  }

  // Cập nhật phân tích dữ liệu từ tiến trình học tập
  Future<Either<Failure, bool>> updateAnalyticsFromProgress(String userId) async {
    return _firebaseDataSource.updateAnalyticsFromProgress(userId);
  }
}
