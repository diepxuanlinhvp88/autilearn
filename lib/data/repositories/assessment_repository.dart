import 'package:dartz/dartz.dart';
import '../datasources/firebase_datasource.dart';
import '../models/skill_assessment_model.dart';
import '../../core/error/failures.dart';

class AssessmentRepository {
  final FirebaseDataSource _firebaseDataSource;

  AssessmentRepository({required FirebaseDataSource firebaseDataSource})
      : _firebaseDataSource = firebaseDataSource;

  // Lấy danh sách đánh giá của học sinh
  Future<Either<Failure, List<SkillAssessmentModel>>> getStudentAssessments(String studentId) async {
    return _firebaseDataSource.getStudentAssessments(studentId);
  }

  // Lấy danh sách đánh giá của giáo viên
  Future<Either<Failure, List<SkillAssessmentModel>>> getTeacherAssessments(String teacherId) async {
    return _firebaseDataSource.getTeacherAssessments(teacherId);
  }

  // Lấy chi tiết đánh giá
  Future<Either<Failure, SkillAssessmentModel>> getAssessment(String assessmentId) async {
    return _firebaseDataSource.getAssessment(assessmentId);
  }

  // Tạo đánh giá mới
  Future<Either<Failure, String>> createAssessment(SkillAssessmentModel assessment) async {
    return _firebaseDataSource.createAssessment(assessment);
  }

  // Cập nhật đánh giá
  Future<Either<Failure, bool>> updateAssessment(SkillAssessmentModel assessment) async {
    return _firebaseDataSource.updateAssessment(assessment);
  }

  // Xóa đánh giá
  Future<Either<Failure, bool>> deleteAssessment(String assessmentId) async {
    return _firebaseDataSource.deleteAssessment(assessmentId);
  }
}
