import 'package:flutter/material.dart';

class ColorPalette extends StatelessWidget {
  final Color selectedColor;
  final Function(Color) onColorSelected;

  const ColorPalette({
    Key? key,
    required this.selectedColor,
    required this.onColorSelected,
  }) : super(key: key);

  static const List<Color> _colors = [
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _colors.length,
        itemBuilder: (context, index) {
          final color = _colors[index];
          final isSelected = color.value == selectedColor.value;
          
          return GestureDetector(
            onTap: () => onColorSelected(color),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey,
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: color == Colors.white && isSelected
                  ? const Icon(Icons.check, color: Colors.grey, size: 20)
                  : null,
            ),
          );
        },
      ),
    );
  }
}
