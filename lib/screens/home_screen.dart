import 'package:flutter/material.dart';
import '../models/user_session.dart';
import '../models/quiz_models.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'login_screen.dart';
import 'create_quiz_config_screen.dart';
import 'quiz_code_entry_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppUser user;

  const HomeScreen({
    super.key,
    required this.user,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _logout() async {
    if (!widget.user.isGuest) {
      await _authService.signOut();
    }
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = widget.user.isGuest;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alto Quizz'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Header Card
            Card(
              color: Colors.deepPurple.shade50,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      child: Icon(isGuest ? Icons.person_outline : Icons.person),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            isGuest ? 'Guest Session (Temporary)' : widget.user.email,
                            style: TextStyle(
                              color: isGuest ? Colors.orange.shade800 : Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Two Main Options
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizCodeEntryScreen(user: widget.user),
                        ),
                      ).then((_) => setState(() {}));
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Participate in Quiz'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isGuest
                        ? null // Disabled for guest users
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CreateQuizConfigScreen(user: widget.user),
                              ),
                            ).then((_) => setState(() {}));
                          },
                    icon: const Icon(Icons.add),
                    label: Text(
                      isGuest ? 'Create Quiz (Disabled)' : 'Create a Quiz',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: isGuest ? Colors.grey.shade300 : Colors.deepPurple,
                      foregroundColor: isGuest ? Colors.grey.shade600 : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Section 1: Created Quizzes
            const Text(
              'My Created Quizzes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            isGuest
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Guests cannot create quizzes.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : StreamBuilder<List<Quiz>>(
                    stream: _firestoreService.getUserCreatedQuizzes(widget.user.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final quizzes = snapshot.data ?? [];
                      if (quizzes.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('You have not created any quizzes yet.'),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: quizzes.length,
                        itemBuilder: (context, index) {
                          final quiz = quizzes[index];
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.quiz, color: Colors.deepPurple),
                              title: Text(quiz.title),
                              subtitle: Text(
                                'Code: ${quiz.quizCode} | Questions: ${quiz.totalQuestions} | Duration: ${quiz.durationMinutes}m',
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
            const SizedBox(height: 24),

            // Section 2: Attempted Quizzes History
            const Text(
              'Attempted Quizzes History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            isGuest
                ? _buildGuestHistoryList()
                : StreamBuilder<List<QuizParticipation>>(
                    stream: _firestoreService.getUserParticipations(widget.user.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final participations = snapshot.data ?? [];
                      if (participations.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('No attempted quizzes history found.'),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: participations.length,
                        itemBuilder: (context, index) {
                          final p = participations[index];
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.assignment_turned_in,
                                  color: Colors.green),
                              title: Text(p.quizTitle),
                              subtitle: Text(
                                'Score: ${p.score}/${p.totalQuestions} | Correct: ${p.correctAnswers} | Incorrect: ${p.incorrectAnswers} | Unanswered: ${p.unanswered}',
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestHistoryList() {
    final history = GuestSessionData.guestParticipations;
    if (history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('No attempted quizzes in this guest session.'),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final p = history[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.history, color: Colors.orange),
            title: Text(p.quizTitle),
            subtitle: Text(
              'Score: ${p.score}/${p.totalQuestions} | Correct: ${p.correctAnswers} | Incorrect: ${p.incorrectAnswers} | Unanswered: ${p.unanswered}',
            ),
          ),
        );
      },
    );
  }
}
