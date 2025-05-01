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
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            if (option.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CachedNetworkImage(
                  imageUrl: option.imageUrl!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const SizedBox(
                    width: 60,
                    height: 60,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => const SizedBox(
                    width: 60,
                    height: 60,
                    child: Center(
                      child: Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
            if (option.imageUrl != null)
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
