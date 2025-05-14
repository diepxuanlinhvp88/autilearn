import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  // Đảm bảo Flutter binding được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Chạy ứng dụng
  runApp(const CreateDrawingTemplatesApp());
}

class CreateDrawingTemplatesApp extends StatelessWidget {
  const CreateDrawingTemplatesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tạo mẫu tô màu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CreateDrawingTemplatesPage(),
    );
  }
}

class CreateDrawingTemplatesPage extends StatefulWidget {
  const CreateDrawingTemplatesPage({Key? key}) : super(key: key);

  @override
  State<CreateDrawingTemplatesPage> createState() => _CreateDrawingTemplatesPageState();
}

class _CreateDrawingTemplatesPageState extends State<CreateDrawingTemplatesPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = false;
  String _message = '';
  bool _isSuccess = false;
  User? _currentUser;
  
  // Danh sách mẫu tô màu
  final List<Map<String, dynamic>> _templates = [
    {
      'title': 'Con mèo',
      'description': 'Tô màu hình con mèo dễ thương',
      'imageUrl': 'https://i.imgur.com/JXK8H81.png',
      'outlineImageUrl': 'https://i.imgur.com/JXK8H81.png',
      'category': 'Động vật',
      'difficulty': 1,
      'isPublished': true,
    },
    {
      'title': 'Con chó',
      'description': 'Tô màu hình con chó đáng yêu',
      'imageUrl': 'https://i.imgur.com/8yA4Ety.png',
      'outlineImageUrl': 'https://i.imgur.com/8yA4Ety.png',
      'category': 'Động vật',
      'difficulty': 1,
      'isPublished': true,
    },
    {
      'title': 'Bông hoa',
      'description': 'Tô màu hình bông hoa xinh đẹp',
      'imageUrl': 'https://i.imgur.com/pKVJYf2.png',
      'outlineImageUrl': 'https://i.imgur.com/pKVJYf2.png',
      'category': 'Thực vật',
      'difficulty': 2,
      'isPublished': true,
    },
    {
      'title': 'Ngôi nhà',
      'description': 'Tô màu hình ngôi nhà nhỏ',
      'imageUrl': 'https://i.imgur.com/QFjYjZQ.png',
      'outlineImageUrl': 'https://i.imgur.com/QFjYjZQ.png',
      'category': 'Kiến trúc',
      'difficulty': 2,
      'isPublished': true,
    },
    {
      'title': 'Xe ô tô',
      'description': 'Tô màu hình chiếc xe ô tô',
      'imageUrl': 'https://i.imgur.com/8yA4Ety.png',
      'outlineImageUrl': 'https://i.imgur.com/8yA4Ety.png',
      'category': 'Phương tiện',
      'difficulty': 3,
      'isPublished': true,
    },
  ];
  
  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }
  
  void _checkCurrentUser() {
    setState(() {
      _currentUser = _auth.currentUser;
      if (_currentUser != null) {
        _message = 'Đã đăng nhập với người dùng: ${_currentUser!.email}';
      } else {
        _message = 'Không có người dùng nào đang đăng nhập. Vui lòng đăng nhập trước.';
      }
    });
  }
  
  Future<void> _createDrawingTemplates() async {
    if (_currentUser == null) {
      setState(() {
        _message = 'Vui lòng đăng nhập trước khi tạo mẫu tô màu';
        _isSuccess = false;
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _message = 'Đang tạo mẫu tô màu...';
      _isSuccess = false;
    });
    
    try {
      // Kiểm tra xem đã có mẫu tô màu nào chưa
      final existingTemplates = await _firestore.collection('drawing_templates').get();
      
      if (existingTemplates.docs.isNotEmpty) {
        setState(() {
          _isLoading = false;
          _message = 'Đã có ${existingTemplates.docs.length} mẫu tô màu trong cơ sở dữ liệu. Bạn có muốn tạo thêm không?';
          _isSuccess = true;
        });
        
        // Hiển thị dialog xác nhận
        final shouldContinue = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xác nhận'),
            content: Text('Đã có ${existingTemplates.docs.length} mẫu tô màu trong cơ sở dữ liệu. Bạn có muốn tạo thêm không?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Không'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Có'),
              ),
            ],
          ),
        ) ?? false;
        
        if (!shouldContinue) {
          return;
        }
      }
      
      // Tạo mẫu tô màu
      for (final template in _templates) {
        await _firestore.collection('drawing_templates').add({
          ...template,
          'creatorId': _currentUser!.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
      setState(() {
        _isLoading = false;
        _message = 'Đã tạo ${_templates.length} mẫu tô màu thành công!';
        _isSuccess = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Lỗi khi tạo mẫu tô màu: $e';
        _isSuccess = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo mẫu tô màu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Tạo mẫu tô màu cho ứng dụng',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Công cụ này sẽ tạo các mẫu tô màu mẫu cho tính năng "Tô màu theo mẫu" trong ứng dụng.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isSuccess ? Colors.green.shade100 : Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _message,
                style: TextStyle(
                  color: _isSuccess ? Colors.green.shade800 : Colors.blue.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _createDrawingTemplates,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text(
                      'Tạo mẫu tô màu',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Quay lại'),
            ),
          ],
        ),
      ),
    );
  }
}
