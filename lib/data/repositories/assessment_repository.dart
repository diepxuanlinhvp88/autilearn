import 'package:dartz/dartz.dart';
import '../datasources/firebase_datasource.dart';
import '../models/skill_assessment_model.dart';

class AssessmentRepository {
  final FirebaseDataSource _firebaseDataSource;

  AssessmentRepository({required FirebaseDataSource firebaseDataSource})
      : _firebaseDataSource = firebaseDataSource;

  // Lấy danh sách đánh giá của học sinh
  Future<Either<String, List<SkillAssessmentModel>>> getStudentAssessments(String studentId) async {
    return _firebaseDataSource.getStudentAssessments(studentId);
  }

  // Lấy danh sách đánh giá của giáo viên
  Future<Either<String, List<SkillAssessmentModel>>> getTeacherAssessments(String teacherId) async {
    return _firebaseDataSource.getTeacherAssessments(teacherId);
  }

  // Lấy chi tiết đánh giá
  Future<Either<String, SkillAssessmentModel>> getAssessment(String assessmentId) async {
    return _firebaseDataSource.getAssessment(assessmentId);
  }

  // Tạo đánh giá mới
  Future<Either<String, String>> createAssessment(SkillAssessmentModel assessment) async {
    return _firebaseDataSource.createAssessment(assessment);
  }

  // Cập nhật đánh giá
  Future<Either<String, bool>> updateAssessment(SkillAssessmentModel assessment) async {
    return _firebaseDataSource.updateAssessment(assessment);
  }

  // Xóa đánh giá
  Future<Either<String, bool>> deleteAssessment(String assessmentId) async {
    return _firebaseDataSource.deleteAssessment(assessmentId);
  }
}
