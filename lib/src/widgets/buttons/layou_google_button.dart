import 'package:flutter/material.dart';

import '../theme/layou_auth_theme.dart';

/// Google sign-in/link button
class LayouGoogleButton extends StatelessWidget {
  /// Button label
  final String label;

  /// Called when button is pressed
  final VoidCallback? onPressed;

  /// Whether the button is in loading state
  final bool isLoading;

  /// Whether the button is enabled
  final bool enabled;

  /// Custom button style
  final ButtonStyle? style;

  /// Custom icon widget
  final Widget? icon;

  /// Custom loading indicator
  final Widget? loadingIndicator;

  /// Whether this provider is already linked (shows check icon)
  final bool isLinked;

  const LayouGoogleButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.style,
    this.icon,
    this.loadingIndicator,
    this.isLinked = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = LayouAuthTheme.fromContext(context);
    final buttonStyle = style ?? theme.googleButtonStyle;
    final buttonIcon = icon ?? theme.googleIcon ?? const Icon(Icons.g_mobiledata, size: 24);
    final loader = loadingIndicator ?? theme.loadingIndicator;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: enabled && !isLoading && !isLinked ? onPressed : null,
        style: buttonStyle,
        child: isLoading
            ? loader
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLinked) ...[
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                  ],
                  buttonIcon,
                  const SizedBox(width: 12),
                  Text(label),
                ],
              ),
      ),
    );
  }
}
