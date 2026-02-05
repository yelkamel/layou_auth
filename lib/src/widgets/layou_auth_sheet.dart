import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/auth_result.dart';
import '../core/auth_user.dart';
import '../exceptions/auth_exceptions.dart';
import '../providers/auth_providers.dart';
import 'buttons/layou_apple_button.dart';
import 'buttons/layou_email_button.dart';
import 'buttons/layou_google_button.dart';
import 'forms/layou_email_form.dart';
import 'layou_credential_in_use_sheet.dart';
import 'theme/layou_auth_strings.dart';
import 'theme/layou_auth_theme.dart';

/// Auth mode for the sheet
enum LayouAuthMode {
  /// Sign in to existing account
  signIn,

  /// Link anonymous account to provider
  link,
}

/// State passed to custom builder
class LayouAuthSheetState {
  final bool isLoading;
  final String? loadingProvider;
  final AuthException? error;
  final bool hasGoogle;
  final bool hasApple;
  final bool hasEmail;

  const LayouAuthSheetState({
    this.isLoading = false,
    this.loadingProvider,
    this.error,
    this.hasGoogle = false,
    this.hasApple = false,
    this.hasEmail = false,
  });
}

/// Actions available to custom builder
class LayouAuthSheetActions {
  final Future<AuthResult<AuthUser>> Function() signInWithGoogle;
  final Future<AuthResult<AuthUser>> Function() signInWithApple;
  final Future<AuthResult<AuthUser>> Function(String email, String password)
      signInWithEmail;
  final Future<AuthResult<AuthUser>> Function() linkWithGoogle;
  final Future<AuthResult<AuthUser>> Function() linkWithApple;
  final Future<AuthResult<AuthUser>> Function(String email, String password)
      linkWithEmail;

  const LayouAuthSheetActions({
    required this.signInWithGoogle,
    required this.signInWithApple,
    required this.signInWithEmail,
    required this.linkWithGoogle,
    required this.linkWithApple,
    required this.linkWithEmail,
  });
}

/// Main auth bottom sheet widget
///
/// Can be used for both sign-in and account linking.
/// Supports full customization via builder or uses default template.
class LayouAuthSheet extends ConsumerStatefulWidget {
  /// Auth mode (signIn or link)
  final LayouAuthMode mode;

  /// Custom builder for full control over UI
  final Widget Function(
    BuildContext context,
    LayouAuthSheetState state,
    LayouAuthSheetActions actions,
  )? builder;

  /// Custom theme
  final LayouAuthTheme? theme;

  /// Custom strings
  final LayouAuthStrings? strings;

  /// Called on successful auth
  final void Function(AuthUser user, AuthMethod method)? onSuccess;

  /// Called on error
  final void Function(AuthException error)? onError;

  /// Whether to show Apple button (defaults to iOS/macOS only)
  final bool? showApple;

  /// Whether to show Google button
  final bool showGoogle;

  /// Whether to show Email button
  final bool showEmail;

  /// Custom title for credential-already-in-use sheet
  final String? credentialInUseTitle;

  /// Custom message for credential-already-in-use sheet (use {provider} placeholder)
  final String? credentialInUseMessage;

  /// Custom sign-in button text for credential-already-in-use sheet
  final String? credentialInUseSignInButton;

  /// Custom cancel button text for credential-already-in-use sheet
  final String? credentialInUseCancelButton;

  const LayouAuthSheet({
    super.key,
    this.mode = LayouAuthMode.link,
    this.builder,
    this.theme,
    this.strings,
    this.onSuccess,
    this.onError,
    this.showApple,
    this.showGoogle = true,
    this.showEmail = true,
    this.credentialInUseTitle,
    this.credentialInUseMessage,
    this.credentialInUseSignInButton,
    this.credentialInUseCancelButton,
  });

