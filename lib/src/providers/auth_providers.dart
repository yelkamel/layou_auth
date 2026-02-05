import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/layou_auth_config.dart';
import '../core/auth_result.dart';
import '../core/auth_service.dart';
import '../core/auth_user.dart';
import '../core/layou_auth.dart';

part 'auth_providers.g.dart';

/// Provides the LayouAuth config
@Riverpod(keepAlive: true)
LayouAuthConfig layouAuthConfig(Ref ref) {
  return LayouAuth.instance.config;
}

/// Provides the AuthService
@Riverpod(keepAlive: true)
AuthService layouAuthService(Ref ref) {
  return LayouAuth.instance.service;
}

/// Stream of auth state changes
@Riverpod(keepAlive: true)
Stream<AuthUser?> layouAuthState(Ref ref) {
  final service = ref.watch(layouAuthServiceProvider);
  return service.authStateChanges();
}

/// Current auth user (nullable)
@riverpod
AuthUser? layouCurrentUser(Ref ref) {
  final authState = ref.watch(layouAuthStateProvider);
  return authState.valueOrNull;
}

/// Whether user is authenticated
@riverpod
bool layouIsAuthenticated(Ref ref) {
  final user = ref.watch(layouCurrentUserProvider);
  return user != null;
}

/// Whether current user is anonymous
@riverpod
bool layouIsAnonymous(Ref ref) {
  final user = ref.watch(layouCurrentUserProvider);
  return user?.isAnonymous ?? true;
}

/// List of linked provider IDs
@riverpod
List<String> layouLinkedProviders(Ref ref) {
  final user = ref.watch(layouCurrentUserProvider);
  return user?.providerIds ?? [];
}

/// Whether Google is linked
@riverpod
bool layouHasGoogle(Ref ref) {
  final providers = ref.watch(layouLinkedProvidersProvider);
  return providers.contains('google.com');
}

/// Whether Apple is linked
@riverpod
bool layouHasApple(Ref ref) {
  final providers = ref.watch(layouLinkedProvidersProvider);
  return providers.contains('apple.com');
}

/// Whether Email is linked
@riverpod
bool layouHasEmail(Ref ref) {
  final providers = ref.watch(layouLinkedProvidersProvider);
  return providers.contains('password');
}

/// Auth actions notifier for sign-in/link/sign-out operations
@riverpod
class LayouAuthActions extends _$LayouAuthActions {
  @override
  FutureOr<void> build() {}

  AuthService get _service => ref.read(layouAuthServiceProvider);

  /// Sign in anonymously
  Future<AuthResult<AuthUser>> signInAnonymously() async {
    state = const AsyncLoading();
    final result = await _service.signInAnonymously();
    state = result.when(
      success: (_) => const AsyncData(null),
      error: (e) => AsyncError(e, StackTrace.current),
    );
    return result;
  }

  /// Sign in with Google
  Future<AuthResult<AuthUser>> signInWithGoogle() async {
    state = const AsyncLoading();
    final result = await _service.signInWithGoogle();
    state = result.when(
      success: (_) => const AsyncData(null),
      error: (e) => AsyncError(e, StackTrace.current),
    );
    return result;
  }

  /// Sign in with Apple
  Future<AuthResult<AuthUser>> signInWithApple() async {
    state = const AsyncLoading();
    final result = await _service.signInWithApple();
    state = result.when(
      success: (_) => const AsyncData(null),
      error: (e) => AsyncError(e, StackTrace.current),
    );
    return result;
  }

  /// Sign in with email and password
  Future<AuthResult<AuthUser>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final result = await _service.signInWithEmail(
      email: email,
      password: password,
    );
    state = result.when(
      success: (_) => const AsyncData(null),
      error: (e) => AsyncError(e, StackTrace.current),
    );
    return result;
  }

  /// Link with Google
  Future<AuthResult<AuthUser>> linkWithGoogle() async {
    state = const AsyncLoading();
    final result = await _service.linkWithGoogle();
    state = result.when(
      success: (_) => const AsyncData(null),
      error: (e) => AsyncError(e, StackTrace.current),
    );
    return result;
  }

  /// Link with Apple
  Future<AuthResult<AuthUser>> linkWithApple() async {
    state = const AsyncLoading();
    final result = await _service.linkWithApple();
    state = result.when(
      success: (_) => const AsyncData(null),
      error: (e) => AsyncError(e, StackTrace.current),
    );
    return result;
  }

  /// Link with email and password
  Future<AuthResult<AuthUser>> linkWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final result = await _service.linkWithEmail(
      email: email,
      password: password,
    );
    state = result.when(
      success: (_) => const AsyncData(null),
      error: (e) => AsyncError(e, StackTrace.current),
    );
    return result;
  }

  /// Sign out
  Future<AuthResult<void>> signOut() async {
    state = const AsyncLoading();
    final result = await _service.signOut();
    state = result.when(
      success: (_) => const AsyncData(null),
      error: (e) => AsyncError(e, StackTrace.current),
    );
    return result;
  }

  /// Delete user
  Future<AuthResult<void>> deleteUser() async {
    state = const AsyncLoading();
    final result = await _service.deleteUser();
    state = result.when(
      success: (_) => const AsyncData(null),
      error: (e) => AsyncError(e, StackTrace.current),
    );
    return result;
  }
}
