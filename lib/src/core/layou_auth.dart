import '../config/layou_auth_config.dart';
import 'auth_service.dart';

/// Main entry point for LayouAuth
///
/// Initialize this in your main.dart before runApp:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
///
///   LayouAuth.initialize(
///     config: LayouAuthConfig(
///       providers: [
///         GoogleProviderConfig(iosClientId: '...'),
///         AppleProviderConfig(),
///         EmailProviderConfig(),
///       ],
///     ),
///   );
///
///   runApp(ProviderScope(child: MyApp()));
/// }
/// ```
class LayouAuth {
  static LayouAuth? _instance;
  static bool _initialized = false;

  final LayouAuthConfig config;
  final AuthService service;

  LayouAuth._({
    required this.config,
    required this.service,
  });

  /// Initialize LayouAuth with configuration
  ///
  /// Must be called before using any auth features.
  /// Typically called in main.dart after Firebase.initializeApp().
  static void initialize({required LayouAuthConfig config}) {
    if (_initialized) {
      throw StateError(
        'LayouAuth is already initialized. '
        'Call LayouAuth.reset() first if you need to reinitialize.',
      );
    }

    final service = AuthService(config: config);

    _instance = LayouAuth._(
      config: config,
      service: service,
    );
    _initialized = true;

    // Setup auth state listener for callbacks
    service.authStateChanges().listen((user) {
      config.onAuthStateChanged?.call(user);
    });
  }

  /// Get the singleton instance
  ///
  /// Throws if not initialized.
  static LayouAuth get instance {
    if (!_initialized || _instance == null) {
      throw StateError(
        'LayouAuth is not initialized. '
        'Call LayouAuth.initialize() in your main.dart first.',
      );
    }
    return _instance!;
  }

  /// Check if LayouAuth is initialized
  static bool get isInitialized => _initialized;

  /// Reset LayouAuth (mainly for testing)
  static void reset() {
    _instance = null;
    _initialized = false;
  }

  /// Convenience getter for the auth service
  static AuthService get auth => instance.service;
}
