import 'package:flutter/material.dart';
import '../widgets/image_picker_widget.dart';

class CreateQuestionScreen extends StatefulWidget {
  final String quizId;
  final String? questionId; // Nếu có questionId thì là chỉnh sửa, không có thì là tạo mới

  const CreateQuestionScreen({
    Key? key,
    required this.quizId,
    this.questionId,
  }) : super(key: key);

  @override
  State<CreateQuestionScreen> createState() => _CreateQuestionScreenState();
}

class _CreateQuestionScreenState extends State<CreateQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _questionTextController = TextEditingController();
  final TextEditingController _hintController = TextEditingController();
  
  String _questionType = 'choices'; // Mặc định là câu hỏi trắc nghiệm
  int _order = 1;
  
  // Danh sách các lựa chọn cho câu hỏi trắc nghiệm
  final List<Map<String, dynamic>> _options = [];
  
  // Đáp án đúng cho câu hỏi trắc nghiệm
  String? _correctOptionId;
  
  // Các cặp ghép đôi cho câu hỏi ghép đôi
  final Map<String, String> _correctPairs = {};
  
  // Thứ tự đúng cho câu hỏi sắp xếp
  final List<String> _correctSequence = [];

  @override
  void initState() {
    super.initState();
    
    // Nếu là chỉnh sửa câu hỏi, tải dữ liệu câu hỏi
    if (widget.questionId != null) {
      _loadQuestionData();
    } else {
      // Nếu là tạo mới, thêm 4 lựa chọn mặc định cho câu hỏi trắc nghiệm
      _addDefaultOptions();
    }
  }

  void _loadQuestionData() {
    // TODO: Tải dữ liệu câu hỏi từ Firestore
    // Đây là nơi bạn sẽ tải dữ liệu câu hỏi từ Firestore nếu là chỉnh sửa
  }

  void _addDefaultOptions() {
    // Thêm 4 lựa chọn mặc định cho câu hỏi trắc nghiệm
    _options.addAll([
      {'id': 'A', 'text': '', 'imageUrl': null},
      {'id': 'B', 'text': '', 'imageUrl': null},
      {'id': 'C', 'text': '', 'imageUrl': null},
      {'id': 'D', 'text': '', 'imageUrl': null},
    ]);
  }

  void _onOptionImageSelected(int index, String imageUrl) {
    setState(() {
      _options[index]['imageUrl'] = imageUrl;
    });
  }

  void _onOptionImageRemoved(int index) {
    setState(() {
      _options[index]['imageUrl'] = null;
    });
  }

  void _saveQuestion() async {
    if (_formKey.currentState!.validate()) {
      // TODO: Lưu câu hỏi vào Firestore
      // Đây là nơi bạn sẽ lưu câu hỏi vào Firestore
      
      // Quay lại màn hình trước
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.questionId == null ? 'Tạo câu hỏi mới' : 'Chỉnh sửa câu hỏi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveQuestion,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Loại câu hỏi
              const Text(
                'Loại câu hỏi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              DropdownButtonFormField<String>(
                value: _questionType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'choices', child: Text('Trắc nghiệm')),
                  DropdownMenuItem(value: 'pairing', child: Text('Ghép đôi')),
                  DropdownMenuItem(value: 'sequential', child: Text('Sắp xếp')),
                ],
                onChanged: (value) {
                  setState(() {
                    _questionType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Nội dung câu hỏi
              const Text(
                'Nội dung câu hỏi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextFormField(
                controller: _questionTextController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Nhập nội dung câu hỏi',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập nội dung câu hỏi';
                  }
                  return null;
                },
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              // Gợi ý
              const Text(
                'Gợi ý',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextFormField(
                controller: _hintController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Nhập gợi ý cho câu hỏi (không bắt buộc)',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              
              // Thứ tự hiển thị
              const Text(
                'Thứ tự hiển thị',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextFormField(
                initialValue: _order.toString(),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Nhập thứ tự hiển thị',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập thứ tự hiển thị';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Thứ tự phải là số';
                  }
                  return null;
                },
                onChanged: (value) {
                  _order = int.tryParse(value) ?? 1;
                },
              ),
              const SizedBox(height: 24),
              
              // Hiển thị các lựa chọn dựa trên loại câu hỏi
              if (_questionType == 'choices') _buildChoicesOptions(),
              if (_questionType == 'pairing') _buildPairingOptions(),
              if (_questionType == 'sequential') _buildSequentialOptions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoicesOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Các lựa chọn',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        
        // Danh sách các lựa chọn
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _options.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Lựa chọn ${_options[index]['id']}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const Spacer(),
                        Radio<String>(
                          value: _options[index]['id'],
                          groupValue: _correctOptionId,
                          onChanged: (value) {
                            setState(() {
                              _correctOptionId = value;
                            });
                          },
                        ),
                        const Text('Đáp án đúng'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Nội dung lựa chọn
                    TextFormField(
                      initialValue: _options[index]['text'],
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Nội dung',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập nội dung lựa chọn';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _options[index]['text'] = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Hình ảnh cho lựa chọn
                    const Text(
                      'Hình ảnh (không bắt buộc)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ImagePickerWidget(
                      initialImageUrl: _options[index]['imageUrl'],
                      onImageSelected: (imageUrl) => _onOptionImageSelected(index, imageUrl),
                      onImageRemoved: () => _onOptionImageRemoved(index),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        
        // Nút thêm lựa chọn
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              final String newId = String.fromCharCode('A'.codeUnitAt(0) + _options.length);
              _options.add({'id': newId, 'text': '', 'imageUrl': null});
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('Thêm lựa chọn'),
        ),
      ],
    );
  }

  Widget _buildPairingOptions() {
    // TODO: Xây dựng giao diện cho câu hỏi ghép đôi
    return const Center(
      child: Text('Giao diện cho câu hỏi ghép đôi sẽ được xây dựng sau'),
    );
  }

  Widget _buildSequentialOptions() {
    // TODO: Xây dựng giao diện cho câu hỏi sắp xếp
    return const Center(
      child: Text('Giao diện cho câu hỏi sắp xếp sẽ được xây dựng sau'),
    );
  }

  @override
  void dispose() {
    _questionTextController.dispose();
    _hintController.dispose();
    super.dispose();
  }
}
