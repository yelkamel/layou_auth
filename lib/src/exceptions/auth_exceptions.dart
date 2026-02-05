/// Base class for all auth exceptions
sealed class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, {this.code});

  @override
  String toString() => '$runtimeType: $message';
}

/// User cancelled the sign-in flow
class UserCancelledException extends AuthException {
  const UserCancelledException() : super('User cancelled sign-in');
}

/// No authenticated user found
class NoUserException extends AuthException {
  const NoUserException() : super('No authenticated user');
}

/// Sign-in failed
class SignInFailedException extends AuthException {
  const SignInFailedException([String? message])
      : super(message ?? 'Failed to sign in');
}

/// Account linking failed
class LinkingFailedException extends AuthException {
  const LinkingFailedException([String? message])
      : super(message ?? 'Failed to link account');
}

/// Credential is already linked to another account
class CredentialAlreadyInUseException extends AuthException {
  final String? email;
  final AuthMethod? method;

  const CredentialAlreadyInUseException({
    this.email,
    this.method,
  }) : super('This credential is already linked to another account');
}

/// Email is already in use
class EmailAlreadyInUseException extends AuthException {
  const EmailAlreadyInUseException()
      : super('This email is already in use');
}

/// Password is too weak
class WeakPasswordException extends AuthException {
  const WeakPasswordException() : super('Password is too weak');
}

/// Invalid email format
class InvalidEmailException extends AuthException {
  const InvalidEmailException() : super('Invalid email format');
}

/// User not found
class UserNotFoundException extends AuthException {
  const UserNotFoundException()
      : super('No account found with this email');
}

/// Wrong password
class WrongPasswordException extends AuthException {
  const WrongPasswordException() : super('Incorrect password');
}

/// User account is disabled
class UserDisabledException extends AuthException {
  const UserDisabledException() : super('This account has been disabled');
}

/// Network error
class NetworkException extends AuthException {
  const NetworkException([String? message])
      : super(message ?? 'Network error occurred');
}

/// Requires recent login (for sensitive operations)
class RequiresRecentLoginException extends AuthException {
  const RequiresRecentLoginException()
      : super('This operation requires recent authentication');
}

/// Unknown auth error
class UnknownAuthException extends AuthException {
  final Object? originalError;

  const UnknownAuthException([String? message, this.originalError])
      : super(message ?? 'An unknown error occurred');
}

/// Auth methods enum
enum AuthMethod {
  google,
  apple,
  email,
  anonymous,
}
