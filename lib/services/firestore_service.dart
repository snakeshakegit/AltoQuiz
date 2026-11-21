import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz_models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save registered user profile to Firestore
  Future<void> saveUserProfile(String uid, String name, String email) async {
    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get registered user profile
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  // Generate unique 6-character uppercase quiz code
  Future<String> generateUniqueQuizCode() async {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    String code = '';
    bool isUnique = false;

    while (!isUnique) {
      code = String.fromCharCodes(
        Iterable.generate(
          6,
          (_) => chars.codeUnitAt(random.nextInt(chars.length)),
        ),
      );
      final query = await _db
          .collection('quizzes')
          .where('quizCode', isEqualTo: code)
          .get();

      if (query.docs.isEmpty) {
        isUnique = true;
      }
    }
    return code;
  }

  // Save Quiz and questions
  Future<String> saveQuiz(
    String title,
    int durationMinutes,
    int totalQuestions,
    String creatorId,
    List<QuestionItem> questions,
  ) async {
    final quizCode = await generateUniqueQuizCode();

    final quizRef = await _db.collection('quizzes').add({
      'title': title,
      'durationMinutes': durationMinutes,
      'totalQuestions': totalQuestions,
      'quizCode': quizCode,
      'creatorId': creatorId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final batch = _db.batch();
    for (final q in questions) {
      final questionRef = quizRef.collection('questions').doc();
      batch.set(questionRef, q.toMap());
    }
    await batch.commit();

    return quizCode;
  }

  // Find Quiz by 6-character Quiz Code
  Future<Quiz?> getQuizByCode(String code) async {
    final query = await _db
        .collection('quizzes')
        .where('quizCode', isEqualTo: code.trim().toUpperCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return Quiz.fromFirestore(query.docs.first);
  }

  // Get questions for a quiz
  Future<List<QuestionItem>> getQuestionsForQuiz(String quizId) async {
    final snapshot =
        await _db.collection('quizzes').doc(quizId).collection('questions').get();

    return snapshot.docs.map((doc) => QuestionItem.fromFirestore(doc)).toList();
  }

  // Get quizzes created by specific user
  Stream<List<Quiz>> getUserCreatedQuizzes(String userId) {
    return _db
        .collection('quizzes')
        .where('creatorId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Quiz.fromFirestore(doc)).toList());
  }

  // Save participation history for registered user
  Future<void> saveParticipation(QuizParticipation participation) async {
    await _db.collection('participation').add(participation.toMap());
  }

  // Get participation history for registered user
  Stream<List<QuizParticipation>> getUserParticipations(String userId) {
    return _db
        .collection('participation')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => QuizParticipation.fromFirestore(doc))
            .toList());
  }
}
