import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../config/layou_auth_config.dart';
import '../exceptions/auth_exceptions.dart';
import 'auth_result.dart';
import 'auth_user.dart';

/// Core authentication service
///
/// Handles all Firebase Auth operations including sign-in, linking, and sign-out.
class AuthService {
  final LayouAuthConfig _config;
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthService({
    required LayouAuthConfig config,
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _config = config,
        _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? _createGoogleSignIn(config);

  static GoogleSignIn _createGoogleSignIn(LayouAuthConfig config) {
    final googleConfig = config.google;
    return GoogleSignIn(
      clientId: googleConfig?.iosClientId,
      serverClientId: googleConfig?.serverClientId,
      scopes: googleConfig?.scopes ?? ['email'],
    );
  }

  // ===========================================================================
  // AUTH STATE
  // ===========================================================================

  /// Stream of auth state changes
  Stream<AuthUser?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map(_mapFirebaseUser);
  }

  /// Get current user synchronously
  AuthUser? get currentUser {
    return _mapFirebaseUser(_firebaseAuth.currentUser);
  }

  /// Get current user UID
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  /// Check if current user is anonymous
  bool get isAnonymous => _firebaseAuth.currentUser?.isAnonymous ?? true;

  /// Get list of linked provider IDs
  List<String> get linkedProviders {
    final user = _firebaseAuth.currentUser;
    if (user == null) return [];
    return user.providerData.map((p) => p.providerId).toList();
  }

  // ===========================================================================
  // SIGN IN
  // ===========================================================================

  /// Sign in anonymously
  Future<AuthResult<AuthUser>> signInAnonymously() async {
    try {
      final credential = await _firebaseAuth.signInAnonymously();
      final user = _mapFirebaseUser(credential.user);
      if (user == null) {
        return const AuthResult.error(SignInFailedException('User is null'));
      }
      await _config.onSignedIn?.call(user, AuthMethod.anonymous);
      return AuthResult.success(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      final error = _mapFirebaseError(e);
      _config.onError?.call(error);
      return AuthResult.error(error);
    } catch (e) {
      final error = UnknownAuthException(e.toString(), e);
      _config.onError?.call(error);
      return AuthResult.error(error);
    }
  }

  /// Sign in with Google
  Future<AuthResult<AuthUser>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const AuthResult.error(UserCancelledException());
      }

      final googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final user = _mapFirebaseUser(userCredential.user);
      if (user == null) {
        return const AuthResult.error(SignInFailedException('User is null'));
      }
      await _config.onSignedIn?.call(user, AuthMethod.google);
      return AuthResult.success(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      final error = _mapSignInError(e);
      _config.onError?.call(error);
      return AuthResult.error(error);
    } catch (e) {
      if (_isUserCancellation(e)) {
        return const AuthResult.error(UserCancelledException());
      }
      final error = UnknownAuthException(e.toString(), e);
      _config.onError?.call(error);
      return AuthResult.error(error);
    }
  }

