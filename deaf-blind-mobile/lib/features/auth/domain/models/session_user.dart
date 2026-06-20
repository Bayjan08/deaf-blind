/// Authenticated user (student or teacher).
class SessionUser {
  SessionUser({required this.id, required this.role, required this.displayName});
  final int id;
  final String role;
  final String displayName;
}
