import 'quiz_models.dart';

/// Class representing the active user (either registered or guest)
class AppUser {
  final String uid;
  final String email;
  final String name;
  final bool isGuest;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    this.isGuest = false,
  });

  factory AppUser.guest() {
    return AppUser(
      uid: 'guest',
      email: '',
      name: 'Guest User',
      isGuest: true,
    );
  }
}

/// In-memory storage for guest session history.
/// Will reset when the app process is closed.
class GuestSessionData {
  static final List<QuizParticipation> guestParticipations = [];
}
