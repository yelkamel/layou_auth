import '../exceptions/auth_exceptions.dart';

/// Minimal user representation from Firebase Auth
///
/// This is NOT your app's User entity - it's just the auth data.
/// Map this to your own User entity in your app.
class AuthUser {
  /// Firebase Auth UID
  final String uid;

  /// User's email (may be null for anonymous users)
  final String? email;

  /// Display name from auth provider
  final String? displayName;

  /// Photo URL from auth provider
  final String? photoUrl;

  /// Whether this is an anonymous user
  final bool isAnonymous;

  /// List of linked provider IDs (e.g., 'google.com', 'apple.com', 'password')
  final List<String> providerIds;

  /// When the user was created
  final DateTime? createdAt;

  const AuthUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    required this.isAnonymous,
    this.providerIds = const [],
    this.createdAt,
  });

  /// Check if user has linked a specific provider
  bool hasProvider(AuthMethod method) {
    return switch (method) {
      AuthMethod.google => providerIds.contains('google.com'),
      AuthMethod.apple => providerIds.contains('apple.com'),
      AuthMethod.email => providerIds.contains('password'),
      AuthMethod.anonymous => isAnonymous && providerIds.isEmpty,
    };
  }

  /// Check if Google is linked
  bool get hasGoogle => hasProvider(AuthMethod.google);

  /// Check if Apple is linked
  bool get hasApple => hasProvider(AuthMethod.apple);

  /// Check if Email is linked
  bool get hasEmail => hasProvider(AuthMethod.email);

  /// Copy with new values
  AuthUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isAnonymous,
    List<String>? providerIds,
    DateTime? createdAt,
  }) {
    return AuthUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      providerIds: providerIds ?? this.providerIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthUser && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return 'AuthUser(uid: $uid, email: $email, isAnonymous: $isAnonymous, providers: $providerIds)';
  }
}
