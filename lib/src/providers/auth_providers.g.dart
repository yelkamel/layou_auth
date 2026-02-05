// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$layouAuthConfigHash() => r'e1a39d83d37724b1efdbd154862c3aac1424a96b';

/// Provides the LayouAuth config
///
/// Copied from [layouAuthConfig].
@ProviderFor(layouAuthConfig)
final layouAuthConfigProvider = Provider<LayouAuthConfig>.internal(
  layouAuthConfig,
  name: r'layouAuthConfigProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$layouAuthConfigHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LayouAuthConfigRef = ProviderRef<LayouAuthConfig>;
String _$layouAuthServiceHash() => r'e5b0f24c052cfa2aa63b4085f9733ed10acf3a32';

/// Provides the AuthService
///
/// Copied from [layouAuthService].
@ProviderFor(layouAuthService)
final layouAuthServiceProvider = Provider<AuthService>.internal(
  layouAuthService,
  name: r'layouAuthServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$layouAuthServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LayouAuthServiceRef = ProviderRef<AuthService>;
String _$layouAuthStateHash() => r'c81f3627ed5604afdc08e816b202dfcd5c4ded4c';

/// Stream of auth state changes
///
/// Copied from [layouAuthState].
@ProviderFor(layouAuthState)
final layouAuthStateProvider = StreamProvider<AuthUser?>.internal(
  layouAuthState,
  name: r'layouAuthStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$layouAuthStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LayouAuthStateRef = StreamProviderRef<AuthUser?>;
String _$layouCurrentUserHash() => r'0f5f8fd2170329ff6b883567688b98f5f5585848';

/// Current auth user (nullable)
///
/// Copied from [layouCurrentUser].
@ProviderFor(layouCurrentUser)
final layouCurrentUserProvider = AutoDisposeProvider<AuthUser?>.internal(
  layouCurrentUser,
  name: r'layouCurrentUserProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$layouCurrentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LayouCurrentUserRef = AutoDisposeProviderRef<AuthUser?>;
String _$layouIsAuthenticatedHash() =>
    r'bf0b21598cbf9ee43f3fae1a52e771b86ddd1186';

/// Whether user is authenticated
///
/// Copied from [layouIsAuthenticated].
@ProviderFor(layouIsAuthenticated)
final layouIsAuthenticatedProvider = AutoDisposeProvider<bool>.internal(
  layouIsAuthenticated,
  name: r'layouIsAuthenticatedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$layouIsAuthenticatedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LayouIsAuthenticatedRef = AutoDisposeProviderRef<bool>;
String _$layouIsAnonymousHash() => r'0309cfc6112a70a248c85d59e1337176c3e7138b';

/// Whether current user is anonymous
///
/// Copied from [layouIsAnonymous].
@ProviderFor(layouIsAnonymous)
final layouIsAnonymousProvider = AutoDisposeProvider<bool>.internal(
  layouIsAnonymous,
  name: r'layouIsAnonymousProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$layouIsAnonymousHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LayouIsAnonymousRef = AutoDisposeProviderRef<bool>;
String _$layouLinkedProvidersHash() =>
    r'af77b5ab7fada7f4d5ef8223162e162b3aa759b9';

/// List of linked provider IDs
///
/// Copied from [layouLinkedProviders].
@ProviderFor(layouLinkedProviders)
final layouLinkedProvidersProvider = AutoDisposeProvider<List<String>>.internal(
  layouLinkedProviders,
  name: r'layouLinkedProvidersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$layouLinkedProvidersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LayouLinkedProvidersRef = AutoDisposeProviderRef<List<String>>;
String _$layouHasGoogleHash() => r'df1392381c7256028d275ed09d70e30ef00b4b56';

/// Whether Google is linked
///
/// Copied from [layouHasGoogle].
@ProviderFor(layouHasGoogle)
final layouHasGoogleProvider = AutoDisposeProvider<bool>.internal(
  layouHasGoogle,
  name: r'layouHasGoogleProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$layouHasGoogleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LayouHasGoogleRef = AutoDisposeProviderRef<bool>;
String _$layouHasAppleHash() => r'b5931117a9dbee8018c99ee70c27f3bfd434cd03';

/// Whether Apple is linked
///
/// Copied from [layouHasApple].
@ProviderFor(layouHasApple)
final layouHasAppleProvider = AutoDisposeProvider<bool>.internal(
  layouHasApple,
  name: r'layouHasAppleProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$layouHasAppleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LayouHasAppleRef = AutoDisposeProviderRef<bool>;
String _$layouHasEmailHash() => r'18eaf4cc85643c14ffa831113972f849149c63db';

/// Whether Email is linked
///
/// Copied from [layouHasEmail].
@ProviderFor(layouHasEmail)
final layouHasEmailProvider = AutoDisposeProvider<bool>.internal(
  layouHasEmail,
  name: r'layouHasEmailProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$layouHasEmailHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LayouHasEmailRef = AutoDisposeProviderRef<bool>;
String _$layouAuthActionsHash() => r'68df0f4a2a1ea8711b356329bb94bf9a6a9966d9';

/// Auth actions notifier for sign-in/link/sign-out operations
///
/// Copied from [LayouAuthActions].
@ProviderFor(LayouAuthActions)
final layouAuthActionsProvider =
    AutoDisposeAsyncNotifierProvider<LayouAuthActions, void>.internal(
  LayouAuthActions.new,
  name: r'layouAuthActionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$layouAuthActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LayouAuthActions = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