  /// Sign in with Apple
  Future<AuthResult<AuthUser>> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleConfig = _config.apple;
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: appleConfig?.scopes ?? [AppleIDAuthorizationScopes.email],
        nonce: nonce,
      );

      final oauthCredential =
          firebase_auth.OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(oauthCredential);
      final user = _mapFirebaseUser(userCredential.user);
      if (user == null) {
        return const AuthResult.error(SignInFailedException('User is null'));
      }
      await _config.onSignedIn?.call(user, AuthMethod.apple);
      return AuthResult.success(user);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return const AuthResult.error(UserCancelledException());
      }
      final error = SignInFailedException(e.message);
      _config.onError?.call(error);
      return AuthResult.error(error);
    } on firebase_auth.FirebaseAuthException catch (e) {
      final error = _mapSignInError(e);
      _config.onError?.call(error);
      return AuthResult.error(error);
    } catch (e) {
      final error = UnknownAuthException(e.toString(), e);
      _config.onError?.call(error);
      return AuthResult.error(error);
    }
  }

  /// Sign in with email and password
  Future<AuthResult<AuthUser>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = _mapFirebaseUser(userCredential.user);
      if (user == null) {
        return const AuthResult.error(SignInFailedException('User is null'));
      }
      await _config.onSignedIn?.call(user, AuthMethod.email);
      return AuthResult.success(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      final error = _mapSignInError(e);
      _config.onError?.call(error);
      return AuthResult.error(error);
    } catch (e) {
      final error = UnknownAuthException(e.toString(), e);
      _config.onError?.call(error);
      return AuthResult.error(error);
    }
  }

  // ===========================================================================
  // ACCOUNT LINKING
  // ===========================================================================

  /// Link current anonymous account with Google
  Future<AuthResult<AuthUser>> linkWithGoogle() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        return const AuthResult.error(NoUserException());
      }

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const AuthResult.error(UserCancelledException());
      }

      final googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await firebaseUser.linkWithCredential(credential);
      final user = _mapFirebaseUser(userCredential.user);
      if (user == null) {
        return const AuthResult.error(LinkingFailedException('User is null'));
      }
      await _config.onAccountLinked?.call(user, AuthMethod.google);
      return AuthResult.success(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      final error = _mapLinkingError(e);
      _config.onError?.call(error);
      return AuthResult.error(error);
    } catch (e) {
      if (_isUserCancellation(e)) {
        return const AuthResult.error(UserCancelledException());
      }
      final error = UnknownAuthException(e.toString(), e);
      _config.onError?.call(error);
      return AuthResult.error(error);
    }
  }

  /// Link current anonymous account with Apple
  Future<AuthResult<AuthUser>> linkWithApple() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        return const AuthResult.error(NoUserException());
      }

      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleConfig = _config.apple;
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: appleConfig?.scopes ?? [AppleIDAuthorizationScopes.email],
        nonce: nonce,
      );

      final oauthCredential =
          firebase_auth.OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      final userCredential =
          await firebaseUser.linkWithCredential(oauthCredential);

      // Update display name if Apple provided it
      final displayName = [
        appleCredential.givenName,
        appleCredential.familyName,
      ].where((s) => s != null && s.isNotEmpty).join(' ');

      if (displayName.isNotEmpty) {
        await userCredential.user?.updateDisplayName(displayName);
      }

      final user = _mapFirebaseUser(userCredential.user);
      if (user == null) {
        return const AuthResult.error(LinkingFailedException('User is null'));
      }
      await _config.onAccountLinked?.call(user, AuthMethod.apple);
      return AuthResult.success(user);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return const AuthResult.error(UserCancelledException());
      }
      final error = LinkingFailedException(e.message);
      _config.onError?.call(error);
      return AuthResult.error(error);
    } on firebase_auth.FirebaseAuthException catch (e) {
      final error = _mapLinkingError(e);
      _config.onError?.call(error);
      return AuthResult.error(error);
    } catch (e) {
      final error = UnknownAuthException(e.toString(), e);
      _config.onError?.call(error);
      return AuthResult.error(error);
    }
  }

  /// Link current anonymous account with email and password
  Future<AuthResult<AuthUser>> linkWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        return const AuthResult.error(NoUserException());
      }

      final credential = firebase_auth.EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      final userCredential = await firebaseUser.linkWithCredential(credential);
      final user = _mapFirebaseUser(userCredential.user);
      if (user == null) {
        return const AuthResult.error(LinkingFailedException('User is null'));
      }
      await _config.onAccountLinked?.call(user, AuthMethod.email);
      return AuthResult.success(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      final error = _mapLinkingError(e);
      _config.onError?.call(error);
      return AuthResult.error(error);
    } catch (e) {
      final error = UnknownAuthException(e.toString(), e);
      _config.onError?.call(error);
      return AuthResult.error(error);
    }
  }

  // ===========================================================================
  // REAUTHENTICATION
  // ===========================================================================

  /// Reauthenticate with email and password
  Future<AuthResult<void>> reauthenticateWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const AuthResult.error(NoUserException());
      }

      final credential = firebase_auth.EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      return const AuthResult.success(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      final error = _mapSignInError(e);
      _config.onError?.call(error);
      return AuthResult.error(error);
    } catch (e) {
      final error = UnknownAuthException(e.toString(), e);
      _config.onError?.call(error);
      return AuthResult.error(error);
    }
  }

  /// Reauthenticate with Google
  Future<AuthResult<void>> reauthenticateWithGoogle() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const AuthResult.error(NoUserException());
      }

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const AuthResult.error(UserCancelledException());
      }

      final googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await user.reauthenticateWithCredential(credential);
      return const AuthResult.success(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      final error = _mapSignInError(e);
      _config.onError?.call(error);
      return AuthResult.error(error);
    } catch (e) {
      if (_isUserCancellation(e)) {
        return const AuthResult.error(UserCancelledException());
      }
      final error = UnknownAuthException(e.toString(), e);
      _config.onError?.call(error);
      return AuthResult.error(error);
    }
  }

  /// Reauthenticate with Apple
  Future<AuthResult<void>> reauthenticateWithApple() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const AuthResult.error(NoUserException());
      }

      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleConfig = _config.apple;
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: appleConfig?.scopes ?? [AppleIDAuthorizationScopes.email],
        nonce: nonce,
      );

      final oauthCredential =
          firebase_auth.OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      await user.reauthenticateWithCredential(oauthCredential);
      return const AuthResult.success(null);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return const AuthResult.error(UserCancelledException());
      }
      final error = SignInFailedException(e.message);
      _config.onError?.call(error);
      return AuthResult.error(error);
    } on firebase_auth.FirebaseAuthException catch (e) {
      final error = _mapSignInError(e);
      _config.onError?.call(error);
      return AuthResult.error(error);
    } catch (e) {
      final error = UnknownAuthException(e.toString(), e);
      _config.onError?.call(error);
      return AuthResult.error(error);
    }
  }

  // ===========================================================================
  // SIGN OUT & DELETE
  // ===========================================================================

  /// Sign out current user
  ///
  /// Optional callbacks:
  /// - [onBeforeLogout]: Called before signing out (e.g., for cleanup or navigation)
  /// - [onAfterLogout]: Called after successful sign out (e.g., for analytics or navigation)
  ///
  /// Callbacks are wrapped in try-catch to prevent blocking the logout flow.
  Future<AuthResult<void>> signOut({
    Future<void> Function()? onBeforeLogout,
    Future<void> Function()? onAfterLogout,
  }) async {
    try {
      // Execute onBeforeLogout callback if provided
      if (onBeforeLogout != null) {
        try {
          await onBeforeLogout();
        } catch (e) {
          // Log but don't block logout
          // ignore: avoid_print
          print('onBeforeLogout callback failed: $e');
        }
      }

      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      await _config.onSignedOut?.call();

      // Execute onAfterLogout callback if provided
      if (onAfterLogout != null) {
        try {
          await onAfterLogout();
        } catch (e) {
          // Log but don't affect the result
          // ignore: avoid_print
          print('onAfterLogout callback failed: $e');
        }
      }

      return const AuthResult.success(null);
    } catch (e) {
      final error = UnknownAuthException(e.toString(), e);
      _config.onError?.call(error);
      return AuthResult.error(error);
    }
  }

  /// Delete current user
  ///
  /// Optional callbacks:
  /// - [onBeforeDelete]: Called before deleting the account (e.g., for custom cleanup)
  /// - [onAfterDelete]: Called after successful deletion (e.g., for analytics or navigation)
  ///
  /// Callbacks are wrapped in try-catch to prevent blocking the deletion flow.
  /// Note: Reauthentication is handled at the UI layer, not here.
  Future<AuthResult<void>> deleteUser({
    Future<void> Function()? onBeforeDelete,
    Future<void> Function()? onAfterDelete,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const AuthResult.error(NoUserException());
      }

      // Execute onBeforeDelete callback if provided
      if (onBeforeDelete != null) {
        try {
          await onBeforeDelete();
        } catch (e) {
          // Log but don't block deletion
          // ignore: avoid_print
          print('onBeforeDelete callback failed: $e');
        }
      }

      final uid = user.uid;
      await user.delete();
      await _config.onUserDeleted?.call(uid);

      // Execute onAfterDelete callback if provided
      if (onAfterDelete != null) {
        try {
          await onAfterDelete();
        } catch (e) {
          // Log but don't affect the result
          // ignore: avoid_print
          print('onAfterDelete callback failed: $e');
        }
      }

      return const AuthResult.success(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      final error = _mapFirebaseError(e);
      _config.onError?.call(error);
      return AuthResult.error(error);
    } catch (e) {
      final error = UnknownAuthException(e.toString(), e);
      _config.onError?.call(error);
      return AuthResult.error(error);
    }
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  AuthUser? _mapFirebaseUser(firebase_auth.User? user) {
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      isAnonymous: user.isAnonymous,
      providerIds: user.providerData.map((p) => p.providerId).toList(),
      createdAt: user.metadata.creationTime,
    );
  }

  AuthException _mapFirebaseError(firebase_auth.FirebaseAuthException e) {
    return switch (e.code) {
      'network-request-failed' => const NetworkException(),
      'user-disabled' => const UserDisabledException(),
      'requires-recent-login' => const RequiresRecentLoginException(),
      _ => UnknownAuthException(e.message, e),
    };
  }

  AuthException _mapSignInError(firebase_auth.FirebaseAuthException e) {
    return switch (e.code) {
      'user-not-found' => const UserNotFoundException(),
      'wrong-password' || 'invalid-credential' => const WrongPasswordException(),
      'invalid-email' => const InvalidEmailException(),
      'user-disabled' => const UserDisabledException(),
      'network-request-failed' => const NetworkException(),
      _ => SignInFailedException(e.message),
    };
  }

  AuthException _mapLinkingError(firebase_auth.FirebaseAuthException e) {
    return switch (e.code) {
      'credential-already-in-use' => const CredentialAlreadyInUseException(),
      'email-already-in-use' => const EmailAlreadyInUseException(),
      'weak-password' => const WeakPasswordException(),
      'network-request-failed' => const NetworkException(),
      _ => LinkingFailedException(e.message),
    };
  }

  bool _isUserCancellation(Object e) {
    final str = e.toString().toLowerCase();
    return str.contains('cancelled') || str.contains('canceled');
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
