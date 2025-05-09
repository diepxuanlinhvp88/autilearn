import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../presentation/blocs/auth/auth_state.dart';
import '../../../presentation/blocs/reward/reward_bloc.dart';
import '../../../presentation/blocs/reward/reward_event.dart';
import '../../../presentation/blocs/reward/reward_state.dart';
import '../../../presentation/widgets/reward/reward_item.dart';
import '../../../presentation/widgets/reward/currency_display.dart';
import '../../../data/models/reward_model.dart';
import '../../../data/models/currency_model.dart';
import '../../../main.dart';

class RewardShopPage extends StatelessWidget {
  const RewardShopPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RewardBloc>(
      create: (context) => getIt<RewardBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cửa hàng phần thưởng'),
          backgroundColor: Colors.amber,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is Authenticated) {
              return BlocConsumer<RewardBloc, RewardState>(
                listener: (context, state) {
                  if (state is RewardError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else if (state is RewardPurchased) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã mua phần thưởng: ${state.reward.name}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    
                    // Tải lại danh sách phần thưởng
                    context.read<RewardBloc>().add(LoadAvailableRewards());
                    context.read<RewardBloc>().add(LoadUserRewards(authState.user.uid));
                  }
                },
                builder: (context, state) {
                  if (state is RewardInitial) {
                    // Tải phần thưởng và tiền tệ khi trang được tạo
                    context.read<RewardBloc>().add(const LoadAvailableRewards());
                    context.read<RewardBloc>().add(LoadUserRewards(authState.user.uid));
                    context.read<RewardBloc>().add(LoadUserCurrency(authState.user.uid));
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is RewardLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is AvailableRewardsLoaded || state is UserRewardsLoaded || state is CurrencyLoaded) {
                    // Lấy dữ liệu từ state
                    List<RewardModel> availableRewards = [];
                    List<RewardModel> userRewards = [];
                    CurrencyModel? currency;
                    
                    if (state is AvailableRewardsLoaded) {
                      availableRewards = state.rewards;
                    } else if (state is UserRewardsLoaded) {
                      userRewards = state.rewards;
                    } else if (state is CurrencyLoaded) {
                      currency = state.currency;
                    }
                    
                    return _buildShopContent(
                      context, 
                      authState.user.uid, 
                      availableRewards, 
                      userRewards, 
                      currency
                    );
                  } else {
                    return const Center(
                      child: Text('Không thể tải cửa hàng'),
                    );
                  }
                },
              );
            } else {
              return const Center(
                child: Text('Vui lòng đăng nhập để xem cửa hàng'),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildShopContent(
    BuildContext context, 
    String userId, 
    List<RewardModel> availableRewards, 
    List<RewardModel> userRewards, 
    CurrencyModel? currency
  ) {
    return Column(
      children: [
        // Currency display
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Số dư của bạn:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              CurrencyDisplay(
                userId: userId,
                showAll: true,
              ),
            ],
          ),
        ),
        
        // Shop content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Available rewards
                const Text(
                  'Phần thưởng có sẵn',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                if (availableRewards.isEmpty)
                  const Center(
                    child: Text('Không có phần thưởng nào'),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: availableRewards.length,
                    itemBuilder: (context, index) {
                      final reward = availableRewards[index];
                      final isPurchased = userRewards.any((r) => r.id == reward.id);
                      
                      // Tạo bản sao của phần thưởng với trạng thái đã mua
                      final displayReward = isPurchased
                          ? reward.copyWith(isPurchased: true)
                          : reward;
                      
                      return RewardItem(
                        reward: displayReward,
                        showDetails: true,
                        onTap: () {
                          if (isPurchased) {
                            _showRewardDetails(context, displayReward);
                          } else {
                            _showPurchaseConfirmation(context, userId, reward, currency);
                          }
                        },
                      );
                    },
                  ),
                
                const SizedBox(height: 24),
                
                // User rewards
                const Text(
                  'Phần thưởng đã mua',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                if (userRewards.isEmpty)
                  const Center(
                    child: Text('Bạn chưa mua phần thưởng nào'),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: userRewards.length,
                    itemBuilder: (context, index) {
                      final reward = userRewards[index];
                      return RewardItem(
                        reward: reward,
                        showDetails: true,
                        showPrice: false,
                        onTap: () {
                          _showRewardDetails(context, reward);
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showRewardDetails(BuildContext context, RewardModel reward) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          reward.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reward image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                reward.imageUrl,
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            // Reward description
            Text(
              reward.description,
              style: const TextStyle(
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Reward type
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getTypeColor(reward.type),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _getTypeText(reward.type),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (reward.isPurchased && reward.purchasedAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Mua ngày: ${_formatDate(reward.purchasedAt!)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showPurchaseConfirmation(
    BuildContext context, 
    String userId, 
    RewardModel reward, 
    CurrencyModel? currency
  ) {
    final bool canPurchase = currency != null && currency.coins >= reward.cost;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Xác nhận mua'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reward image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                reward.imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Bạn có muốn mua "${reward.name}" với giá ${reward.cost} xu không?',
              style: const TextStyle(
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Số dư: ',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                const Icon(
                  Icons.monetization_on,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '${currency?.coins ?? 0}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: canPurchase ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            if (!canPurchase) ...[
              const SizedBox(height: 8),
              Text(
                'Bạn cần thêm ${reward.cost - (currency?.coins ?? 0)} xu để mua phần thưởng này',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: canPurchase
                ? () {
                    Navigator.of(context).pop();
                    context.read<RewardBloc>().add(
                          PurchaseReward(
                            userId: userId,
                            reward: reward,
                          ),
                        );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
            ),
            child: const Text('Mua ngay'),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case RewardTypes.avatar:
        return Colors.blue;
      case RewardTypes.background:
        return Colors.green;
      case RewardTypes.character:
        return Colors.purple;
      case RewardTypes.accessory:
        return Colors.orange;
      case RewardTypes.theme:
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  String _getTypeText(String type) {
    switch (type) {
      case RewardTypes.avatar:
        return 'Hình đại diện';
      case RewardTypes.background:
        return 'Hình nền';
      case RewardTypes.character:
        return 'Nhân vật';
      case RewardTypes.accessory:
        return 'Phụ kiện';
      case RewardTypes.theme:
        return 'Chủ đề';
      default:
        return 'Khác';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
