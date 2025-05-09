import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/question_model.dart';

class PairingItemCard extends StatelessWidget {
  final AnswerOption option;
  final bool isSelected;
  final bool isPaired;
  final bool isCorrect;
  final bool isWrong;
  final VoidCallback? onTap;

  const PairingItemCard({
    super.key,
    required this.option,
    required this.isSelected,
    required this.isPaired,
    required this.isCorrect,
    required this.isWrong,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.grey;
    Color backgroundColor = Colors.white;

    if (isCorrect) {
      borderColor = Colors.green;
      backgroundColor = Colors.green.withOpacity(0.1);
    } else if (isWrong) {
      borderColor = Colors.red;
      backgroundColor = Colors.red.withOpacity(0.1);
    } else if (isSelected) {
      borderColor = Colors.blue;
      backgroundColor = Colors.blue.withOpacity(0.1);
    } else if (isPaired) {
      borderColor = Colors.purple;
      backgroundColor = Colors.purple.withOpacity(0.1);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        height: 80, // Đặt chiều cao cố định cho tất cả các ô
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa các phần tử theo chiều dọc
          children: [
            // Hình ảnh với kích thước cố định
            Container(
              width: 60,
              height: 60,
              child: option.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CachedNetworkImage(
                      imageUrl: option.imageUrl!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(
                          Icons.error,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  )
                : const SizedBox(), // Vẫn giữ khoảng trống cho các mục không có hình ảnh
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                option.text,
                style: TextStyle(
                  fontWeight: isSelected || isPaired ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Colors.blue
                      : isPaired
                          ? Colors.purple
                          : Colors.black,
                ),
                maxLines: 3, // Giới hạn số dòng để tránh văn bản quá dài
                overflow: TextOverflow.ellipsis, // Hiển thị dấu ... nếu văn bản bị cắt
              ),
            ),
            if (isCorrect)
              const Icon(
                Icons.check_circle,
                color: Colors.green,
              )
            else if (isWrong)
              const Icon(
                Icons.cancel,
                color: Colors.red,
              )
            else if (isSelected)
              const Icon(
                Icons.touch_app,
                color: Colors.blue,
              )
            else if (isPaired)
              const Icon(
                Icons.link,
                color: Colors.purple,
              ),
          ],
        ),
      ),
    );
  }
}
