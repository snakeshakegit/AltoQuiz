import 'package:flutter/material.dart';
import '../models/user_session.dart';
import '../models/quiz_models.dart';
import 'home_screen.dart';

class QuizResultScreen extends StatelessWidget {
  final AppUser user;
  final QuizParticipation participation;

  const QuizResultScreen({
    super.key,
    required this.user,
    required this.participation,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (participation.score / participation.totalQuestions * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      percentage >= 50
                          ? Icons.emoji_events
                          : Icons.sentiment_dissatisfied,
                      size: 72,
                      color: percentage >= 50 ? Colors.amber : Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      participation.quizTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Score: ${participation.score} / ${participation.totalQuestions} ($percentage%)',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Stats Breakdown
                    _buildStatRow(
                      Icons.format_list_numbered,
                      'Total Questions',
                      '${participation.totalQuestions}',
                      Colors.blue,
                    ),
                    _buildStatRow(
                      Icons.check_circle,
                      'Correct Answers',
                      '${participation.correctAnswers}',
                      Colors.green,
                    ),
                    _buildStatRow(
                      Icons.cancel,
                      'Incorrect Answers',
                      '${participation.incorrectAnswers}',
                      Colors.red,
                    ),
                    _buildStatRow(
                      Icons.help,
                      'Unanswered',
                      '${participation.unanswered}',
                      Colors.orange,
                    ),

                    const SizedBox(height: 28),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeScreen(user: user),
                          ),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Back to Home Screen',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
