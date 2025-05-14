import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../../data/repositories/reward_repository.dart';
import '../../../data/models/badge_model.dart';
import '../../../data/models/reward_model.dart';
import '../../../data/models/currency_model.dart';
import 'reward_event.dart';
import 'reward_state.dart';

class RewardBloc extends Bloc<RewardEvent, RewardState> {
  final RewardRepository rewardRepository;

  RewardBloc({required this.rewardRepository}) : super(const RewardInitial()) {
    on<LoadUserBadges>(_onLoadUserBadges);
    on<UnlockBadge>(_onUnlockBadge);
    on<LoadAvailableRewards>(_onLoadAvailableRewards);
    on<LoadUserRewards>(_onLoadUserRewards);
    on<PurchaseReward>(_onPurchaseReward);
    on<LoadUserCurrency>(_onLoadUserCurrency);
    on<UpdateUserCurrency>(_onUpdateUserCurrency);
    on<AddCurrency>(_onAddCurrency);
  }

  Future<void> _onLoadUserBadges(
    LoadUserBadges event,
    Emitter<RewardState> emit,
  ) async {
    emit(const RewardLoading());

    try {
      final result = await rewardRepository.getUserBadges(event.userId);
      result.fold(
        (failure) => emit(RewardError(failure.toString())),
        (badges) => emit(BadgesLoaded(badges)),
      );
    } catch (e) {
      emit(RewardError(e.toString()));
    }
  }

  Future<void> _onUnlockBadge(
    UnlockBadge event,
    Emitter<RewardState> emit,
  ) async {
    emit(const RewardLoading());

    try {
      final result = await rewardRepository.unlockBadge(event.userId, event.badge);
      result.fold(
        (failure) => emit(RewardError(failure.toString())),
        (message) => emit(BadgeUnlocked(event.badge)),
      );
    } catch (e) {
      emit(RewardError(e.toString()));
    }
  }

  Future<void> _onLoadAvailableRewards(
    LoadAvailableRewards event,
    Emitter<RewardState> emit,
  ) async {
    emit(const RewardLoading());

    try {
      final result = await rewardRepository.getAvailableRewards();
      result.fold(
        (failure) => emit(RewardError(failure.toString())),
        (rewards) => emit(AvailableRewardsLoaded(rewards)),
      );
    } catch (e) {
      emit(RewardError(e.toString()));
    }
  }

  Future<void> _onLoadUserRewards(
    LoadUserRewards event,
    Emitter<RewardState> emit,
  ) async {
    emit(const RewardLoading());

    try {
      final result = await rewardRepository.getUserRewards(event.userId);
      result.fold(
        (failure) => emit(RewardError(failure.toString())),
        (rewards) => emit(UserRewardsLoaded(rewards)),
      );
    } catch (e) {
      emit(RewardError(e.toString()));
    }
  }

  Future<void> _onPurchaseReward(
    PurchaseReward event,
    Emitter<RewardState> emit,
  ) async {
    emit(const RewardLoading());

    try {
      final result = await rewardRepository.purchaseReward(event.userId, event.reward);
      result.fold(
        (failure) => emit(RewardError(failure.toString())),
        (message) => emit(RewardPurchased(event.reward)),
      );
    } catch (e) {
      emit(RewardError(e.toString()));
    }
  }

  Future<void> _onLoadUserCurrency(
    LoadUserCurrency event,
    Emitter<RewardState> emit,
  ) async {
    emit(const RewardLoading());

    try {
      final result = await rewardRepository.getUserCurrency(event.userId);
      result.fold(
        (failure) => emit(RewardError(failure.toString())),
        (currency) => emit(CurrencyLoaded(currency)),
      );
    } catch (e) {
      emit(RewardError(e.toString()));
    }
  }

  Future<void> _onUpdateUserCurrency(
    UpdateUserCurrency event,
    Emitter<RewardState> emit,
  ) async {
    emit(const RewardLoading());
    
    try {
      final result = await rewardRepository.updateUserCurrency(event.currency);
      result.fold(
        (failure) => emit(RewardError(failure.toString())),
        (success) => emit(CurrencyUpdated(event.currency)),
      );
    } catch (e) {
      emit(RewardError(e.toString()));
    }
  }

  Future<void> _onAddCurrency(
    AddCurrency event,
    Emitter<RewardState> emit,
  ) async {
    emit(const RewardLoading());

    try {
      final currencyResult = await rewardRepository.getUserCurrency(event.userId);
      
      currencyResult.fold(
        (error) => emit(RewardError('Không thể lấy thông tin tiền tệ: $error')),
        (currency) async {
          final updatedCurrency = currency.copyWith(
            stars: currency.stars + event.stars,
            coins: currency.coins + event.coins,
            gems: currency.gems + event.gems,
            lastUpdated: DateTime.now(),
          );

          final result = await rewardRepository.updateUserCurrency(updatedCurrency);
          result.fold(
            (error) => emit(RewardError('Lỗi cập nhật tiền tệ: $error')),
            (success) => emit(CurrencyUpdated(updatedCurrency)),
          );
        },
      );
    } catch (e) {
      emit(RewardError(e.toString()));
    }
  }
}
