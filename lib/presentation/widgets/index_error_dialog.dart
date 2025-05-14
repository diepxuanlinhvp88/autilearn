import 'package:flutter/material.dart';
import '../../core/utils/firestore_error_handler.dart';

/// Widget hiển thị dialog lỗi khi cần tạo index
class IndexErrorDialog extends StatelessWidget {
  final dynamic error;
  final VoidCallback? onRetry;

  const IndexErrorDialog({
    Key? key,
    required this.error,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String? indexUrl = FirestoreErrorHandler.extractIndexUrl(error);
    final String errorMessage = FirestoreErrorHandler.getFriendlyErrorMessage(error);

    return AlertDialog(
      title: const Text('Cần tạo index'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(errorMessage),
          if (indexUrl != null) ...[
            const SizedBox(height: 16),
            const Text(
              'Sau khi tạo index, có thể mất vài phút để hoàn tất. Vui lòng thử lại sau khi index được tạo.',
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Đóng'),
        ),
        if (onRetry != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry!();
            },
            child: const Text('Thử lại'),
          ),
        if (indexUrl != null) ...[
          TextButton(
            onPressed: () async {
              await FirestoreErrorHandler.copyIndexUrlToClipboard(indexUrl);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã sao chép URL tạo index vào clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Sao chép URL'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await FirestoreErrorHandler.openIndexUrl(indexUrl);
              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Không thể mở URL. URL đã được sao chép vào clipboard.'),
                    duration: Duration(seconds: 3),
                  ),
                );
                await FirestoreErrorHandler.copyIndexUrlToClipboard(indexUrl);
              }
            },
            child: const Text('Tạo index'),
          ),
        ],
      ],
    );
  }
}

/// Extension để hiển thị dialog lỗi index
extension IndexErrorDialogExtension on BuildContext {
  /// Hiển thị dialog lỗi index
  Future<void> showIndexErrorDialog(dynamic error, {VoidCallback? onRetry}) async {
    if (FirestoreErrorHandler.isMissingIndexError(error)) {
      await showDialog(
        context: this,
        builder: (context) => IndexErrorDialog(
          error: error,
          onRetry: onRetry,
        ),
      );
    } else {
      // Hiển thị thông báo lỗi thông thường
      ScaffoldMessenger.of(this).showSnackBar(
        SnackBar(
          content: Text(FirestoreErrorHandler.getFriendlyErrorMessage(error)),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}
