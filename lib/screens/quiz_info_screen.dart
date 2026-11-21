import 'package:flutter/material.dart';
import '../models/user_session.dart';
import '../models/quiz_models.dart';
import '../services/firestore_service.dart';
import 'quiz_play_screen.dart';

class QuizInfoScreen extends StatefulWidget {
  final AppUser user;
  final Quiz quiz;

  const QuizInfoScreen({
    super.key,
    required this.user,
    required this.quiz,
  });

  @override
  State<QuizInfoScreen> createState() => _QuizInfoScreenState();
}

class _QuizInfoScreenState extends State<QuizInfoScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _startQuiz() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final questions =
          await _firestoreService.getQuestionsForQuiz(widget.quiz.id);

      if (questions.isEmpty) {
        setState(() {
          _errorMessage = 'No questions found for this quiz.';
        });
        return;
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuizPlayScreen(
              user: widget.user,
              quiz: widget.quiz,
              questions: questions,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load quiz questions: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Overview'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
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
                    Text(
                      widget.quiz.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: const Icon(Icons.timer, color: Colors.deepPurple),
                      title: const Text('Duration'),
                      trailing: Text(
                        '${widget.quiz.durationMinutes} Minutes',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ListTile(
                      leading:
                          const Icon(Icons.format_list_numbered, color: Colors.deepPurple),
                      title: const Text('Total Questions'),
                      trailing: Text(
                        '${widget.quiz.totalQuestions}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.code, color: Colors.deepPurple),
                      title: const Text('Quiz Code'),
                      trailing: Text(
                        widget.quiz.quizCode,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_errorMessage.isNotEmpty) ...[
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                    ],

                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                            onPressed: _startQuiz,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Start Quiz'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
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
}
