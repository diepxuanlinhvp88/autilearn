import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../models/teacher_student_link_model.dart';
import '../models/user_model.dart';

class TeacherStudentRepository {
  final FirebaseFirestore _firestore;

  TeacherStudentRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Liên kết giáo viên với học sinh
  Future<Either<Failure, TeacherStudentLink>> linkTeacherStudent({
    required String teacherId,
    required String studentId,
  }) async {
    try {
      // Kiểm tra xem liên kết đã tồn tại chưa
      final existingLink = await _firestore
          .collection('teacher_student_links')
          .where('teacherId', isEqualTo: teacherId)
          .where('studentId', isEqualTo: studentId)
          .get();

      if (existingLink.docs.isNotEmpty) {
        return Left(ServerFailure('Liên kết này đã tồn tại'));
      }

      // Tạo liên kết mới
      final linkData = TeacherStudentLink(
        id: '',
        teacherId: teacherId,
        studentId: studentId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ).toMap();

      final docRef = await _firestore.collection('teacher_student_links').add(linkData);
      final newLink = TeacherStudentLink.fromMap(docRef.id, linkData);

      return Right(newLink);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Lấy danh sách học sinh của giáo viên
  Future<Either<Failure, List<UserModel>>> getTeacherStudents(String teacherId) async {
    try {
      // Lấy tất cả liên kết của giáo viên
      final links = await _firestore
          .collection('teacher_student_links')
          .where('teacherId', isEqualTo: teacherId)
          .where('isActive', isEqualTo: true)
          .get();

      if (links.docs.isEmpty) {
        return const Right([]);
      }

      // Lấy thông tin của tất cả học sinh
      final studentIds = links.docs.map((doc) => doc.data()['studentId'] as String).toList();
      final students = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: studentIds)
          .get();

      final studentList = students.docs.map((doc) {
        return UserModel.fromMap(doc.id, doc.data());
      }).toList();

      return Right(studentList);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Lấy thông tin giáo viên của học sinh
  Future<Either<Failure, UserModel?>> getStudentTeacher(String studentId) async {
    try {
      final link = await _firestore
          .collection('teacher_student_links')
          .where('studentId', isEqualTo: studentId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (link.docs.isEmpty) {
        return const Right(null);
      }

      final teacherId = link.docs.first.data()['teacherId'] as String;
      final teacher = await _firestore.collection('users').doc(teacherId).get();

      if (!teacher.exists) {
        return const Right(null);
      }

      return Right(UserModel.fromMap(teacher.id, teacher.data()!));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Hủy liên kết giáo viên-học sinh
  Future<Either<Failure, void>> unlinkTeacherStudent({
    required String teacherId,
    required String studentId,
  }) async {
    try {
      final links = await _firestore
          .collection('teacher_student_links')
          .where('teacherId', isEqualTo: teacherId)
          .where('studentId', isEqualTo: studentId)
          .where('isActive', isEqualTo: true)
          .get();

      if (links.docs.isEmpty) {
        return Left(ServerFailure('Không tìm thấy liên kết'));
      }

      // Cập nhật trạng thái isActive thành false
      await _firestore
          .collection('teacher_student_links')
          .doc(links.docs.first.id)
          .update({'isActive': false, 'updatedAt': FieldValue.serverTimestamp()});

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
} 