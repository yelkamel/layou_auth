import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/auth_user.dart';
import '../exceptions/auth_exceptions.dart';
import '../providers/auth_providers.dart';
import 'buttons/layou_apple_button.dart';
import 'buttons/layou_email_button.dart';
import 'buttons/layou_google_button.dart';
import 'theme/layou_auth_strings.dart';
import 'theme/layou_auth_theme.dart';

/// Inline auth section widget for embedding in settings or profile pages
class LayouAuthSection extends ConsumerStatefulWidget {
  /// Custom title
  final String? title;

  /// Custom subtitle
  final String? subtitle;

  /// Custom theme
  final LayouAuthTheme? theme;

  /// Custom strings
  final LayouAuthStrings? strings;

  /// Called on successful linking
  final void Function(AuthUser user, AuthMethod method)? onSuccess;

  /// Called on error
  final void Function(AuthException error)? onError;

  /// Whether to show Apple button (defaults to iOS/macOS only)
  final bool? showApple;

  /// Whether to show Google button
  final bool showGoogle;

  /// Whether to show Email button/form
  final bool showEmail;

  /// Called when email button is pressed (e.g., to navigate to email form screen)
  /// If null, email button won't be shown
  final VoidCallback? onEmailPressed;

  const LayouAuthSection({
    super.key,
    this.title,
    this.subtitle,
    this.theme,
    this.strings,
    this.onSuccess,
    this.onError,
    this.showApple,
    this.showGoogle = true,
    this.showEmail = true,
    this.onEmailPressed,
  });

  @override
  ConsumerState<LayouAuthSection> createState() => _LayouAuthSectionState();
}

class _LayouAuthSectionState extends ConsumerState<LayouAuthSection> {
  bool _isLoading = false;
  String? _loadingProvider;

  LayouAuthStrings get _strings => widget.strings ?? const LayouAuthStrings();

  bool get _showAppleButton {
    if (widget.showApple != null) return widget.showApple!;
    return !kIsWeb && (Platform.isIOS || Platform.isMacOS);
  }

  Future<void> _linkWithGoogle() async {
    setState(() {
      _isLoading = true;
      _loadingProvider = 'google';
    });

    final result =
        await ref.read(layouAuthActionsProvider.notifier).linkWithGoogle();

    if (!mounted) return;

    result.when(
      success: (user) {
        widget.onSuccess?.call(user, AuthMethod.google);
      },
      error: (error) {
        if (error is! UserCancelledException) {
          widget.onError?.call(error);
          _showError(error);
        }
      },
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        _loadingProvider = null;
      });
    }
  }

  Future<void> _linkWithApple() async {
    setState(() {
      _isLoading = true;
      _loadingProvider = 'apple';
    });

    final result =
        await ref.read(layouAuthActionsProvider.notifier).linkWithApple();

    if (!mounted) return;

    result.when(
      success: (user) {
        widget.onSuccess?.call(user, AuthMethod.apple);
      },
      error: (error) {
        if (error is! UserCancelledException) {
          widget.onError?.call(error);
          _showError(error);
        }
      },
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        _loadingProvider = null;
      });
    }
  }

  void _showError(AuthException error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_strings.getErrorMessage(error)),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme ?? LayouAuthTheme.fromContext(context);
    final hasGoogle = ref.watch(layouHasGoogleProvider);
    final hasApple = ref.watch(layouHasAppleProvider);
    final hasEmail = ref.watch(layouHasEmailProvider);
    final isAnonymous = ref.watch(layouIsAnonymousProvider);

    // Don't show if not anonymous (already linked)
    if (!isAnonymous) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        if (widget.title != null || widget.strings != null)
          Text(
            widget.title ?? _strings.linkAccountTitle,
            style: theme.titleStyle?.copyWith(fontSize: 18),
          ),

        if (widget.title != null || widget.strings != null)
          const SizedBox(height: 4),

        // Subtitle
        if (widget.subtitle != null || widget.strings != null)
          Text(
            widget.subtitle ?? _strings.linkAccountSubtitle,
            style: theme.subtitleStyle,
          ),

        if (widget.subtitle != null || widget.strings != null)
          const SizedBox(height: 16),

        // Google button
        if (widget.showGoogle)
          LayouGoogleButton(
            label: _strings.googleButton,
            isLoading: _loadingProvider == 'google',
            enabled: !_isLoading,
            isLinked: hasGoogle,
            onPressed: _linkWithGoogle,
          ),

        if (widget.showGoogle) SizedBox(height: theme.buttonSpacing),

        // Apple button
        if (_showAppleButton)
          LayouAppleButton(
            label: _strings.appleButton,
            isLoading: _loadingProvider == 'apple',
            enabled: !_isLoading,
            isLinked: hasApple,
            onPressed: _linkWithApple,
          ),

        if (_showAppleButton) SizedBox(height: theme.buttonSpacing),

        // Email button
        if (widget.showEmail && widget.onEmailPressed != null)
          LayouEmailButton(
            label: _strings.emailButton,
            enabled: !_isLoading,
            isLinked: hasEmail,
            onPressed: widget.onEmailPressed,
          ),
      ],
    );
  }
}
