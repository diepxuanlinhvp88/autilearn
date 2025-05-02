import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/firebase_service.dart';
import '../../../main.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isDeleting = false;
  String _statusMessage = '';
  int _deletedQuizzes = 0;
  int _deletedQuestions = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản trị hệ thống'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Công cụ quản trị',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Xóa dữ liệu mẫu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Thao tác này sẽ xóa tất cả bài học và câu hỏi trong hệ thống. Hành động này không thể hoàn tác.',
                      style: TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    if (_isDeleting)
                      Column(
                        children: [
                          const LinearProgressIndicator(),
                          const SizedBox(height: 16),
                          Text('Đã xóa $_deletedQuizzes bài học và $_deletedQuestions câu hỏi'),
                        ],
                      )
                    else
                      ElevatedButton(
                        onPressed: () => _showDeleteConfirmation(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Xóa tất cả dữ liệu'),
                      ),
                    if (_statusMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          _statusMessage,
                          style: TextStyle(
                            color: _statusMessage.contains('thành công')
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa dữ liệu'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa TẤT CẢ bài học và câu hỏi? Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteAllData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa tất cả'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAllData() async {
    setState(() {
      _isDeleting = true;
      _statusMessage = 'Đang xóa dữ liệu...';
      _deletedQuizzes = 0;
      _deletedQuestions = 0;
    });

    try {
      // 1. Xóa tất cả câu hỏi
      final questionsSnapshot = await _firestore.collection('questions').get();
      
      // Xóa từng câu hỏi
      for (final doc in questionsSnapshot.docs) {
        await doc.reference.delete();
        setState(() {
          _deletedQuestions++;
        });
      }

      // 2. Xóa tất cả bài học
      final quizzesSnapshot = await _firestore.collection('quizzes').get();
      
      // Xóa từng bài học
      for (final doc in quizzesSnapshot.docs) {
        await doc.reference.delete();
        setState(() {
          _deletedQuizzes++;
        });
      }

      setState(() {
        _isDeleting = false;
        _statusMessage = 'Đã xóa thành công $_deletedQuizzes bài học và $_deletedQuestions câu hỏi';
      });
    } catch (e) {
      setState(() {
        _isDeleting = false;
        _statusMessage = 'Lỗi khi xóa dữ liệu: ${e.toString()}';
      });
    }
  }
}
