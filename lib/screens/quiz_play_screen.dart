import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_session.dart';
import '../models/quiz_models.dart';
import '../services/firestore_service.dart';
import 'quiz_result_screen.dart';

class QuizPlayScreen extends StatefulWidget {
  final AppUser user;
  final Quiz quiz;
  final List<QuestionItem> questions;

  const QuizPlayScreen({
    super.key,
    required this.user,
    required this.quiz,
    required this.questions,
  });

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  int _currentIndex = 0;
  // Store user answer selection per question index: index -> 'A', 'B', 'C', or 'D'
  final Map<int, String> _userAnswers = {};

  late Timer _timer;
  late int _secondsRemaining;
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.quiz.durationMinutes * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer.cancel();
        if (!_isSubmitted) {
          _autoSubmitDueToTimer();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTimer(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _autoSubmitDueToTimer() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Time is up! Submitting your quiz automatically...'),
        duration: Duration(seconds: 2),
      ),
    );
    _processSubmission();
  }

  void _confirmSubmit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Quiz?'),
        content: const Text(
          'Are you sure you want to submit your answers?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _processSubmission();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _processSubmission() async {
    if (_isSubmitted) return;
    _isSubmitted = true;
    _timer.cancel();

    int correct = 0;
    int incorrect = 0;
    int unanswered = 0;

    for (int i = 0; i < widget.questions.length; i++) {
      final selected = _userAnswers[i];
      if (selected == null || selected.isEmpty) {
        unanswered++;
      } else if (selected == widget.questions[i].correctAnswer) {
        correct++;
      } else {
        incorrect++;
      }
    }

    final total = widget.questions.length;
    final score = correct; // score out of total

    final participation = QuizParticipation(
      id: '',
      userId: widget.user.uid,
      quizId: widget.quiz.id,
      quizTitle: widget.quiz.title,
      score: score,
      totalQuestions: total,
      correctAnswers: correct,
      incorrectAnswers: incorrect,
      unanswered: unanswered,
      submittedAt: DateTime.now(),
    );

    // Save participation
    if (widget.user.isGuest) {
      GuestSessionData.guestParticipations.add(participation);
    } else {
      await _firestoreService.saveParticipation(participation);
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultScreen(
            user: widget.user,
            participation: participation,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_currentIndex];
    final totalQuestions = widget.questions.length;

    return PopScope(
      canPop: _isSubmitted,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || _isSubmitted) return;
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Quiz?'),
            content: const Text(
              'Your progress will be lost if you exit without submitting.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Stay'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        if (shouldPop == true && mounted) {
          Navigator.of(this.context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.quiz.title),
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _secondsRemaining < 60
                    ? Colors.red.shade100
                    : Colors.deepPurple.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer,
                    size: 18,
                    color: _secondsRemaining < 60 ? Colors.red : Colors.deepPurple,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTimer(_secondsRemaining),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _secondsRemaining < 60 ? Colors.red : Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Question Progress Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${_currentIndex + 1} of $totalQuestions',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  Text(
                    '${((_currentIndex + 1) / totalQuestions * 100).toInt()}%',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (_currentIndex + 1) / totalQuestions,
                backgroundColor: Colors.grey.shade200,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 24),

              // Question Text Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    question.questionText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              RadioGroup<String>(
                groupValue: _userAnswers[_currentIndex],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _userAnswers[_currentIndex] = value);
                  }
                },
                child: Column(
                  children: [
                    _buildOptionTile('A', question.optionA),
                    const SizedBox(height: 10),
                    _buildOptionTile('B', question.optionB),
                    const SizedBox(height: 10),
                    _buildOptionTile('C', question.optionC),
                    const SizedBox(height: 10),
                    _buildOptionTile('D', question.optionD),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Navigation Controls
              Row(
                children: [
                  if (_currentIndex > 0)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _currentIndex--;
                          });
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Previous'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    )
                  else
                    const Spacer(),
                  const SizedBox(width: 12),
                  if (_currentIndex < totalQuestions - 1)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _currentIndex++;
                          });
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Next'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _confirmSubmit,
                        icon: const Icon(Icons.check),
                        label: const Text('Submit Quiz'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile(String optionKey, String optionText) {
    final isSelected = _userAnswers[_currentIndex] == optionKey;

    return Card(
      color: isSelected ? Colors.deepPurple.shade50 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: RadioListTile<String>(
        value: optionKey,
        activeColor: Colors.deepPurple,
        title: Text(
          '$optionKey.  $optionText',
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.deepPurple : Colors.black87,
          ),
        ),
      ),
    );
  }
}
