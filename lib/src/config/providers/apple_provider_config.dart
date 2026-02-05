import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../exceptions/auth_exceptions.dart';
import 'auth_provider_config.dart';

/// Configuration for Apple Sign-In
class AppleProviderConfig extends AuthProviderConfig {
  /// Scopes to request from Apple
  final List<AppleIDAuthorizationScopes> scopes;

  const AppleProviderConfig({
    this.scopes = const [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
  });

  @override
  AuthMethod get method => AuthMethod.apple;
}
