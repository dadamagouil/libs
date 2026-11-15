/// Authentication situation seen by the app.
///
/// [recovering]: the user arrives through the "forgot password" link and must choose a new password.
class AuthStatus {
  const AuthStatus({this.userId, this.recovering = false});

  final String? userId;
  final bool recovering;

  bool get signedIn => userId != null;

  // Equality by value: a mere token refresh must not reload the profile.
  @override
  bool operator ==(Object other) =>
      other is AuthStatus && other.userId == userId && other.recovering == recovering;

  @override
  int get hashCode => Object.hash(userId, recovering);
}
