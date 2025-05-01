import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiAnimation extends StatefulWidget {
  final Widget child;

  const ConfettiAnimation({
    super.key,
    required this.child,
  });

  @override
  State<ConfettiAnimation> createState() => _ConfettiAnimationState();
}

class _ConfettiAnimationState extends State<ConfettiAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Confetti> _confetti;
  final int _confettiCount = 50;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _confetti = List.generate(_confettiCount, (_) => Confetti(_random));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: ConfettiPainter(
                _confetti,
                _controller.value,
              ),
              child: Container(),
            );
          },
        ),
      ],
    );
  }
}

class Confetti {
  final Random random;
  late Color color;
  late double x;
  late double y;
  late double size;
  late double speed;
  late double angle;

  Confetti(this.random) {
    reset();
  }

  void reset() {
    color = _getRandomColor();
    x = random.nextDouble();
    y = random.nextDouble() * -1;
    size = 5 + random.nextDouble() * 10;
    speed = 0.1 + random.nextDouble() * 0.2;
    angle = random.nextDouble() * pi * 2;
  }

  Color _getRandomColor() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
    ];
    return colors[random.nextInt(colors.length)];
  }

  void update(double animationValue) {
    y += speed * animationValue;
    x += sin(angle) * 0.05;

    if (y > 1) {
      reset();
    }
  }
}

class ConfettiPainter extends CustomPainter {
  final List<Confetti> confetti;
  final double animationValue;

  ConfettiPainter(this.confetti, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (var confetti in this.confetti) {
      confetti.update(animationValue);
      
      final paint = Paint()
        ..color = confetti.color
        ..style = PaintingStyle.fill;
      
      canvas.save();
      canvas.translate(confetti.x * size.width, confetti.y * size.height);
      canvas.rotate(confetti.angle);
      
      // Draw a rectangle for confetti
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: confetti.size,
          height: confetti.size * 0.5,
        ),
        paint,
      );
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}
