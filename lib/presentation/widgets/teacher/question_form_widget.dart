import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/question_model.dart';
import '../image_picker_widget.dart';

class QuestionFormWidget extends StatefulWidget {
  final String quizType;
  final QuestionModel? initialQuestion;
  final Function(QuestionModel) onSave;

  const QuestionFormWidget({
    super.key,
    required this.quizType,
    this.initialQuestion,
    required this.onSave,
  });

  @override
  State<QuestionFormWidget> createState() => _QuestionFormWidgetState();
}

class _QuestionFormWidgetState extends State<QuestionFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _questionTextController = TextEditingController();
  final _hintController = TextEditingController();
  final _audioUrlController = TextEditingController();

  String? _imageUrl;

  // For choices quiz
  String? _correctOptionId;
  List<AnswerOption> _options = [];

  // For sequential quiz
  List<String> _correctSequence = [];

  // For pairing quiz
  Map<String, String> _correctPairs = {};
  List<AnswerOption> _leftOptions = [];
  List<AnswerOption> _rightOptions = [];

  @override
  void initState() {
    super.initState();

    if (widget.initialQuestion != null) {
      _questionTextController.text = widget.initialQuestion!.text;
      _hintController.text = widget.initialQuestion!.hint ?? '';
      _imageUrl = widget.initialQuestion!.imageUrl;
      _audioUrlController.text = widget.initialQuestion!.audioUrl ?? '';

      if (widget.quizType == AppConstants.choicesQuiz) {
        _options = List.from(widget.initialQuestion!.options);
        _correctOptionId = widget.initialQuestion!.correctOptionId;
      } else if (widget.quizType == AppConstants.sequentialQuiz) {
        _options = List.from(widget.initialQuestion!.options);
        _correctSequence = List.from(widget.initialQuestion!.correctSequence ?? []);
      } else if (widget.quizType == AppConstants.pairingQuiz) {
        // Split options into left and right for pairing quiz
        final allOptions = widget.initialQuestion!.options;
        _correctPairs = Map.from(widget.initialQuestion!.correctPairs ?? {});

        // Separate left and right options based on correctPairs
        for (var option in allOptions) {
          if (_correctPairs.containsKey(option.id)) {
            _leftOptions.add(option);
          } else {
            _rightOptions.add(option);
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _questionTextController.dispose();
    _hintController.dispose();
    _audioUrlController.dispose();
    super.dispose();
  }

  void _addOption() {
    setState(() {
      final newId = _options.isEmpty ? 'A' : String.fromCharCode(_options.last.id.codeUnitAt(0) + 1);
      _options.add(AnswerOption(
        id: newId,
        text: '',
        imageUrl: null,
      ));
    });
  }

  void _removeOption(int index) {
    setState(() {
      final removedOption = _options[index];
      _options.removeAt(index);

      // Update correctOptionId if needed
      if (widget.quizType == AppConstants.choicesQuiz &&
          removedOption.id == _correctOptionId) {
        _correctOptionId = null;
      }

      // Update correctSequence if needed
      if (widget.quizType == AppConstants.sequentialQuiz) {
        _correctSequence.remove(removedOption.id);
      }
    });
  }

  void _addPairingOption(bool isLeft) {
    setState(() {
      if (isLeft) {
        final newId = _leftOptions.isEmpty ? 'L1' : 'L${_leftOptions.length + 1}';
        _leftOptions.add(AnswerOption(
          id: newId,
          text: '',
          imageUrl: null,
        ));
      } else {
        final newId = _rightOptions.isEmpty ? 'R1' : 'R${_rightOptions.length + 1}';
        _rightOptions.add(AnswerOption(
          id: newId,
          text: '',
          imageUrl: null,
        ));
      }
    });
  }

  void _removePairingOption(int index, bool isLeft) {
    setState(() {
      if (isLeft) {
        final removedOption = _leftOptions[index];
        _leftOptions.removeAt(index);

        // Remove from pairs
        _correctPairs.remove(removedOption.id);
      } else {
        final removedOption = _rightOptions[index];
        _rightOptions.removeAt(index);

        // Remove from pairs
        _correctPairs.removeWhere((key, value) => value == removedOption.id);
      }
    });
  }

  void _updateOptionText(int index, String text) {
    setState(() {
      _options[index] = _options[index].copyWith(text: text);
    });
  }

  void _updateOptionImageUrl(int index, String? imageUrl) {
    setState(() {
      _options[index] = _options[index].copyWith(imageUrl: imageUrl);
    });
  }

  void _updatePairingOptionText(int index, String text, bool isLeft) {
    setState(() {
      if (isLeft) {
        _leftOptions[index] = _leftOptions[index].copyWith(text: text);
      } else {
        _rightOptions[index] = _rightOptions[index].copyWith(text: text);
      }
    });
  }

  void _updatePairingOptionImageUrl(int index, String? imageUrl, bool isLeft) {
    setState(() {
      if (isLeft) {
        _leftOptions[index] = _leftOptions[index].copyWith(imageUrl: imageUrl);
      } else {
        _rightOptions[index] = _rightOptions[index].copyWith(imageUrl: imageUrl);
      }
    });
  }

  void _updateCorrectPair(String leftId, String rightId) {
    setState(() {
      _correctPairs[leftId] = rightId;
    });
  }

  void _saveQuestion() {
    if (!_formKey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }

    print('Saving question...');
    print('Initial question ID: ${widget.initialQuestion?.id}');
    print('Quiz type: ${widget.quizType}');

    QuestionModel question;

    if (widget.quizType == AppConstants.choicesQuiz) {
      question = QuestionModel(
        id: widget.initialQuestion?.id ?? '',
        quizId: widget.initialQuestion?.quizId ?? '',
        text: _questionTextController.text,
        audioUrl: _audioUrlController.text.isEmpty ? null : _audioUrlController.text,
        type: widget.quizType,
        options: _options,
        correctOptionId: _correctOptionId,
        imageUrl: _imageUrl,
        order: widget.initialQuestion?.order ?? 1,
        hint: _hintController.text.isEmpty ? null : _hintController.text,
      );
      print('Choices quiz - Options count: ${_options.length}, Correct option ID: $_correctOptionId');
    } else if (widget.quizType == AppConstants.sequentialQuiz) {
      question = QuestionModel(
        id: widget.initialQuestion?.id ?? '',
        quizId: widget.initialQuestion?.quizId ?? '',
        text: _questionTextController.text,
        audioUrl: _audioUrlController.text.isEmpty ? null : _audioUrlController.text,
        type: widget.quizType,
        options: _options,
        correctSequence: _correctSequence,
        imageUrl: _imageUrl,
        order: widget.initialQuestion?.order ?? 1,
        hint: _hintController.text.isEmpty ? null : _hintController.text,
      );
      print('Sequential quiz - Options count: ${_options.length}, Sequence length: ${_correctSequence.length}');
    } else {
      // Combine left and right options for pairing quiz
      final allOptions = [..._leftOptions, ..._rightOptions];

      question = QuestionModel(
        id: widget.initialQuestion?.id ?? '',
        quizId: widget.initialQuestion?.quizId ?? '',
        text: _questionTextController.text,
        audioUrl: _audioUrlController.text.isEmpty ? null : _audioUrlController.text,
        type: widget.quizType,
        options: allOptions,
        correctPairs: _correctPairs,
        imageUrl: _imageUrl,
        order: widget.initialQuestion?.order ?? 1,
        hint: _hintController.text.isEmpty ? null : _hintController.text,
      );
      print('Pairing quiz - Left options: ${_leftOptions.length}, Right options: ${_rightOptions.length}, Pairs: ${_correctPairs.length}');
    }

    print('Question to save: $question');
    print('Question ID: ${question.id}');
    print('Question text: ${question.text}');

    widget.onSave(question);
    print('onSave callback called');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text
          TextFormField(
            controller: _questionTextController,
            decoration: const InputDecoration(
              labelText: 'Câu hỏi',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.question_mark),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập câu hỏi';
              }
              return null;
            },
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          // Hint
          TextFormField(
            controller: _hintController,
            decoration: const InputDecoration(
              labelText: 'Gợi ý (không bắt buộc)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lightbulb_outline),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          // Image Picker
          const Text(
            'Hình ảnh (không bắt buộc)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ImagePickerWidget(
            initialImageUrl: _imageUrl,
            onImageSelected: (url) {
              setState(() {
                _imageUrl = url;
              });
            },
            onImageRemoved: () {
              setState(() {
                _imageUrl = null;
              });
            },
          ),
          const SizedBox(height: 16),

          // Audio URL
          TextFormField(
            controller: _audioUrlController,
            decoration: const InputDecoration(
              labelText: 'URL âm thanh (không bắt buộc)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.music_note),
            ),
          ),
          const SizedBox(height: 24),

          // Type-specific form fields
          if (widget.quizType == AppConstants.choicesQuiz)
            _buildChoicesForm(),
          if (widget.quizType == AppConstants.sequentialQuiz)
            _buildSequentialForm(),
          if (widget.quizType == AppConstants.pairingQuiz)
            _buildPairingForm(),

          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _saveQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Lưu câu hỏi',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoicesForm() {
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

        // Options list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _options.length,
          itemBuilder: (context, index) {
            final option = _options[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Option ID
                        CircleAvatar(
                          backgroundColor: _correctOptionId == option.id
                              ? Colors.green
                              : Colors.grey,
                          child: Text(
                            option.id,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Option text field
                        Expanded(
                          child: TextFormField(
                            initialValue: option.text,
                            decoration: const InputDecoration(
                              labelText: 'Nội dung',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập nội dung';
                              }
                              return null;
                            },
                            onChanged: (value) => _updateOptionText(index, value),
                          ),
                        ),

                        // Remove button
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeOption(index),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Image Picker
                    const Text(
                      'Hình ảnh (không bắt buộc)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    ImagePickerWidget(
                      initialImageUrl: option.imageUrl,
                      onImageSelected: (url) => _updateOptionImageUrl(index, url),
                      onImageRemoved: () => _updateOptionImageUrl(index, null),
                    ),

                    // Correct answer checkbox
                    CheckboxListTile(
                      title: const Text('Đây là đáp án đúng'),
                      value: _correctOptionId == option.id,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _correctOptionId = option.id;
                          } else {
                            _correctOptionId = null;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // Add option button
        TextButton.icon(
          onPressed: _addOption,
          icon: const Icon(Icons.add),
          label: const Text('Thêm lựa chọn'),
        ),

        // Validation message for correct option
        if (_options.isNotEmpty && _correctOptionId == null)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              'Vui lòng chọn một đáp án đúng',
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildSequentialForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Các mục cần sắp xếp:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Options list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _options.length,
          itemBuilder: (context, index) {
            final option = _options[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Option ID
                        CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            option.id,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Option text field
                        Expanded(
                          child: TextFormField(
                            initialValue: option.text,
                            decoration: const InputDecoration(
                              labelText: 'Nội dung',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập nội dung';
                              }
                              return null;
                            },
                            onChanged: (value) => _updateOptionText(index, value),
                          ),
                        ),

                        // Remove button
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeOption(index),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Image Picker
                    const Text(
                      'Hình ảnh (không bắt buộc)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    ImagePickerWidget(
                      initialImageUrl: option.imageUrl,
                      onImageSelected: (url) => _updateOptionImageUrl(index, url),
                      onImageRemoved: () => _updateOptionImageUrl(index, null),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // Add option button
        TextButton.icon(
          onPressed: _addOption,
          icon: const Icon(Icons.add),
          label: const Text('Thêm mục'),
        ),

        const SizedBox(height: 16),

        // Correct sequence section
        if (_options.isNotEmpty)
          Column(
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

              // Reorderable list for sequence
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final item = _correctSequence.removeAt(oldIndex);
                    _correctSequence.insert(newIndex, item);
                  });
                },
                children: _correctSequence.map((optionId) {
                  final option = _options.firstWhere(
                    (o) => o.id == optionId,
                    orElse: () => const AnswerOption(id: '', text: 'Unknown'),
                  );

                  return ListTile(
                    key: Key(optionId),
                    leading: const Icon(Icons.drag_handle),
                    title: Text(option.text),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _correctSequence.remove(optionId);
                        });
                      },
                    ),
                  );
                }).toList(),
              ),

              // Available options to add to sequence
              const SizedBox(height: 8),
              const Text('Thêm vào thứ tự:'),
              Wrap(
                spacing: 8,
                children: _options
                    .where((option) => !_correctSequence.contains(option.id))
                    .map((option) {
                  return ActionChip(
                    label: Text(option.text),
                    onPressed: () {
                      setState(() {
                        _correctSequence.add(option.id);
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildPairingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column items
        const Text(
          'Cột bên trái:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _leftOptions.length,
          itemBuilder: (context, index) {
            final option = _leftOptions[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Option ID
                        CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            option.id,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Option text field
                        Expanded(
                          child: TextFormField(
                            initialValue: option.text,
                            decoration: const InputDecoration(
                              labelText: 'Nội dung',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập nội dung';
                              }
                              return null;
                            },
                            onChanged: (value) => _updatePairingOptionText(index, value, true),
                          ),
                        ),

                        // Remove button
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removePairingOption(index, true),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Image Picker
                    const Text(
                      'Hình ảnh (không bắt buộc)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    ImagePickerWidget(
                      initialImageUrl: option.imageUrl,
                      onImageSelected: (url) => _updatePairingOptionImageUrl(index, url, true),
                      onImageRemoved: () => _updatePairingOptionImageUrl(index, null, true),
                    ),

                    // Pair selection dropdown
                    if (_rightOptions.isNotEmpty)
                      DropdownButtonFormField<String>(
                        value: _correctPairs[option.id],
                        decoration: const InputDecoration(
                          labelText: 'Ghép với',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.compare_arrows),
                        ),
                        items: _rightOptions.map((rightOption) {
                          return DropdownMenuItem<String>(
                            value: rightOption.id,
                            child: Text(rightOption.text.isEmpty ? rightOption.id : rightOption.text),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            _updateCorrectPair(option.id, value);
                          }
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        ),

        // Add left option button
        TextButton.icon(
          onPressed: () => _addPairingOption(true),
          icon: const Icon(Icons.add),
          label: const Text('Thêm mục bên trái'),
        ),

        const SizedBox(height: 24),

        // Right column items
        const Text(
          'Cột bên phải:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _rightOptions.length,
          itemBuilder: (context, index) {
            final option = _rightOptions[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Option ID
                        CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Text(
                            option.id,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Option text field
                        Expanded(
                          child: TextFormField(
                            initialValue: option.text,
                            decoration: const InputDecoration(
                              labelText: 'Nội dung',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập nội dung';
                              }
                              return null;
                            },
                            onChanged: (value) => _updatePairingOptionText(index, value, false),
                          ),
                        ),

                        // Remove button
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removePairingOption(index, false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Image Picker
                    const Text(
                      'Hình ảnh (không bắt buộc)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    ImagePickerWidget(
                      initialImageUrl: option.imageUrl,
                      onImageSelected: (url) => _updatePairingOptionImageUrl(index, url, false),
                      onImageRemoved: () => _updatePairingOptionImageUrl(index, null, false),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // Add right option button
        TextButton.icon(
          onPressed: () => _addPairingOption(false),
          icon: const Icon(Icons.add),
          label: const Text('Thêm mục bên phải'),
        ),

        // Validation message for pairs
        if (_leftOptions.isNotEmpty && _rightOptions.isNotEmpty &&
            _leftOptions.any((option) => !_correctPairs.containsKey(option.id)))
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              'Vui lòng ghép đôi tất cả các mục bên trái',
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }
}

extension AnswerOptionExtension on AnswerOption {
  AnswerOption copyWith({
    String? id,
    String? text,
    String? imageUrl,
  }) {
    return AnswerOption(
      id: id ?? this.id,
      text: text ?? this.text,
      imageUrl: imageUrl, // Allow null to be passed explicitly
    );
  }
}
