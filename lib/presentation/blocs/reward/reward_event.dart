import 'package:equatable/equatable.dart';
import '../../../data/models/badge_model.dart';
import '../../../data/models/reward_model.dart';
import '../../../data/models/currency_model.dart';

abstract class RewardEvent extends Equatable {
  const RewardEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserBadges extends RewardEvent {
  final String userId;

  const LoadUserBadges(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UnlockBadge extends RewardEvent {
  final String userId;
  final BadgeModel badge;

  const UnlockBadge({
    required this.userId,
    required this.badge,
  });

  @override
  List<Object?> get props => [userId, badge];
}

class LoadAvailableRewards extends RewardEvent {
  const LoadAvailableRewards();
}

class LoadUserRewards extends RewardEvent {
  final String userId;

  const LoadUserRewards(this.userId);

  @override
  List<Object?> get props => [userId];
}

class PurchaseReward extends RewardEvent {
  final String userId;
  final RewardModel reward;

  const PurchaseReward({
    required this.userId,
    required this.reward,
  });

  @override
  List<Object?> get props => [userId, reward];
}

class LoadUserCurrency extends RewardEvent {
  final String userId;

  const LoadUserCurrency(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UpdateUserCurrency extends RewardEvent {
  final CurrencyModel currency;

  const UpdateUserCurrency(this.currency);

  @override
  List<Object?> get props => [currency];
}

class AddCurrency extends RewardEvent {
  final String userId;
  final int stars;
  final int coins;
  final int gems;

  const AddCurrency({
    required this.userId,
    this.stars = 0,
    this.coins = 0,
    this.gems = 0,
  });

  @override
  List<Object?> get props => [userId, stars, coins, gems];
}
