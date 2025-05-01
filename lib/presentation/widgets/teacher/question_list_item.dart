import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/question_model.dart';

class QuestionListItem extends StatelessWidget {
  final QuestionModel question;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onReorder;

  const QuestionListItem({
    super.key,
    required this.question,
    required this.onEdit,
    required this.onDelete,
    this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question order and type
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getTypeColor(),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Câu ${question.order}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _getTypeText(),
                    style: TextStyle(
                      color: _getTypeColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                // Action buttons
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: onEdit,
                  tooltip: 'Chỉnh sửa',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                  tooltip: 'Xóa',
                ),
                if (onReorder != null)
                  IconButton(
                    icon: const Icon(Icons.reorder, color: Colors.grey),
                    onPressed: onReorder,
                    tooltip: 'Thay đổi thứ tự',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Question text
            Text(
              question.text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Question content preview
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question image if available
                if (question.imageUrl != null && question.imageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: question.imageUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                if (question.imageUrl != null && question.imageUrl!.isNotEmpty)
                  const SizedBox(width: 12),
                
                // Question options summary
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getOptionsSummary(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (question.hint != null && question.hint!.isNotEmpty)
                        Row(
                          children: [
                            const Icon(
                              Icons.lightbulb_outline,
                              size: 16,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Gợi ý: ${question.hint}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.orange,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      if (question.audioUrl != null && question.audioUrl!.isNotEmpty)
                        const Row(
                          children: [
                            Icon(
                              Icons.music_note,
                              size: 16,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Có âm thanh',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (question.type) {
      case AppConstants.choicesQuiz:
        return Colors.blue;
      case AppConstants.pairingQuiz:
        return Colors.green;
      case AppConstants.sequentialQuiz:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getTypeText() {
    switch (question.type) {
      case AppConstants.choicesQuiz:
        return 'Lựa chọn';
      case AppConstants.pairingQuiz:
        return 'Ghép đôi';
      case AppConstants.sequentialQuiz:
        return 'Sắp xếp';
      default:
        return 'Không xác định';
    }
  }

  String _getOptionsSummary() {
    if (question.options.isEmpty) {
      return 'Không có lựa chọn';
    }

    if (question.type == AppConstants.choicesQuiz) {
      final correctOption = question.options.firstWhere(
        (option) => option.id == question.correctOptionId,
        orElse: () => const AnswerOption(id: '', text: 'Unknown'),
      );
      
      return 'Đáp án đúng: ${correctOption.text}\n'
          'Tổng số lựa chọn: ${question.options.length}';
    } else if (question.type == AppConstants.sequentialQuiz) {
      return 'Số lượng mục: ${question.options.length}\n'
          'Thứ tự đúng: ${question.correctSequence?.length ?? 0} mục';
    } else if (question.type == AppConstants.pairingQuiz) {
      return 'Số cặp ghép: ${question.correctPairs?.length ?? 0}';
    }
    
    return 'Số lượng lựa chọn: ${question.options.length}';
  }
}
