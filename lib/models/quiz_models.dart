import 'package:cloud_firestore/cloud_firestore.dart';

class Quiz {
  final String id;
  final String title;
  final int durationMinutes;
  final int totalQuestions;
  final String quizCode;
  final String creatorId;
  final DateTime createdAt;

  Quiz({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.totalQuestions,
    required this.quizCode,
    required this.creatorId,
    required this.createdAt,
  });

  factory Quiz.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Quiz(
      id: doc.id,
      title: data['title'] ?? '',
      durationMinutes: data['durationMinutes'] ?? 10,
      totalQuestions: data['totalQuestions'] ?? 0,
      quizCode: data['quizCode'] ?? '',
      creatorId: data['creatorId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'durationMinutes': durationMinutes,
      'totalQuestions': totalQuestions,
      'quizCode': quizCode,
      'creatorId': creatorId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

class QuestionItem {
  final String id;
  final String questionText;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAnswer; // 'A', 'B', 'C', or 'D'

  QuestionItem({
    required this.id,
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
  });

  factory QuestionItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final options = data['options'] as Map<String, dynamic>? ?? {};
    return QuestionItem(
      id: doc.id,
      questionText: data['questionText'] ?? '',
      optionA: options['A'] ?? '',
      optionB: options['B'] ?? '',
      optionC: options['C'] ?? '',
      optionD: options['D'] ?? '',
      correctAnswer: data['correctAnswer'] ?? 'A',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionText': questionText,
      'options': {
        'A': optionA,
        'B': optionB,
        'C': optionC,
        'D': optionD,
      },
      'correctAnswer': correctAnswer,
    };
  }
}

class QuizParticipation {
  final String id;
  final String userId;
  final String quizId;
  final String quizTitle;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final int unanswered;
  final DateTime submittedAt;

  QuizParticipation({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.quizTitle,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.unanswered,
    required this.submittedAt,
  });

  factory QuizParticipation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return QuizParticipation(
      id: doc.id,
      userId: data['userId'] ?? '',
      quizId: data['quizId'] ?? '',
      quizTitle: data['quizTitle'] ?? '',
      score: data['score'] ?? 0,
      totalQuestions: data['totalQuestions'] ?? 0,
      correctAnswers: data['correctAnswers'] ?? 0,
      incorrectAnswers: data['incorrectAnswers'] ?? 0,
      unanswered: data['unanswered'] ?? 0,
      submittedAt: (data['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'quizId': quizId,
      'quizTitle': quizTitle,
      'score': score,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'incorrectAnswers': incorrectAnswers,
      'unanswered': unanswered,
      'submittedAt': FieldValue.serverTimestamp(),
    };
  }
}
