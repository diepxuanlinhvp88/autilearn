import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../../data/repositories/reward_repository.dart';
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
    final result = await rewardRepository.getUserBadges(event.userId);

    result.fold(
      (error) => emit(RewardError(error)),
      (badges) => emit(BadgesLoaded(badges)),
    );
  }

  Future<void> _onUnlockBadge(
    UnlockBadge event,
    Emitter<RewardState> emit,
  ) async {
    emit(const RewardLoading());
    final result = await rewardRepository.unlockBadge(event.userId, event.badge);

    result.fold(
      (error) => emit(RewardError(error)),
      (_) => emit(BadgeUnlocked(event.badge)),
    );
  }

  Future<void> _onLoadAvailableRewards(
    LoadAvailableRewards event,
    Emitter<RewardState> emit,
  ) async {
    emit(const RewardLoading());
    final result = await rewardRepository.getAvailableRewards();

    result.fold(
      (error) => emit(RewardError(error)),
      (rewards) => emit(AvailableRewardsLoaded(rewards)),
    );
  }

  Future<void> _onLoadUserRewards(
    LoadUserRewards event,
    Emitter<RewardState> emit,
  ) async {
    emit(const RewardLoading());
    final result = await rewardRepository.getUserRewards(event.userId);

    result.fold(
      (error) => emit(RewardError(error)),
      (rewards) => emit(UserRewardsLoaded(rewards)),
    );
  }

  Future<void> _onPurchaseReward(
    PurchaseReward event,
    Emitter<RewardState> emit,
  ) async {
    emit(const RewardLoading());

    // Kiểm tra xem người dùng có đủ tiền không
    final currencyResult = await rewardRepository.getUserCurrency(event.userId);

    await currencyResult.fold(
      (error) async {
        emit(RewardError('Không thể lấy thông tin tiền tệ: $error'));
      },
      (currency) async {
        // Kiểm tra xem có đủ tiền không
        if (currency.coins < event.reward.cost) {
          emit(RewardError('Không đủ tiền để mua phần thưởng này'));
          return;
        }

        // Trừ tiền
        final updatedCurrency = currency.copyWith(
          coins: currency.coins - event.reward.cost,
          lastUpdated: DateTime.now(),
        );

        // Cập nhật tiền tệ
        final updateResult = await rewardRepository.updateUserCurrency(updatedCurrency);

        await updateResult.fold(
          (error) async {
            emit(RewardError('Lỗi cập nhật tiền tệ: $error'));
          },
          (_) async {
            // Mua phần thưởng
            final purchaseResult = await rewardRepository.purchaseReward(event.userId, event.reward);

            await purchaseResult.fold(
              (error) async {
                emit(RewardError('Lỗi mua phần thưởng: $error'));
              },
              (_) async {
                emit(RewardPurchased(event.reward));
                // Tải lại tiền tệ
                add(LoadUserCurrency(event.userId));
              },
            );
          },
        );
      },
    );
  }

  Future<void> _onLoadUserCurrency(
    LoadUserCurrency event,
    Emitter<RewardState> emit,
  ) async {
    emit(const RewardLoading());
    final result = await rewardRepository.getUserCurrency(event.userId);

    result.fold(
      (error) => emit(RewardError(error)),
      (currency) => emit(CurrencyLoaded(currency)),
    );
  }

  Future<void> _onUpdateUserCurrency(
    UpdateUserCurrency event,
    Emitter<RewardState> emit,
  ) async {
    emit(const RewardLoading());
    final result = await rewardRepository.updateUserCurrency(event.currency);

    result.fold(
      (error) => emit(RewardError(error)),
      (_) => emit(CurrencyUpdated(event.currency)),
    );
  }

  Future<void> _onAddCurrency(
    AddCurrency event,
    Emitter<RewardState> emit,
  ) async {
    emit(const RewardLoading());

    // Lấy tiền tệ hiện tại
    final currencyResult = await rewardRepository.getUserCurrency(event.userId);

    await currencyResult.fold(
      (error) async {
        emit(RewardError('Không thể lấy thông tin tiền tệ: $error'));
      },
      (currency) async {
        // Cập nhật tiền tệ
        final updatedCurrency = currency.copyWith(
          stars: currency.stars + event.stars,
          coins: currency.coins + event.coins,
          gems: currency.gems + event.gems,
          lastUpdated: DateTime.now(),
        );

        // Lưu tiền tệ mới
        final result = await rewardRepository.updateUserCurrency(updatedCurrency);

        await result.fold(
          (error) async {
            emit(RewardError('Lỗi cập nhật tiền tệ: $error'));
          },
          (_) async {
            emit(CurrencyUpdated(updatedCurrency));
          },
        );
      },
    );
  }
}
