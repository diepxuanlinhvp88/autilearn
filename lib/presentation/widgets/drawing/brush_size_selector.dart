import 'package:flutter/material.dart';

class BrushSizeSelector extends StatelessWidget {
  final double selectedSize;
  final Function(double) onSizeSelected;

  const BrushSizeSelector({
    Key? key,
    required this.selectedSize,
    required this.onSizeSelected,
  }) : super(key: key);

  static const List<double> _sizes = [2.0, 5.0, 10.0, 15.0, 20.0, 25.0, 30.0];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          const Icon(Icons.brush, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Slider(
              value: selectedSize,
              min: _sizes.first,
              max: _sizes.last,
              divisions: _sizes.length - 1,
              label: selectedSize.toStringAsFixed(1),
              onChanged: onSizeSelected,
            ),
          ),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
              border: Border.all(color: Colors.grey),
            ),
            child: Center(
              child: Container(
                width: selectedSize,
                height: selectedSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
