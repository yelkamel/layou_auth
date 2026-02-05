import 'package:flutter/material.dart';

/// Bottom sheet that appears when a credential is already in use on another account.
/// Asks the user if they want to sign in with the existing account instead.
class LayouCredentialInUseSheet extends StatelessWidget {
  /// Provider name (Google, Apple, Email)
  final String providerName;

  /// Custom title
  final String? title;

  /// Custom message (use {provider} placeholder)
  final String? message;

  /// Sign-in button text
  final String? signInButtonText;

  /// Cancel button text
  final String? cancelButtonText;

  const LayouCredentialInUseSheet({
    super.key,
    required this.providerName,
    this.title,
    this.message,
    this.signInButtonText,
    this.cancelButtonText,
  });

  /// Show as modal bottom sheet
  ///
  /// Returns `true` if user wants to sign in, `false` if cancelled.
  static Future<bool> show(
    BuildContext context, {
    required String providerName,
    String? title,
    String? message,
    String? signInButtonText,
    String? cancelButtonText,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LayouCredentialInUseSheet(
        providerName: providerName,
        title: title,
        message: message,
        signInButtonText: signInButtonText,
        cancelButtonText: cancelButtonText,
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final displayTitle = title ?? 'Account Already Exists';
    final displayMessage = message?.replaceAll('{provider}', providerName) ??
        'This $providerName account is already associated with an existing account. Do you want to sign in with this account instead?';
    final displaySignInButton = signInButtonText ?? 'Sign In';
    final displayCancelButton = cancelButtonText ?? 'Cancel';

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
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
                    color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.info_outline,
                    size: 48,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                displayTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                displayMessage,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Sign in button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(displaySignInButton),
                ),
              ),
              const SizedBox(height: 12),

              // Cancel button
              SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(displayCancelButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
