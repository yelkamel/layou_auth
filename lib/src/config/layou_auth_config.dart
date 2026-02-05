import '../core/auth_user.dart';
import '../exceptions/auth_exceptions.dart';
import 'providers/auth_provider_config.dart';
import 'providers/google_provider_config.dart';
import 'providers/apple_provider_config.dart';
import 'providers/email_provider_config.dart';

/// Main configuration for LayouAuth
class LayouAuthConfig {
  /// List of enabled auth providers
  final List<AuthProviderConfig> providers;

  /// Called when auth state changes
  final void Function(AuthUser? user)? onAuthStateChanged;

  /// Called on successful sign-in
  final Future<void> Function(AuthUser user, AuthMethod method)? onSignedIn;

  /// Called on successful account linking
  final Future<void> Function(AuthUser user, AuthMethod method)? onAccountLinked;

  /// Called on sign-out
  final Future<void> Function()? onSignedOut;

  /// Called on user deletion
  final Future<void> Function(String uid)? onUserDeleted;

  /// Called on any auth error
  final void Function(AuthException error)? onError;

  const LayouAuthConfig({
    required this.providers,
    this.onAuthStateChanged,
    this.onSignedIn,
    this.onAccountLinked,
    this.onSignedOut,
    this.onUserDeleted,
    this.onError,
  });

  /// Check if a provider is enabled
  bool hasProvider(AuthMethod method) {
    return providers.any((p) => p.method == method);
  }

  /// Get config for a specific provider
  T? getProvider<T extends AuthProviderConfig>() {
    for (final provider in providers) {
      if (provider is T) return provider;
    }
    return null;
  }

  /// Get Google provider config
  GoogleProviderConfig? get google => getProvider<GoogleProviderConfig>();

  /// Get Apple provider config
  AppleProviderConfig? get apple => getProvider<AppleProviderConfig>();

  /// Get Email provider config
  EmailProviderConfig? get email => getProvider<EmailProviderConfig>();

  /// Default config with all providers enabled
  factory LayouAuthConfig.defaults({
    String? googleIosClientId,
    String? googleWebClientId,
  }) {
    return LayouAuthConfig(
      providers: [
        GoogleProviderConfig(
          iosClientId: googleIosClientId,
          webClientId: googleWebClientId,
        ),
        const AppleProviderConfig(),
        const EmailProviderConfig(),
      ],
    );
  }
}
