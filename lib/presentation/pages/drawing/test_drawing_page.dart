import 'package:flutter/material.dart';
import '../../../presentation/widgets/drawing/simple_canvas.dart';

class TestDrawingPage extends StatefulWidget {
  const TestDrawingPage({Key? key}) : super(key: key);

  @override
  State<TestDrawingPage> createState() => _TestDrawingPageState();
}

class _TestDrawingPageState extends State<TestDrawingPage> {
  Color _selectedColor = Colors.black;
  double _strokeWidth = 5.0;
  bool _hasChanges = false;
  final GlobalKey<SimpleCanvasState> _canvasKey = GlobalKey<SimpleCanvasState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiểm tra vẽ'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _canvasKey.currentState?.clear();
              setState(() {
                _hasChanges = false;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Canvas
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SimpleCanvas(
                  key: _canvasKey,
                  color: _selectedColor,
                  strokeWidth: _strokeWidth,
                  onDrawingChanged: () {
                    setState(() {
                      _hasChanges = true;
                    });
                  },
                ),
              ),
            ),
          ),
          
          // Color selection
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Color buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildColorButton(Colors.black),
                    _buildColorButton(Colors.red),
                    _buildColorButton(Colors.green),
                    _buildColorButton(Colors.blue),
                    _buildColorButton(Colors.yellow),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Stroke width slider
                Row(
                  children: [
                    const Text('Độ dày:'),
                    Expanded(
                      child: Slider(
                        value: _strokeWidth,
                        min: 1.0,
                        max: 20.0,
                        onChanged: (value) {
                          setState(() {
                            _strokeWidth = value;
                          });
                        },
                      ),
                    ),
                    Text('${_strokeWidth.toInt()}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: _selectedColor == color ? Colors.blue : Colors.grey,
            width: _selectedColor == color ? 3 : 1,
          ),
        ),
      ),
    );
  }
}