  /// Show as modal bottom sheet
  static Future<bool?> show(
    BuildContext context, {
    LayouAuthMode mode = LayouAuthMode.link,
    Widget Function(
      BuildContext context,
      LayouAuthSheetState state,
      LayouAuthSheetActions actions,
    )? builder,
    LayouAuthTheme? theme,
    LayouAuthStrings? strings,
    void Function(AuthUser user, AuthMethod method)? onSuccess,
    void Function(AuthException error)? onError,
    bool? showApple,
    bool showGoogle = true,
    bool showEmail = true,
    String? credentialInUseTitle,
    String? credentialInUseMessage,
    String? credentialInUseSignInButton,
    String? credentialInUseCancelButton,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LayouAuthSheet(
        mode: mode,
        builder: builder,
        theme: theme,
        strings: strings,
        onSuccess: onSuccess,
        onError: onError,
        showApple: showApple,
        showGoogle: showGoogle,
        showEmail: showEmail,
        credentialInUseTitle: credentialInUseTitle,
        credentialInUseMessage: credentialInUseMessage,
        credentialInUseSignInButton: credentialInUseSignInButton,
        credentialInUseCancelButton: credentialInUseCancelButton,
      ),
    );
  }

  @override
  ConsumerState<LayouAuthSheet> createState() => _LayouAuthSheetState();
}

class _LayouAuthSheetState extends ConsumerState<LayouAuthSheet> {
  bool _isLoading = false;
  String? _loadingProvider;
  AuthException? _error;
  bool _showEmailForm = false;

  LayouAuthStrings get _strings => widget.strings ?? const LayouAuthStrings();

  bool get _showAppleButton {
    if (widget.showApple != null) return widget.showApple!;
    return !kIsWeb && (Platform.isIOS || Platform.isMacOS);
  }

