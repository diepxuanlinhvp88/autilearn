import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'core/services/sample_data_service.dart';
import 'firebase_options.dart';

void main() async {
  // Đảm bảo Flutter binding được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Chạy ứng dụng
  runApp(const CreateSampleDataApp());
}

class CreateSampleDataApp extends StatelessWidget {
  const CreateSampleDataApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tạo dữ liệu mẫu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CreateSampleDataPage(),
    );
  }
}

class CreateSampleDataPage extends StatefulWidget {
  const CreateSampleDataPage({Key? key}) : super(key: key);

  @override
  State<CreateSampleDataPage> createState() => _CreateSampleDataPageState();
}

class _CreateSampleDataPageState extends State<CreateSampleDataPage> {
  final SampleDataService _sampleDataService = SampleDataService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = false;
  String _message = '';
  bool _isSuccess = false;
  User? _currentUser;
  
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
  
  Future<void> _createSampleData() async {
    if (_currentUser == null) {
      setState(() {
        _message = 'Vui lòng đăng nhập trước khi tạo dữ liệu mẫu';
        _isSuccess = false;
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _message = 'Đang tạo dữ liệu mẫu...';
      _isSuccess = false;
    });
    
    try {
      // Xóa dữ liệu cũ trước khi tạo mới
      await _clearExistingData();
      
      // Tạo dữ liệu mẫu mới
      await _sampleDataService.generateSampleData(_currentUser!.uid);
      
      setState(() {
        _isLoading = false;
        _message = 'Đã tạo dữ liệu mẫu thành công!';
        _isSuccess = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Lỗi khi tạo dữ liệu mẫu: $e';
        _isSuccess = false;
      });
    }
  }
  
  Future<void> _clearExistingData() async {
    final userId = _currentUser!.uid;
    
    // Danh sách các collections cần xóa dữ liệu
    final collections = [
      'quizzes',
      'questions',
      'user_progress',
      'user_badges',
      'rewards',
      'currency',
      'analytics',
      'skill_assessments',
      'schedules',
      'drawings',
      'teacher_student_links',
    ];
    
    // Xóa dữ liệu từ mỗi collection
    for (final collection in collections) {
      print('Đang xóa dữ liệu từ collection: $collection');
      
      QuerySnapshot querySnapshot;
      
      if (collection == 'quizzes') {
        querySnapshot = await _firestore
            .collection(collection)
            .where('creatorId', isEqualTo: userId)
            .get();
      } else if (collection == 'questions') {
        // Lấy tất cả quizIds của người dùng
        final quizSnapshot = await _firestore
            .collection('quizzes')
            .where('creatorId', isEqualTo: userId)
            .get();
        
        final quizIds = quizSnapshot.docs.map((doc) => doc.id).toList();
        
        if (quizIds.isEmpty) {
          print('Không có quiz nào để xóa questions');
          continue;
        }
        
        querySnapshot = await _firestore
            .collection(collection)
            .where('quizId', whereIn: quizIds)
            .get();
      } else {
        // Các collections khác thường có trường userId
        querySnapshot = await _firestore
            .collection(collection)
            .where('userId', isEqualTo: userId)
            .get();
      }
      
      // Xóa từng document
      final batch = _firestore.batch();
      var count = 0;
      
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
        count++;
        
        // Firestore chỉ cho phép tối đa 500 operations trong một batch
        if (count >= 400) {
          await batch.commit();
          print('Đã xóa $count documents từ $collection');
          count = 0;
        }
      }
      
      if (count > 0) {
        await batch.commit();
        print('Đã xóa $count documents từ $collection');
      }
      
      print('Hoàn thành xóa dữ liệu từ collection: $collection');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo dữ liệu mẫu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Tạo dữ liệu mẫu cho ứng dụng',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Dữ liệu mẫu bao gồm:\n'
              '- Bài học (quizzes) với nhiều loại khác nhau\n'
              '- Câu hỏi cho mỗi bài học\n'
              '- Dữ liệu tiến trình học tập\n'
              '- Huy hiệu và phần thưởng\n'
              '- Mẫu vẽ và bản vẽ\n'
              '- Liên kết giáo viên-học sinh',
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
              onPressed: _isLoading ? null : _createSampleData,
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
                      'Tạo dữ liệu mẫu',
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
