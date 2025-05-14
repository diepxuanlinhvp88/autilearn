import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const DebugDataViewerApp());
}

class DebugDataViewerApp extends StatelessWidget {
  const DebugDataViewerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Debug Data Viewer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const DebugDataViewerPage(),
    );
  }
}

class DebugDataViewerPage extends StatefulWidget {
  const DebugDataViewerPage({Key? key}) : super(key: key);

  @override
  State<DebugDataViewerPage> createState() => _DebugDataViewerPageState();
}

class _DebugDataViewerPageState extends State<DebugDataViewerPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String _currentCollection = 'quizzes';
  List<Map<String, dynamic>> _documents = [];
  bool _isLoading = false;
  String _errorMessage = '';
  User? _currentUser;
  
  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
    _loadData();
  }
  
  void _checkCurrentUser() {
    setState(() {
      _currentUser = _auth.currentUser;
    });
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final QuerySnapshot snapshot = await _firestore.collection(_currentCollection).get();
      
      setState(() {
        _documents = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            ...data,
          };
        }).toList();
        _isLoading = false;
      });
      
      print('Loaded ${_documents.length} documents from $_currentCollection');
      
      if (_documents.isNotEmpty) {
        print('First document: ${_documents.first}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      print('Error loading data: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Debug Data Viewer - $_currentCollection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Firebase Collections',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_currentUser != null)
                    Text(
                      'User: ${_currentUser!.email}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  if (_currentUser != null)
                    Text(
                      'ID: ${_currentUser!.uid}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            _buildCollectionTile('quizzes'),
            _buildCollectionTile('questions'),
            _buildCollectionTile('users'),
            _buildCollectionTile('user_progress'),
            _buildCollectionTile('badges'),
            _buildCollectionTile('user_badges'),
            _buildCollectionTile('rewards'),
            _buildCollectionTile('currency'),
            _buildCollectionTile('analytics'),
            _buildCollectionTile('skill_assessments'),
            _buildCollectionTile('schedules'),
            _buildCollectionTile('drawings'),
            _buildCollectionTile('drawing_templates'),
            _buildCollectionTile('teacher_student_links'),
          ],
        ),
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
              : _documents.isEmpty
                  ? const Center(
                      child: Text('No documents found in this collection'),
                    )
                  : ListView.builder(
                      itemCount: _documents.length,
                      itemBuilder: (context, index) {
                        final document = _documents[index];
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ExpansionTile(
                            title: Text(
                              document['title'] ?? document['name'] ?? document['id'] ?? 'No title',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text('ID: ${document['id']}'),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: document.entries
                                      .where((entry) => entry.key != 'id')
                                      .map((entry) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 120,
                                            child: Text(
                                              '${entry.key}:',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              _formatValue(entry.value),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              if (_currentCollection == 'quizzes')
                                ElevatedButton(
                                  onPressed: () => _loadQuestionsByQuizId(document['id']),
                                  child: const Text('View Questions'),
                                ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
  
  Widget _buildCollectionTile(String collectionName) {
    return ListTile(
      title: Text(collectionName),
      selected: _currentCollection == collectionName,
      onTap: () {
        setState(() {
          _currentCollection = collectionName;
        });
        Navigator.pop(context);
        _loadData();
      },
    );
  }
  
  Future<void> _loadQuestionsByQuizId(String quizId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('questions')
          .where('quizId', isEqualTo: quizId)
          .orderBy('order')
          .get();
      
      setState(() {
        _documents = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            ...data,
          };
        }).toList();
        _currentCollection = 'questions (for quiz $quizId)';
        _isLoading = false;
      });
      
      print('Loaded ${_documents.length} questions for quiz $quizId');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      print('Error loading questions: $e');
    }
  }
  
  String _formatValue(dynamic value) {
    if (value == null) {
      return 'null';
    } else if (value is Timestamp) {
      return value.toDate().toString();
    } else if (value is List) {
      return value.join(', ');
    } else if (value is Map) {
      return value.entries.map((e) => '${e.key}: ${e.value}').join(', ');
    } else {
      return value.toString();
    }
  }
}
