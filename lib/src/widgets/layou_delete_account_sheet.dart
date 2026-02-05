import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/auth_result.dart';
import '../exceptions/auth_exceptions.dart';
import '../providers/auth_providers.dart';
import 'forms/layou_email_form.dart';
import 'theme/layou_auth_strings.dart';

/// Bottom sheet for account deletion with reauthentication support
class LayouDeleteAccountSheet extends ConsumerStatefulWidget {
  /// Custom strings
  final LayouAuthStrings? strings;

  /// Title of the sheet
  final String? title;

  /// Warning message
  final String? message;

  /// Delete button text
  final String? deleteButtonText;

  /// Cancel button text
  final String? cancelButtonText;

  /// Deleting message (shown during deletion)
  final String? deletingMessage;

  /// Success message
  final String? successMessage;

  /// Error message
  final String? errorMessage;

  /// Callback before deletion
  final Future<void> Function()? onBeforeDelete;

  /// Callback after successful deletion
  final Future<void> Function()? onAfterDelete;

  const LayouDeleteAccountSheet({
    super.key,
    this.strings,
    this.title,
    this.message,
    this.deleteButtonText,
    this.cancelButtonText,
    this.deletingMessage,
    this.successMessage,
    this.errorMessage,
    this.onBeforeDelete,
    this.onAfterDelete,
  });

  /// Show as modal bottom sheet
  static Future<bool?> show(
    BuildContext context, {
    LayouAuthStrings? strings,
    String? title,
    String? message,
    String? deleteButtonText,
    String? cancelButtonText,
    String? deletingMessage,
    String? successMessage,
    String? errorMessage,
    Future<void> Function()? onBeforeDelete,
    Future<void> Function()? onAfterDelete,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LayouDeleteAccountSheet(
        strings: strings,
        title: title,
        message: message,
        deleteButtonText: deleteButtonText,
        cancelButtonText: cancelButtonText,
        deletingMessage: deletingMessage,
        successMessage: successMessage,
        errorMessage: errorMessage,
        onBeforeDelete: onBeforeDelete,
        onAfterDelete: onAfterDelete,
      ),
    );
  }

  @override
  ConsumerState<LayouDeleteAccountSheet> createState() =>
      _LayouDeleteAccountSheetState();
}

