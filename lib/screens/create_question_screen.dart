import 'package:flutter/material.dart';
import '../models/user_session.dart';
import '../models/quiz_models.dart';
import '../services/firestore_service.dart';

class CreateQuestionScreen extends StatefulWidget {
  final AppUser user;
  final String title;
  final int durationMinutes;
  final int totalQuestions;

  const CreateQuestionScreen({
    super.key,
    required this.user,
    required this.title,
    required this.durationMinutes,
    required this.totalQuestions,
  });

  @override
  State<CreateQuestionScreen> createState() => _CreateQuestionScreenState();
}

class _CreateQuestionScreenState extends State<CreateQuestionScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();

  int _currentIndex = 1;
  final List<QuestionItem> _createdQuestions = [];

  final _questionController = TextEditingController();
  final _optionAController = TextEditingController();
  final _optionBController = TextEditingController();
  final _optionCController = TextEditingController();
  final _optionDController = TextEditingController();

  String _selectedCorrectAnswer = 'A';
  bool _isSaving = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _questionController.dispose();
    _optionAController.dispose();
    _optionBController.dispose();
    _optionCController.dispose();
    _optionDController.dispose();
    super.dispose();
  }

  bool _validateAndSaveCurrentQuestion() {
    if (!_formKey.currentState!.validate()) return false;

    final question = QuestionItem(
      id: '',
      questionText: _questionController.text.trim(),
      optionA: _optionAController.text.trim(),
      optionB: _optionBController.text.trim(),
      optionC: _optionCController.text.trim(),
      optionD: _optionDController.text.trim(),
      correctAnswer: _selectedCorrectAnswer,
    );

    _createdQuestions.add(question);
    return true;
  }

  void _clearInputs() {
    _questionController.clear();
    _optionAController.clear();
    _optionBController.clear();
    _optionCController.clear();
    _optionDController.clear();
    setState(() {
      _selectedCorrectAnswer = 'A';
      _errorMessage = '';
    });
  }

  void _nextQuestion() {
    if (_validateAndSaveCurrentQuestion()) {
      setState(() {
        _currentIndex++;
      });
      _clearInputs();
    }
  }

  Future<void> _finishQuiz() async {
    if (!_validateAndSaveCurrentQuestion()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = '';
    });

    try {
      final quizCode = await _firestoreService.saveQuiz(
        widget.title,
        widget.durationMinutes,
        widget.totalQuestions,
        widget.user.uid,
        _createdQuestions,
      );

      if (mounted) {
        _showSuccessDialog(quizCode);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save quiz: $e';
        _isSaving = false;
      });
    }
  }

  void _showSuccessDialog(String quizCode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Quiz Created!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Your quiz has been saved successfully.'),
            const SizedBox(height: 16),
            const Text(
              'Quiz Code:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SelectableText(
              quizCode,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Share this code with participants to join your quiz.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Exit question creation
              Navigator.of(context).pop(); // Exit config screen back to Home
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Return to Home'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLastQuestion = _currentIndex == widget.totalQuestions;

    return Scaffold(
      appBar: AppBar(
        title: Text('Question $_currentIndex of ${widget.totalQuestions}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress header
              LinearProgressIndicator(
                value: _currentIndex / widget.totalQuestions,
                backgroundColor: Colors.grey.shade200,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 16),
              Text(
                'Question $_currentIndex of ${widget.totalQuestions}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 16),

              if (_errorMessage.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red.shade800),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Question Text Field
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: 'Question Text',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.help_outline),
                ),
                maxLines: 2,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Question text is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              const Text(
                'Enter 4 Options & Select 1 Correct Answer:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),

              RadioGroup<String>(
                groupValue: _selectedCorrectAnswer,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCorrectAnswer = value);
                  }
                },
                child: Column(
                  children: [
                    _buildOptionRow('A', _optionAController),
                    const SizedBox(height: 10),
                    _buildOptionRow('B', _optionBController),
                    const SizedBox(height: 10),
                    _buildOptionRow('C', _optionCController),
                    const SizedBox(height: 10),
                    _buildOptionRow('D', _optionDController),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: isLastQuestion ? _finishQuiz : _nextQuestion,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor:
                            isLastQuestion ? Colors.green : Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        isLastQuestion ? 'Finish Quiz' : 'Next Question',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionRow(String label, TextEditingController controller) {
    return Row(
      children: [
        Radio<String>(
          value: label,
          activeColor: Colors.deepPurple,
        ),
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Option $label',
              border: const OutlineInputBorder(),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Option $label cannot be empty';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
