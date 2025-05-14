import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_constants.dart';
import 'badge_service.dart';

class UserRoleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final BadgeService _badgeService = BadgeService();

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
          'role': AppConstants.roleStudent, // Mặc định là học sinh
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        };

        await _firestore.collection('users').doc(user.uid).set(userData);

        // Gán huy hiệu đồng cho người dùng mới
        await _assignBronzeBadge(user.uid);

        return AppConstants.roleStudent;
      }

      // Nếu người dùng đã tồn tại nhưng không có vai trò, cập nhật
      final data = userDoc.data() as Map<String, dynamic>;
      if (!data.containsKey('role') || data['role'] == null || data['role'] == '') {
        print('Cập nhật vai trò cho người dùng');
        await _firestore.collection('users').doc(user.uid).update({
          'role': AppConstants.roleStudent,
          'updatedAt': Timestamp.now(),
        });
        return AppConstants.roleStudent;
      }

      // Kiểm tra xem người dùng đã có huy hiệu chưa
      if (!data.containsKey('currentBadgeId') || data['currentBadgeId'] == null || data['currentBadgeId'] == '') {
        print('Gán huy hiệu đồng cho người dùng');
        await _assignBronzeBadge(user.uid);
      }

      return data['role'] as String;
    } catch (e) {
      print('Lỗi khi kiểm tra vai trò người dùng: $e');
      return '';
    }
  }

  // Phương thức gán huy hiệu đồng cho người dùng
  Future<void> _assignBronzeBadge(String userId) async {
    try {
      // Lấy danh sách huy hiệu
      final badgesSnapshot = await _firestore
          .collection('badges')
          .where('name', isEqualTo: 'Huy hiệu Đồng')
          .limit(1)
          .get();

      if (badgesSnapshot.docs.isEmpty) {
        print('Không tìm thấy huy hiệu Đồng, tạo mới các huy hiệu');
        await _badgeService.createSampleBadges();

        // Lấy lại huy hiệu Đồng sau khi tạo mới
        final newBadgesSnapshot = await _firestore
            .collection('badges')
            .where('name', isEqualTo: 'Huy hiệu Đồng')
            .limit(1)
            .get();

        if (newBadgesSnapshot.docs.isEmpty) {
          print('Vẫn không tìm thấy huy hiệu Đồng sau khi tạo mới');
          return;
        }

        // Gán huy hiệu Đồng cho người dùng
        final bronzeBadgeId = newBadgesSnapshot.docs.first.id;
        await _firestore.collection('users').doc(userId).update({
          'currentBadgeId': bronzeBadgeId,
          'updatedAt': Timestamp.now(),
        });
        print('Gán huy hiệu Đồng mới cho người dùng: $bronzeBadgeId');
      } else {
        // Gán huy hiệu Đồng cho người dùng
        final bronzeBadgeId = badgesSnapshot.docs.first.id;
        await _firestore.collection('users').doc(userId).update({
          'currentBadgeId': bronzeBadgeId,
          'updatedAt': Timestamp.now(),
        });
        print('Gán huy hiệu Đồng cho người dùng: $bronzeBadgeId');
      }
    } catch (e) {
      print('Lỗi khi gán huy hiệu Đồng: $e');
    }
  }
}
