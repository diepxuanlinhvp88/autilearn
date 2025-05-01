import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseFirestore get firestore => _firestore;
  FirebaseStorage get storage => _storage;
  FirebaseAuth get auth => _auth;

  // Collection references
  CollectionReference get users => _firestore.collection('users');
  CollectionReference get quizzes => _firestore.collection('quizzes');
  CollectionReference get questions => _firestore.collection('questions');
  CollectionReference get userProgress => _firestore.collection('user_progress');

  // Storage references
  Reference get quizImages => _storage.ref().child('quiz_images');
  Reference get audioFiles => _storage.ref().child('audio_files');
}
