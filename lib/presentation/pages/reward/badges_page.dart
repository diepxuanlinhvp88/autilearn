import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../presentation/blocs/auth/auth_state.dart';
import '../../../presentation/blocs/reward/reward_bloc.dart';
import '../../../presentation/blocs/reward/reward_event.dart';
import '../../../presentation/blocs/reward/reward_state.dart';
import '../../../presentation/widgets/reward/badge_item.dart';
import '../../../data/models/badge_model.dart';
import '../../../main.dart';

class BadgesPage extends StatelessWidget {
  const BadgesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RewardBloc>(
      create: (context) => getIt<RewardBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Huy hiệu thành tích'),
          backgroundColor: Colors.blue,
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
                  } else if (state is BadgeUnlocked) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã mở khóa huy hiệu: ${state.badge.name}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is RewardInitial) {
                    // Tải huy hiệu khi trang được tạo
                    context.read<RewardBloc>().add(LoadUserBadges(authState.user.uid));
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is RewardLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is BadgesLoaded) {
                    final badges = state.badges;
                    if (badges.isEmpty) {
                      return const Center(
                        child: Text('Bạn chưa có huy hiệu nào'),
                      );
                    }

                    return _buildBadgesList(context, badges);
                  } else {
                    return const Center(
                      child: Text('Không thể tải huy hiệu'),
                    );
                  }
                },
              );
            } else {
              return const Center(
                child: Text('Vui lòng đăng nhập để xem huy hiệu'),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildBadgesList(BuildContext context, List<BadgeModel> badges) {
    // Phân loại huy hiệu
    final unlockedBadges = badges.where((badge) => badge.isUnlocked).toList();
    final lockedBadges = badges.where((badge) => !badge.isUnlocked).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thông tin
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thành tích của bạn',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Đã mở khóa: ${unlockedBadges.length}/${badges.length} huy hiệu',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: badges.isEmpty ? 0 : unlockedBadges.length / badges.length,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Huy hiệu đã mở khóa
          if (unlockedBadges.isNotEmpty) ...[
            const Text(
              'Huy hiệu đã mở khóa',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: unlockedBadges.length,
              itemBuilder: (context, index) {
                final badge = unlockedBadges[index];
                return BadgeItem(
                  badge: badge,
                  showDetails: true,
                  onTap: () {
                    _showBadgeDetails(context, badge);
                  },
                );
              },
            ),
            const SizedBox(height: 24),
          ],

          // Huy hiệu chưa mở khóa
          if (lockedBadges.isNotEmpty) ...[
            const Text(
              'Huy hiệu chưa mở khóa',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: lockedBadges.length,
              itemBuilder: (context, index) {
                final badge = lockedBadges[index];
                return BadgeItem(
                  badge: badge,
                  showDetails: true,
                  onTap: () {
                    _showBadgeDetails(context, badge);
                  },
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  void _showBadgeDetails(BuildContext context, BadgeModel badge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          badge.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge image
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: badge.isUnlocked ? Colors.blue.shade100 : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: badge.isUnlocked
                    ? Image.network(
                        badge.imageUrl,
                        fit: BoxFit.cover,
                      )
                    : ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                          Colors.grey,
                          BlendMode.saturation,
                        ),
                        child: Image.network(
                          badge.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            // Badge description
            Text(
              badge.description,
              style: const TextStyle(
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Badge requirements
            Text(
              'Yêu cầu: ${badge.requiredPoints} điểm',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            if (badge.isUnlocked && badge.unlockedAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Đạt được ngày: ${_formatDate(badge.unlockedAt!)}',
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
