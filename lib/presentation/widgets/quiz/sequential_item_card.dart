import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/question_model.dart';

class SequentialItemCard extends StatelessWidget {
  final AnswerOption option;
  final int index;
  final bool isCorrect;
  final bool isWrong;
  final bool isDraggable;
  final VoidCallback? onRemove;

  const SequentialItemCard({
    super.key,
    required this.option,
    required this.index,
    required this.isCorrect,
    required this.isWrong,
    required this.isDraggable,
    this.onRemove,
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
    }

    return Container(
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
          // Index circle
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: borderColor.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                index.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: borderColor,
                ),
              ),
            ),
          ),
          // Option content
          Expanded(
            child: Row(
              children: [
                if (option.imageUrl != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
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
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      option.text,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Status icons
          if (isCorrect)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
            )
          else if (isWrong)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.cancel,
                color: Colors.red,
              ),
            ),
          // Drag handle or remove button
          if (isDraggable)
            Row(
              children: [
                // if (onRemove != null)
                //   IconButton(
                //     icon: const Icon(Icons.close),
                //     onPressed: onRemove,
                //     color: Colors.grey,
                //     tooltip: 'Xóa khỏi trình tự',
                //   ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.drag_handle,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
