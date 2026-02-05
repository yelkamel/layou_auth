import 'package:flutter/material.dart';

/// Theme configuration for LayouAuth widgets
class LayouAuthTheme {
  /// Button style for Google sign-in
  final ButtonStyle? googleButtonStyle;

  /// Button style for Apple sign-in
  final ButtonStyle? appleButtonStyle;

  /// Button style for Email sign-in
  final ButtonStyle? emailButtonStyle;

  /// Icon for Google button
  final Widget? googleIcon;

  /// Icon for Apple button
  final Widget? appleIcon;

  /// Icon for Email button
  final Widget? emailIcon;

  /// Loading indicator widget
  final Widget? loadingIndicator;

  /// Border radius for buttons
  final double buttonBorderRadius;

  /// Vertical padding for buttons
  final double buttonVerticalPadding;

  /// Spacing between buttons
  final double buttonSpacing;

  /// Title text style
  final TextStyle? titleStyle;

  /// Subtitle text style
  final TextStyle? subtitleStyle;

  /// Error container decoration
  final BoxDecoration? errorDecoration;

  /// Error text style
  final TextStyle? errorTextStyle;

  const LayouAuthTheme({
    this.googleButtonStyle,
    this.appleButtonStyle,
    this.emailButtonStyle,
    this.googleIcon,
    this.appleIcon,
    this.emailIcon,
    this.loadingIndicator,
    this.buttonBorderRadius = 12.0,
    this.buttonVerticalPadding = 16.0,
    this.buttonSpacing = 12.0,
    this.titleStyle,
    this.subtitleStyle,
    this.errorDecoration,
    this.errorTextStyle,
  });

  /// Create theme from BuildContext
  factory LayouAuthTheme.fromContext(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return LayouAuthTheme(
      googleButtonStyle: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.onSurface,
        side: BorderSide(color: colorScheme.outline),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      appleButtonStyle: ElevatedButton.styleFrom(
        backgroundColor: isDark ? Colors.white : Colors.black,
        foregroundColor: isDark ? Colors.black : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      emailButtonStyle: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.onSurface,
        side: BorderSide(color: colorScheme.outline),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      googleIcon: Icon(
        Icons.g_mobiledata,
        size: 24,
        color: colorScheme.onSurface,
      ),
      appleIcon: Icon(
        Icons.apple,
        size: 24,
        color: isDark ? Colors.black : Colors.white,
      ),
      emailIcon: Icon(
        Icons.email_outlined,
        size: 24,
        color: colorScheme.onSurface,
      ),
      loadingIndicator: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(colorScheme.primary),
        ),
      ),
      titleStyle: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
      subtitleStyle: theme.textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      errorDecoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      errorTextStyle: TextStyle(
        color: colorScheme.error,
        fontSize: 14,
      ),
    );
  }

  /// Copy with new values
  LayouAuthTheme copyWith({
    ButtonStyle? googleButtonStyle,
    ButtonStyle? appleButtonStyle,
    ButtonStyle? emailButtonStyle,
    Widget? googleIcon,
    Widget? appleIcon,
    Widget? emailIcon,
    Widget? loadingIndicator,
    double? buttonBorderRadius,
    double? buttonVerticalPadding,
    double? buttonSpacing,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
    BoxDecoration? errorDecoration,
    TextStyle? errorTextStyle,
  }) {
    return LayouAuthTheme(
      googleButtonStyle: googleButtonStyle ?? this.googleButtonStyle,
      appleButtonStyle: appleButtonStyle ?? this.appleButtonStyle,
      emailButtonStyle: emailButtonStyle ?? this.emailButtonStyle,
      googleIcon: googleIcon ?? this.googleIcon,
      appleIcon: appleIcon ?? this.appleIcon,
      emailIcon: emailIcon ?? this.emailIcon,
      loadingIndicator: loadingIndicator ?? this.loadingIndicator,
      buttonBorderRadius: buttonBorderRadius ?? this.buttonBorderRadius,
      buttonVerticalPadding: buttonVerticalPadding ?? this.buttonVerticalPadding,
      buttonSpacing: buttonSpacing ?? this.buttonSpacing,
      titleStyle: titleStyle ?? this.titleStyle,
      subtitleStyle: subtitleStyle ?? this.subtitleStyle,
      errorDecoration: errorDecoration ?? this.errorDecoration,
      errorTextStyle: errorTextStyle ?? this.errorTextStyle,
    );
  }
}
