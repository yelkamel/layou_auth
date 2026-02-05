import '../../exceptions/auth_exceptions.dart';
import 'auth_provider_config.dart';

/// Configuration for Google Sign-In
class GoogleProviderConfig extends AuthProviderConfig {
  /// iOS client ID from GoogleService-Info.plist
  /// Required for iOS/macOS
  final String? iosClientId;

  /// Web client ID from Firebase Console
  /// Required for web platform
  final String? webClientId;

  /// Server client ID for backend verification
  final String? serverClientId;

  /// Additional scopes to request
  final List<String> scopes;

  /// Force account selection even if only one account
  final bool forceAccountSelection;

  const GoogleProviderConfig({
    this.iosClientId,
    this.webClientId,
    this.serverClientId,
    this.scopes = const ['email'],
    this.forceAccountSelection = false,
  });

  @override
  AuthMethod get method => AuthMethod.google;
}