  Future<AuthResult<AuthUser>> _handleAuth(
    String provider,
    Future<AuthResult<AuthUser>> Function() action, {
    bool isLinkMode = false,
  }) async {
    setState(() {
      _isLoading = true;
      _loadingProvider = provider;
      _error = null;
    });

    final result = await action();

    if (!mounted) return result;

    await result.when(
      success: (user) {
        final method = switch (provider) {
          'google' => AuthMethod.google,
          'apple' => AuthMethod.apple,
          'email' => AuthMethod.email,
          _ => AuthMethod.anonymous,
        };
        widget.onSuccess?.call(user, method);
        Navigator.of(context).pop(true);
      },
      error: (error) async {
        // Handle credential-already-in-use in link mode
        if (isLinkMode && error is CredentialAlreadyInUseException) {
          final providerName = switch (provider) {
            'google' => 'Google',
            'apple' => 'Apple',
            'email' => 'Email',
            _ => 'account',
          };

          final shouldSignIn = await LayouCredentialInUseSheet.show(
            context,
            providerName: providerName,
            title: widget.credentialInUseTitle,
            message: widget.credentialInUseMessage,
            signInButtonText: widget.credentialInUseSignInButton,
            cancelButtonText: widget.credentialInUseCancelButton,
          );

          if (shouldSignIn && mounted) {
            // User wants to sign in instead - call the sign-in method
            switch (provider) {
              case 'google':
                await _signInWithGoogle();
                break;
              case 'apple':
                await _signInWithApple();
                break;
              // For email, we don't have the password here, so just show error
              default:
                if (error is! UserCancelledException) {
                  setState(() => _error = error);
                  widget.onError?.call(error);
                }
            }
            return; // Don't show error since we're trying sign-in
          }
        }

        // Normal error handling
        if (error is! UserCancelledException) {
          setState(() => _error = error);
          widget.onError?.call(error);
        }
      },
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        _loadingProvider = null;
      });
    }

    return result;
  }

  Future<AuthResult<AuthUser>> _signInWithGoogle() {
    return _handleAuth(
      'google',
      () => ref.read(layouAuthActionsProvider.notifier).signInWithGoogle(),
    );
  }

  Future<AuthResult<AuthUser>> _signInWithApple() {
    return _handleAuth(
      'apple',
      () => ref.read(layouAuthActionsProvider.notifier).signInWithApple(),
    );
  }

  Future<AuthResult<AuthUser>> _signInWithEmail(
      String email, String password,) {
    return _handleAuth(
      'email',
      () => ref
          .read(layouAuthActionsProvider.notifier)
          .signInWithEmail(email: email, password: password),
    );
  }

  Future<AuthResult<AuthUser>> _linkWithGoogle() {
    return _handleAuth(
      'google',
      () => ref.read(layouAuthActionsProvider.notifier).linkWithGoogle(),
      isLinkMode: true,
    );
  }

  Future<AuthResult<AuthUser>> _linkWithApple() {
    return _handleAuth(
      'apple',
      () => ref.read(layouAuthActionsProvider.notifier).linkWithApple(),
      isLinkMode: true,
    );
  }

  Future<AuthResult<AuthUser>> _linkWithEmail(String email, String password) {
    return _handleAuth(
      'email',
      () => ref
          .read(layouAuthActionsProvider.notifier)
          .linkWithEmail(email: email, password: password),
      isLinkMode: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasGoogle = ref.watch(layouHasGoogleProvider);
    final hasApple = ref.watch(layouHasAppleProvider);
    final hasEmail = ref.watch(layouHasEmailProvider);

    final state = LayouAuthSheetState(
      isLoading: _isLoading,
      loadingProvider: _loadingProvider,
      error: _error,
      hasGoogle: hasGoogle,
      hasApple: hasApple,
      hasEmail: hasEmail,
    );

    final actions = LayouAuthSheetActions(
      signInWithGoogle: _signInWithGoogle,
      signInWithApple: _signInWithApple,
      signInWithEmail: _signInWithEmail,
      linkWithGoogle: _linkWithGoogle,
      linkWithApple: _linkWithApple,
      linkWithEmail: _linkWithEmail,
    );

    // If builder provided, use it
    if (widget.builder != null) {
      return widget.builder!(context, state, actions);
    }

    // Default template
    return _buildDefaultSheet(context, state, actions, hasGoogle, hasApple, hasEmail);
  }

  Widget _buildDefaultSheet(
    BuildContext context,
    LayouAuthSheetState state,
    LayouAuthSheetActions actions,
    bool hasGoogle,
    bool hasApple,
    bool hasEmail,
  ) {
    final theme = widget.theme ?? LayouAuthTheme.fromContext(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isLinkMode = widget.mode == LayouAuthMode.link;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                isLinkMode ? _strings.linkAccountTitle : _strings.signInTitle,
                style: theme.titleStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                isLinkMode
                    ? _strings.linkAccountSubtitle
                    : _strings.signInSubtitle,
                style: theme.subtitleStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Error message
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: theme.errorDecoration,
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: colorScheme.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _strings.getErrorMessage(_error!),
                          style: theme.errorTextStyle,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Buttons or Email form
              if (!_showEmailForm) ...[
                // Google button
                if (widget.showGoogle)
                  LayouGoogleButton(
                    label: _strings.googleButton,
                    isLoading: _loadingProvider == 'google',
                    enabled: !_isLoading,
                    isLinked: isLinkMode && hasGoogle,
                    onPressed: () => isLinkMode
                        ? actions.linkWithGoogle()
                        : actions.signInWithGoogle(),
                  ),

                if (widget.showGoogle) SizedBox(height: theme.buttonSpacing),

                // Apple button
                if (_showAppleButton)
                  LayouAppleButton(
                    label: _strings.appleButton,
                    isLoading: _loadingProvider == 'apple',
                    enabled: !_isLoading,
                    isLinked: isLinkMode && hasApple,
                    onPressed: () => isLinkMode
                        ? actions.linkWithApple()
                        : actions.signInWithApple(),
                  ),

                if (_showAppleButton) SizedBox(height: theme.buttonSpacing),

                // Email button
                if (widget.showEmail)
                  LayouEmailButton(
                    label: _strings.emailButton,
                    isLoading: _loadingProvider == 'email',
                    enabled: !_isLoading,
                    isLinked: isLinkMode && hasEmail,
                    onPressed: () => setState(() => _showEmailForm = true),
                  ),
              ] else ...[
                // Email form
                LayouEmailForm(
                  strings: _strings,
                  showConfirmPassword: isLinkMode,
                  isLoading: _isLoading,
                  submitLabel: isLinkMode
                      ? _strings.linkAccountTitle
                      : _strings.signInTitle,
                  onSubmit: (email, password) async {
                    if (isLinkMode) {
                      await actions.linkWithEmail(email, password);
                    } else {
                      await actions.signInWithEmail(email, password);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed:
                      _isLoading ? null : () => setState(() => _showEmailForm = false),
                  child: Text(_strings.backButton),
                ),
              ],

              const SizedBox(height: 16),

              // Close button
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(_strings.closeButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
