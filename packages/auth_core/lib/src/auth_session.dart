final class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.subjectId,
    required this.expiresAt,
  });

  final String accessToken;
  final String refreshToken;
  final String subjectId;
  final DateTime expiresAt;

  bool isExpiredAt(DateTime instant) => !expiresAt.isAfter(instant.toUtc());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthSession &&
          accessToken == other.accessToken &&
          refreshToken == other.refreshToken &&
          subjectId == other.subjectId &&
          expiresAt == other.expiresAt;

  @override
  int get hashCode =>
      Object.hash(accessToken, refreshToken, subjectId, expiresAt);
}
