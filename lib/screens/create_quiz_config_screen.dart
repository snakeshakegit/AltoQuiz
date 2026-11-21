import 'package:flutter/material.dart';
import '../models/user_session.dart';
import 'create_question_screen.dart';

class CreateQuizConfigScreen extends StatefulWidget {
  final AppUser user;

  const CreateQuizConfigScreen({
    super.key,
    required this.user,
  });

  @override
  State<CreateQuizConfigScreen> createState() => _CreateQuizConfigScreenState();
}

class _CreateQuizConfigScreenState extends State<CreateQuizConfigScreen> {
  final _formKey = GlobalKey<FormState>();

  String _title = '';
  int _durationMinutes = 10;
  int _totalQuestions = 5;

  void _proceedToQuestions() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateQuestionScreen(
          user: widget.user,
          title: _title,
          durationMinutes: _durationMinutes,
          totalQuestions: _totalQuestions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure Quiz'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Quiz Configuration',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Quiz Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a quiz title';
                  }
                  return null;
                },
                onSaved: (val) => _title = val?.trim() ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Quiz Duration (Minutes)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer),
                ),
                keyboardType: TextInputType.number,
                initialValue: '10',
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter duration';
                  }
                  final num = int.tryParse(val.trim());
                  if (num == null || num <= 0) {
                    return 'Duration must be a positive integer';
                  }
                  return null;
                },
                onSaved: (val) => _durationMinutes = int.parse(val!.trim()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Total Number of Questions',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                initialValue: '5',
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter total questions';
                  }
                  final num = int.tryParse(val.trim());
                  if (num == null || num <= 0) {
                    return 'Must be at least 1 question';
                  }
                  return null;
                },
                onSaved: (val) => _totalQuestions = int.parse(val!.trim()),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _proceedToQuestions,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Next: Create Questions',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
