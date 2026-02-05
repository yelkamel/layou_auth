import 'package:flutter/material.dart';

import '../theme/layou_auth_theme.dart';

/// Apple sign-in/link button
class LayouAppleButton extends StatelessWidget {
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

  const LayouAppleButton({
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonStyle = style ?? theme.appleButtonStyle;
    final buttonIcon = icon ?? theme.appleIcon ?? Icon(
      Icons.apple,
      size: 24,
      color: isDark ? Colors.black : Colors.white,
    );
    final loader = loadingIndicator ??
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(isDark ? Colors.black : Colors.white),
          ),
        );

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
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
