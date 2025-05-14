import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/error/failures.dart';
import '../models/badge_model.dart';
import '../models/user_progress_model.dart';

class BadgeRepository {
  final FirebaseFirestore _firestore;

  BadgeRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Either<Failure, BadgeModel>> getBronzeBadge() async {
    try {
      final snapshot = await _firestore
          .collection('badges')
          .where('name', isEqualTo: 'Huy hiệu Đồng')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return Left(ServerFailure('Không tìm thấy huy hiệu Đồng'));
      }

      return Right(BadgeModel.fromFirestore(snapshot.docs.first));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> updateUserBadge(String userId, String badgeId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'currentBadgeId': badgeId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, BadgeModel>> getCurrentBadge(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final currentBadgeId = userDoc.data()?['currentBadgeId'] as String?;

      if (currentBadgeId == null) {
        return Left(ServerFailure('User has no badge'));
      }

      final badgeDoc = await _firestore.collection('badges').doc(currentBadgeId).get();
      if (!badgeDoc.exists) {
        return Left(ServerFailure('Badge not found'));
      }

      return Right(BadgeModel.fromFirestore(badgeDoc));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<BadgeModel>>> getAllBadges() async {
    try {
      final snapshot = await _firestore
          .collection('badges')
          .orderBy('requiredPoints')
          .get();

      final badges = snapshot.docs
          .map((doc) => BadgeModel.fromFirestore(doc))
          .toList();

      return Right(badges);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> assignBadgeToUser(String userId, String badgeId) async {
    try {
      // Kiểm tra xem badge có tồn tại không
      final badgeSnapshot = await _firestore.collection('badges').where('name', isEqualTo: 'Huy hiệu Đồng').get();

      if (badgeSnapshot.docs.isEmpty) {
        return Left(ServerFailure('Không tìm thấy huy hiệu'));
      }

      final badgeDoc = badgeSnapshot.docs.first;
      final badgeDocId = badgeDoc.id;

      // Cập nhật huy hiệu cho người dùng
      await _firestore.collection('users').doc(userId).update({
        'currentBadgeId': badgeDocId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Tạo liên kết người dùng-huy hiệu
      await _firestore.collection('user_badges').add({
        'userId': userId,
        'badgeId': badgeDocId,
        'earnedAt': FieldValue.serverTimestamp(),
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}