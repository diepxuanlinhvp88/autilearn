import 'package:dartz/dartz.dart';
import '../datasources/firebase_datasource.dart';
import '../models/badge_model.dart';
import '../models/reward_model.dart';
import '../models/currency_model.dart';

class RewardRepository {
  final FirebaseDataSource _firebaseDataSource;

  RewardRepository({required FirebaseDataSource firebaseDataSource})
      : _firebaseDataSource = firebaseDataSource;

  // Lấy danh sách huy hiệu của người dùng
  Future<Either<String, List<BadgeModel>>> getUserBadges(String userId) async {
    return _firebaseDataSource.getUserBadges(userId);
  }

  // Mở khóa huy hiệu mới cho người dùng
  Future<Either<String, String>> unlockBadge(String userId, BadgeModel badge) async {
    return _firebaseDataSource.unlockBadge(userId, badge);
  }

  // Lấy danh sách phần thưởng có sẵn
  Future<Either<String, List<RewardModel>>> getAvailableRewards() async {
    return _firebaseDataSource.getAvailableRewards();
  }

  // Lấy danh sách phần thưởng đã mua của người dùng
  Future<Either<String, List<RewardModel>>> getUserRewards(String userId) async {
    return _firebaseDataSource.getUserRewards(userId);
  }

  // Mua phần thưởng mới
  Future<Either<String, String>> purchaseReward(String userId, RewardModel reward) async {
    return _firebaseDataSource.purchaseReward(userId, reward);
  }

  // Lấy thông tin tiền tệ của người dùng
  Future<Either<String, CurrencyModel>> getUserCurrency(String userId) async {
    return _firebaseDataSource.getUserCurrency(userId);
  }

  // Cập nhật tiền tệ của người dùng
  Future<Either<String, bool>> updateUserCurrency(CurrencyModel currency) async {
    return _firebaseDataSource.updateUserCurrency(currency);
  }
}
