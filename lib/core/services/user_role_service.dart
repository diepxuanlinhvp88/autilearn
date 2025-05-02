import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_constants.dart';

class UserRoleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Kiểm tra và cập nhật vai trò người dùng
  Future<String> ensureUserRole() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('Không có người dùng đăng nhập');
        return '';
      }

      print('Kiểm tra vai trò cho người dùng: ${user.uid}');
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      // Nếu người dùng chưa có trong Firestore, tạo mới
      if (!userDoc.exists) {
        print('Tạo mới người dùng trong Firestore');
        final userData = {
          'name': user.displayName ?? 'Người dùng',
          'email': user.email ?? '',
          'role': AppConstants.roleTeacher, // Mặc định là giáo viên
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        };

        await _firestore.collection('users').doc(user.uid).set(userData);
        return AppConstants.roleTeacher;
      }

      // Nếu người dùng đã tồn tại nhưng không có vai trò, cập nhật
      final data = userDoc.data() as Map<String, dynamic>;
      if (!data.containsKey('role') || data['role'] == null || data['role'] == '') {
        print('Cập nhật vai trò cho người dùng');
        await _firestore.collection('users').doc(user.uid).update({
          'role': AppConstants.roleTeacher,
          'updatedAt': Timestamp.now(),
        });
        return AppConstants.roleTeacher;
      }

      return data['role'] as String;
    } catch (e) {
      print('Lỗi khi kiểm tra vai trò người dùng: $e');
      return '';
    }
  }
}
