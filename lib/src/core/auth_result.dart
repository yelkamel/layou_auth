import '../exceptions/auth_exceptions.dart';

/// Result wrapper for auth operations
///
/// Provides a type-safe way to handle success/error cases.
sealed class AuthResult<T> {
  const AuthResult();

  /// Create a success result
  const factory AuthResult.success(T value) = AuthSuccess<T>;

  /// Create an error result
  const factory AuthResult.error(AuthException error) = AuthError<T>;

  /// Handle both cases
  R when<R>({
    required R Function(T value) success,
    required R Function(AuthException error) error,
  });

  /// Handle both cases with maybeWhen
  R maybeWhen<R>({
    R Function(T value)? success,
    R Function(AuthException error)? error,
    required R Function() orElse,
  });

  /// Map success value
  AuthResult<R> map<R>(R Function(T value) mapper);

  /// FlatMap success value
  AuthResult<R> flatMap<R>(AuthResult<R> Function(T value) mapper);

  /// Get success value or null
  T? get valueOrNull;

  /// Get error or null
  AuthException? get errorOrNull;

  /// Is this a success?
  bool get isSuccess;

  /// Is this an error?
  bool get isError;
}

/// Success result
class AuthSuccess<T> extends AuthResult<T> {
  final T value;

  const AuthSuccess(this.value);

  @override
  R when<R>({
    required R Function(T value) success,
    required R Function(AuthException error) error,
  }) {
    return success(value);
  }

  @override
  R maybeWhen<R>({
    R Function(T value)? success,
    R Function(AuthException error)? error,
    required R Function() orElse,
  }) {
    return success?.call(value) ?? orElse();
  }

  @override
  AuthResult<R> map<R>(R Function(T value) mapper) {
    return AuthResult.success(mapper(value));
  }

  @override
  AuthResult<R> flatMap<R>(AuthResult<R> Function(T value) mapper) {
    return mapper(value);
  }

  @override
  T? get valueOrNull => value;

  @override
  AuthException? get errorOrNull => null;

  @override
  bool get isSuccess => true;

  @override
  bool get isError => false;
}

/// Error result
class AuthError<T> extends AuthResult<T> {
  final AuthException error;

  const AuthError(this.error);

  @override
  R when<R>({
    required R Function(T value) success,
    required R Function(AuthException error) error,
  }) {
    return error(this.error);
  }

  @override
  R maybeWhen<R>({
    R Function(T value)? success,
    R Function(AuthException error)? error,
    required R Function() orElse,
  }) {
    return error?.call(this.error) ?? orElse();
  }

  @override
  AuthResult<R> map<R>(R Function(T value) mapper) {
    return AuthResult.error(error);
  }

  @override
  AuthResult<R> flatMap<R>(AuthResult<R> Function(T value) mapper) {
    return AuthResult.error(error);
  }

  @override
  T? get valueOrNull => null;

  @override
  AuthException? get errorOrNull => error;

  @override
  bool get isSuccess => false;

  @override
  bool get isError => true;
}
