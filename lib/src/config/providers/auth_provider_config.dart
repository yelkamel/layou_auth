import '../../exceptions/auth_exceptions.dart';

/// Base class for auth provider configuration
abstract class AuthProviderConfig {
  const AuthProviderConfig();

  /// The auth method this config represents
  AuthMethod get method;
}
