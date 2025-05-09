import 'package:flutter/material.dart';
import '../../../data/models/reward_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RewardItem extends StatelessWidget {
  final RewardModel reward;
  final VoidCallback? onTap;
  final bool showDetails;
  final bool showPrice;

  const RewardItem({
    Key? key,
    required this.reward,
    this.onTap,
    this.showDetails = false,
    this.showPrice = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: _getBorderColor(),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reward image
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _getBackgroundColor(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: reward.isPurchased
                        ? CachedNetworkImage(
                            imageUrl: reward.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.error,
                              color: Colors.red,
                            ),
                          )
                        : ColorFiltered(
                            colorFilter: const ColorFilter.mode(
                              Colors.grey,
                              BlendMode.saturation,
                            ),
                            child: CachedNetworkImage(
                              imageUrl: reward.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.error,
                                color: Colors.red,
                              ),
                            ),
                          ),
                  ),
                ),
                if (!reward.isPurchased && showPrice)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.monetization_on,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${reward.cost}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Reward name
            Text(
              reward.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: reward.isPurchased ? Colors.black : Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (showDetails) ...[
              const SizedBox(height: 4),
              // Reward description
              Text(
                reward.description,
                style: TextStyle(
                  fontSize: 12,
                  color: reward.isPurchased ? Colors.grey : Colors.grey.shade400,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Reward type
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getTypeColor(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getTypeText(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (reward.isPurchased && reward.purchasedAt != null) ...[
                const SizedBox(height: 4),
                // Purchase date
                Text(
                  'Mua ngày: ${_formatDate(reward.purchasedAt!)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Color _getBorderColor() {
    if (!reward.isPurchased) {
      return Colors.grey;
    }

    switch (reward.type) {
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

  Color _getBackgroundColor() {
    if (!reward.isPurchased) {
      return Colors.grey.shade200;
    }

    switch (reward.type) {
      case RewardTypes.avatar:
        return Colors.blue.shade100;
      case RewardTypes.background:
        return Colors.green.shade100;
      case RewardTypes.character:
        return Colors.purple.shade100;
      case RewardTypes.accessory:
        return Colors.orange.shade100;
      case RewardTypes.theme:
        return Colors.pink.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getTypeColor() {
    switch (reward.type) {
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

  String _getTypeText() {
    switch (reward.type) {
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
