import 'package:flutter/material.dart';
import '../../../presentation/widgets/common/confetti_animation.dart';

class QuizResultPage extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final VoidCallback onRetry;
  final VoidCallback onHome;

  const QuizResultPage({
    Key? key,
    required this.score,
    required this.totalQuestions,
    required this.onRetry,
    required this.onHome,
  }) : super(key: key);

  @override
  State<QuizResultPage> createState() => _QuizResultPageState();
}

class _QuizResultPageState extends State<QuizResultPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double percentage = widget.score / widget.totalQuestions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả bài học'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // Bao bọc toàn bộ nội dung trong ConfettiAnimation để có hiệu ứng pháo hoa
      body: ConfettiAnimation(
        child: Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Trophy icon - với hiệu ứng xuất hiện
            ScaleTransition(
              scale: CurvedAnimation(
                parent: _controller,
                curve: Curves.elasticOut,
              ),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 64,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Score - với hiệu ứng đếm số
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: widget.score),
              duration: const Duration(milliseconds: 1500),
              builder: (context, value, child) {
                return Text(
                  'Điểm của bạn: $value/${widget.totalQuestions}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // Percentage - với hiệu ứng tăng dần
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: percentage),
              duration: const Duration(milliseconds: 1500),
              builder: (context, value, child) {
                return Column(
                  children: [
                    Text(
                      'Tỷ lệ đúng: ${(value * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Progress bar - với hiệu ứng tăng dần
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: value,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(value)),
                          minHeight: 10,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 40),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    print('QuizResultPage: Home button pressed');
                    widget.onHome();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Quay lại trang chủ',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    print('QuizResultPage: Retry button pressed');
                    widget.onRetry();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Làm lại',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 0.8) {
      return Colors.green;
    } else if (percentage >= 0.6) {
      return Colors.amber;
    } else {
      return Colors.red;
    }
  }
}
