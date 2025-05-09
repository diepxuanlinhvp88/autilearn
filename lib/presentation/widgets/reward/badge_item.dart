import 'package:flutter/material.dart';
import '../../../data/models/badge_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BadgeItem extends StatelessWidget {
  final BadgeModel badge;
  final VoidCallback? onTap;
  final bool showDetails;

  const BadgeItem({
    Key? key,
    required this.badge,
    this.onTap,
    this.showDetails = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
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
            // Badge image
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _getBackgroundColor(),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: badge.isUnlocked
                        ? CachedNetworkImage(
                            imageUrl: badge.imageUrl,
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
                              imageUrl: badge.imageUrl,
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
                if (!badge.isUnlocked)
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Badge name
            Text(
              badge.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: badge.isUnlocked ? Colors.black : Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (showDetails) ...[
              const SizedBox(height: 4),
              // Badge description
              Text(
                badge.description,
                style: TextStyle(
                  fontSize: 12,
                  color: badge.isUnlocked ? Colors.grey : Colors.grey.shade400,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Badge category
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getCategoryColor(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getCategoryText(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (badge.isUnlocked && badge.unlockedAt != null) ...[
                const SizedBox(height: 4),
                // Unlocked date
                Text(
                  'Đạt được: ${_formatDate(badge.unlockedAt!)}',
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
    if (!badge.isUnlocked) {
      return Colors.grey;
    }

    switch (badge.category) {
      case BadgeCategories.completion:
        return Colors.green;
      case BadgeCategories.streak:
        return Colors.orange;
      case BadgeCategories.mastery:
        return Colors.blue;
      case BadgeCategories.special:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getBackgroundColor() {
    if (!badge.isUnlocked) {
      return Colors.grey.shade200;
    }

    switch (badge.category) {
      case BadgeCategories.completion:
        return Colors.green.shade100;
      case BadgeCategories.streak:
        return Colors.orange.shade100;
      case BadgeCategories.mastery:
        return Colors.blue.shade100;
      case BadgeCategories.special:
        return Colors.purple.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getCategoryColor() {
    switch (badge.category) {
      case BadgeCategories.completion:
        return Colors.green;
      case BadgeCategories.streak:
        return Colors.orange;
      case BadgeCategories.mastery:
        return Colors.blue;
      case BadgeCategories.special:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryText() {
    switch (badge.category) {
      case BadgeCategories.completion:
        return 'Hoàn thành';
      case BadgeCategories.streak:
        return 'Liên tiếp';
      case BadgeCategories.mastery:
        return 'Thành thạo';
      case BadgeCategories.special:
        return 'Đặc biệt';
      default:
        return 'Khác';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
