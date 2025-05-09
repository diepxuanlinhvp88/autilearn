import 'package:equatable/equatable.dart';
import '../../../data/models/badge_model.dart';
import '../../../data/models/reward_model.dart';
import '../../../data/models/currency_model.dart';

abstract class RewardState extends Equatable {
  const RewardState();

  @override
  List<Object?> get props => [];
}

class RewardInitial extends RewardState {
  const RewardInitial();
}

class RewardLoading extends RewardState {
  const RewardLoading();
}

class BadgesLoaded extends RewardState {
  final List<BadgeModel> badges;

  const BadgesLoaded(this.badges);

  @override
  List<Object?> get props => [badges];
}

class BadgeUnlocked extends RewardState {
  final BadgeModel badge;

  const BadgeUnlocked(this.badge);

  @override
  List<Object?> get props => [badge];
}

class AvailableRewardsLoaded extends RewardState {
  final List<RewardModel> rewards;

  const AvailableRewardsLoaded(this.rewards);

  @override
  List<Object?> get props => [rewards];
}

class UserRewardsLoaded extends RewardState {
  final List<RewardModel> rewards;

  const UserRewardsLoaded(this.rewards);

  @override
  List<Object?> get props => [rewards];
}

class RewardPurchased extends RewardState {
  final RewardModel reward;

  const RewardPurchased(this.reward);

  @override
  List<Object?> get props => [reward];
}

class CurrencyLoaded extends RewardState {
  final CurrencyModel currency;

  const CurrencyLoaded(this.currency);

  @override
  List<Object?> get props => [currency];
}

class CurrencyUpdated extends RewardState {
  final CurrencyModel currency;

  const CurrencyUpdated(this.currency);

  @override
  List<Object?> get props => [currency];
}

class RewardError extends RewardState {
  final String message;

  const RewardError(this.message);

  @override
  List<Object?> get props => [message];
}
