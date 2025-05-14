import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const CheckSampleDataApp());
}

class CheckSampleDataApp extends StatelessWidget {
  const CheckSampleDataApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kiểm tra dữ liệu mẫu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CheckSampleDataPage(),
    );
  }
}

class CheckSampleDataPage extends StatefulWidget {
  const CheckSampleDataPage({Key? key}) : super(key: key);

  @override
  State<CheckSampleDataPage> createState() => _CheckSampleDataPageState();
}

class _CheckSampleDataPageState extends State<CheckSampleDataPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  User? _currentUser;
  Map<String, int> _collectionCounts = {};
  bool _isLoading = false;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
    _countDocuments();
  }
  
  void _checkCurrentUser() {
    setState(() {
      _currentUser = _auth.currentUser;
    });
  }
  
  Future<void> _countDocuments() async {
    if (_currentUser == null) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final userId = _currentUser!.uid;
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
      
      final Map<String, int> counts = {};
      
      for (final collection in collections) {
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
            counts[collection] = 0;
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
        
        counts[collection] = querySnapshot.docs.length;
      }
      
      setState(() {
        _collectionCounts = counts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiểm tra dữ liệu mẫu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _countDocuments,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    'Error: $_errorMessage',
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : _currentUser == null
                  ? const Center(
                      child: Text('Vui lòng đăng nhập để kiểm tra dữ liệu'),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Thông tin người dùng',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Email: ${_currentUser!.email}'),
                                  Text('ID: ${_currentUser!.uid}'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Số lượng dữ liệu mẫu',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._collectionCounts.entries.map((entry) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(entry.key),
                                trailing: Text(
                                  '${entry.value}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                onTap: () => _viewCollectionDetails(entry.key),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
    );
  }
  
  Future<void> _viewCollectionDetails(String collection) async {
    if (_currentUser == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final userId = _currentUser!.uid;
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
          setState(() {
            _isLoading = false;
          });
          return;
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
      
      setState(() {
        _isLoading = false;
      });
      
      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Chi tiết $collection'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: querySnapshot.docs.length,
              itemBuilder: (context, index) {
                final doc = querySnapshot.docs[index];
                final data = doc.data() as Map<String, dynamic>;
                return ListTile(
                  title: Text(data['title'] ?? data['name'] ?? doc.id),
                  subtitle: Text('ID: ${doc.id}'),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
}
