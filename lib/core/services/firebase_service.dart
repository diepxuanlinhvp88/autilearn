import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseFirestore get firestore => _firestore;

  FirebaseAuth get auth => _auth;

  // Collection references
  CollectionReference get users => _firestore.collection('users');
  CollectionReference get quizzes => _firestore.collection('quizzes');
  CollectionReference get questions => _firestore.collection('questions');
  CollectionReference get userProgress => _firestore.collection('user_progress');


}