class _LayouDeleteAccountSheetState
    extends ConsumerState<LayouDeleteAccountSheet> {
  bool _isDeleting = false;
  bool _showReauthForm = false;
  String? _reauthProvider;

  LayouAuthStrings get _strings => widget.strings ?? const LayouAuthStrings();

  String get _title => widget.title ?? 'Delete Account';
  String get _message =>
      widget.message ??
      'Are you sure you want to delete your account? This action cannot be undone.';
  String get _deleteButtonText => widget.deleteButtonText ?? 'Delete Account';
  String get _cancelButtonText => widget.cancelButtonText ?? 'Cancel';
  String get _successMessage =>
      widget.successMessage ?? 'Account deleted successfully';
  String get _errorMessage =>
      widget.errorMessage ?? 'Failed to delete account';

  bool get _showAppleButton {
    return !kIsWeb && (Platform.isIOS || Platform.isMacOS);
  }

  Future<void> _deleteAccount() async {
    setState(() {
      _isDeleting = true;
    });

    final service = ref.read(layouAuthServiceProvider);
    final result = await service.deleteUser(
      onBeforeDelete: widget.onBeforeDelete,
      onAfterDelete: widget.onAfterDelete,
    );

    if (!mounted) return;

    result.when(
      success: (_) async {
        // Auto-logout
        await service.signOut();

        if (!mounted) return;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_successMessage),
            backgroundColor: Colors.green,
          ),
        );

        // Close sheet with success
        Navigator.of(context).pop(true);
      },
      error: (error) async {
        if (error is RequiresRecentLoginException) {
          // Show reauthentication UI
          setState(() {
            _isDeleting = false;
            _showReauthForm = true;
          });
        } else {
          setState(() {
            _isDeleting = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$_errorMessage: ${error.message}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
    );
  }

  Future<void> _reauthenticateAndRetry(String provider) async {
    setState(() {
      _isDeleting = true;
      _reauthProvider = provider;
    });

    final service = ref.read(layouAuthServiceProvider);
    AuthResult<void> reauthResult;

    switch (provider) {
      case 'google':
        reauthResult = await service.reauthenticateWithGoogle();
        break;
      case 'apple':
        reauthResult = await service.reauthenticateWithApple();
        break;
      default:
        setState(() {
          _isDeleting = false;
          _reauthProvider = null;
        });
        return;
    }

    if (!mounted) return;

    reauthResult.when(
      success: (_) {
        // Reauthentication successful, retry deletion
        _deleteAccount();
      },
      error: (error) {
        setState(() {
          _isDeleting = false;
          _reauthProvider = null;
        });

        if (error is! UserCancelledException) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reauthentication failed: ${error.message}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
    );
  }

  Future<void> _reauthenticateWithEmail(String email, String password) async {
    setState(() {
      _isDeleting = true;
      _reauthProvider = 'email';
    });

    final service = ref.read(layouAuthServiceProvider);
    final reauthResult = await service.reauthenticateWithEmail(
      email: email,
      password: password,
    );

    if (!mounted) return;

    reauthResult.when(
      success: (_) {
        // Reauthentication successful, retry deletion
        _deleteAccount();
      },
      error: (error) {
        setState(() {
          _isDeleting = false;
          _reauthProvider = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reauthentication failed: ${error.message}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_showReauthForm) {
      return _buildReauthSheet(context);
    }

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

              // Warning icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 48,
                    color: colorScheme.error,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                _title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                _message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Delete button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isDeleting ? null : _deleteAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isDeleting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onError,
                          ),
                        )
                      : Text(_deleteButtonText),
                ),
              ),
              const SizedBox(height: 12),

              // Cancel button
              SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: _isDeleting
                      ? null
                      : () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(_cancelButtonText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReauthSheet(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasGoogle = ref.watch(layouHasGoogleProvider);
    final hasApple = ref.watch(layouHasAppleProvider);
    final hasEmail = ref.watch(layouHasEmailProvider);
    final showEmailForm = _reauthProvider == 'email';

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
                'Confirm Your Identity',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Please reauthenticate to continue',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              if (!showEmailForm) ...[
                // Google button
                if (hasGoogle)
                  SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _isDeleting
                          ? null
                          : () => _reauthenticateAndRetry('google'),
                      icon: const Icon(Icons.g_mobiledata, size: 24),
                      label: Text(_strings.googleButton),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                if (hasGoogle) const SizedBox(height: 12),

                // Apple button
                if (_showAppleButton && hasApple)
                  SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _isDeleting
                          ? null
                          : () => _reauthenticateAndRetry('apple'),
                      icon: const Icon(Icons.apple, size: 24),
                      label: Text(_strings.appleButton),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                if (_showAppleButton && hasApple) const SizedBox(height: 12),

                // Email button
                if (hasEmail)
                  SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _isDeleting
                          ? null
                          : () => setState(() => _reauthProvider = 'email'),
                      icon: const Icon(Icons.email_outlined, size: 24),
                      label: Text(_strings.emailButton),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
              ] else ...[
                // Email form
                LayouEmailForm(
                  onSubmit: _reauthenticateWithEmail,
                  showConfirmPassword: false,
                  strings: _strings,
                  isLoading: _isDeleting,
                  submitLabel: 'Reauthenticate',
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed:
                      _isDeleting ? null : () => setState(() => _reauthProvider = null),
                  child: Text(_strings.backButton),
                ),
              ],

              const SizedBox(height: 16),

              // Cancel button
              OutlinedButton(
                onPressed: _isDeleting
                    ? null
                    : () {
                        setState(() {
                          _showReauthForm = false;
                          _reauthProvider = null;
                        });
                      },
                child: Text(_strings.closeButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
