import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/question_model.dart';
import '../quiz/quiz_option_card.dart';
import '../quiz/pairing_item_card.dart';
import '../quiz/sequential_item_card.dart';

class QuestionPreviewWidget extends StatelessWidget {
  final QuestionModel question;

  const QuestionPreviewWidget({
    super.key,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Xem trước:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),

            // Question text
            Text(
              question.text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Question image if available
            if (question.imageUrl != null && question.imageUrl!.isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: question.imageUrl!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 200,
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Audio indicator if available
            if (question.audioUrl != null && question.audioUrl!.isNotEmpty)
              const ListTile(
                leading: Icon(Icons.music_note, color: Colors.blue),
                title: Text('Âm thanh có sẵn'),
                subtitle: Text('Âm thanh sẽ phát khi hiển thị câu hỏi'),
              ),

            const SizedBox(height: 16),

            // Type-specific preview
            if (question.type == AppConstants.choicesQuiz)
              _buildChoicesPreview(),
            if (question.type == AppConstants.sequentialQuiz)
              _buildSequentialPreview(),
            if (question.type == AppConstants.pairingQuiz)
              _buildPairingPreview(),

            const SizedBox(height: 16),

            // Hint if available
            if (question.hint != null && question.hint!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.yellow.shade700),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gợi ý:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          Text(question.hint!),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoicesPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Các lựa chọn:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Grid of options
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: question.options.length,
          itemBuilder: (context, index) {
            final option = question.options[index];
            final isCorrect = option.id == question.correctOptionId;

            return QuizOptionCard(
              option: option,
              isSelected: false,
              isCorrect: isCorrect,
              isWrong: false,
              onTap: null,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSequentialPreview() {
    // Show options in correct sequence if available
    final displayOptions = <AnswerOption>[];

    if (question.correctSequence != null && question.correctSequence!.isNotEmpty) {
      for (final id in question.correctSequence!) {
        final option = question.options.firstWhere(
          (o) => o.id == id,
          orElse: () => const AnswerOption(id: '', text: 'Unknown'),
        );
        displayOptions.add(option);
      }
    } else {
      displayOptions.addAll(question.options);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thứ tự đúng:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // List of sequential items
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayOptions.length,
          itemBuilder: (context, index) {
            final option = displayOptions[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: SequentialItemCard(
                option: option,
                index: index + 1,
                isCorrect: false,
                isWrong: false,
                isDraggable: false,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPairingPreview() {
    // Separate left and right options
    final leftOptions = <AnswerOption>[];
    final rightOptions = <AnswerOption>[];

    if (question.correctPairs != null && question.correctPairs!.isNotEmpty) {
      for (final option in question.options) {
        if (question.correctPairs!.containsKey(option.id)) {
          leftOptions.add(option);
        } else {
          rightOptions.add(option);
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ghép đôi:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Two columns for pairing
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: leftOptions.map((option) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: PairingItemCard(
                      option: option,
                      isSelected: false,
                      isPaired: true,
                      isCorrect: false,
                      isWrong: false,
                      onTap: null,
                    ),
                  );
                }).toList(),
              ),
            ),

            // Connection lines
            const SizedBox(width: 20),
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_forward, color: Colors.blue),
              ],
            ),
            const SizedBox(width: 20),

            // Right column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: rightOptions.map((option) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: PairingItemCard(
                      option: option,
                      isSelected: false,
                      isPaired: true,
                      isCorrect: false,
                      isWrong: false,
                      onTap: null,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
