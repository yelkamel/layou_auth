import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../config/providers/email_provider_config.dart';
import '../../core/layou_auth.dart';
import '../theme/layou_auth_strings.dart';

/// Email/password form widget
class LayouEmailForm extends StatefulWidget {
  /// Called when form is submitted with valid data
  final Future<void> Function(String email, String password) onSubmit;

  /// Whether to show confirm password field
  final bool showConfirmPassword;

  /// Custom strings
  final LayouAuthStrings? strings;

  /// Custom email validator
  final String? Function(String email)? emailValidator;

  /// Custom password validator
  final String? Function(String password)? passwordValidator;

  /// Submit button label
  final String? submitLabel;

  /// Whether the form is in loading state
  final bool isLoading;

  /// Input decoration for fields
  final InputDecoration? inputDecoration;

  /// Button style
  final ButtonStyle? buttonStyle;

  /// Debug credentials message (shown as snackbar in debug mode)
  final String? debugCredentialsMessage;

  const LayouEmailForm({
    super.key,
    required this.onSubmit,
    this.showConfirmPassword = true,
    this.strings,
    this.emailValidator,
    this.passwordValidator,
    this.submitLabel,
    this.isLoading = false,
    this.inputDecoration,
    this.buttonStyle,
    this.debugCredentialsMessage,
  });

  @override
  State<LayouEmailForm> createState() => _LayouEmailFormState();
}

class _LayouEmailFormState extends State<LayouEmailForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;

  LayouAuthStrings get _strings => widget.strings ?? const LayouAuthStrings();

  EmailProviderConfig? get _emailConfig {
    if (!LayouAuth.isInitialized) return null;
    return LayouAuth.instance.config.email;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _generateDebugCredentials() {
    if (!kDebugMode) return;

    final random = Random();
    final randomNumber = random.nextInt(1000).toString().padLeft(3, '0');
    final email = 'test_$randomNumber@yopmail.com';
    const password = 'azerty123';

    setState(() {
      _emailController.text = email;
      _passwordController.text = password;
      if (widget.showConfirmPassword) {
        _confirmPasswordController.text = password;
      }
    });

    if (widget.debugCredentialsMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.debugCredentialsMessage!),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String? _validateEmail(String? value) {
    if (widget.emailValidator != null) {
      return widget.emailValidator!(value ?? '');
    }
    if (_emailConfig != null) {
      return _emailConfig!.validateEmail(value ?? '');
    }
    if (value == null || value.isEmpty) {
      return _strings.emailRequired;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return _strings.emailInvalid;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (widget.passwordValidator != null) {
      return widget.passwordValidator!(value ?? '');
    }
    if (_emailConfig != null) {
      return _emailConfig!.validatePassword(value ?? '');
    }
    if (value == null || value.isEmpty) {
      return _strings.passwordRequired;
    }
    if (value.length < 8) {
      return _strings.passwordTooShort;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) {
      return _strings.passwordsDontMatch;
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await widget.onSubmit(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = widget.isLoading || _isSubmitting;

    final baseDecoration = widget.inputDecoration ??
        InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            enabled: !isLoading,
            decoration: baseDecoration.copyWith(
              label: kDebugMode
                  ? GestureDetector(
                      onLongPress: _generateDebugCredentials,
                      child: Text(_strings.emailLabel),
                    )
                  : Text(_strings.emailLabel),
              hintText: _strings.emailHint,
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            validator: _validateEmail,
          ),
          const SizedBox(height: 16),

          // Password field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: widget.showConfirmPassword
                ? TextInputAction.next
                : TextInputAction.done,
            enabled: !isLoading,
            onFieldSubmitted:
                widget.showConfirmPassword ? null : (_) => _submit(),
            decoration: baseDecoration.copyWith(
              labelText: _strings.passwordLabel,
              hintText: _strings.passwordHint,
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: _validatePassword,
          ),

          // Confirm password field
          if (widget.showConfirmPassword) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              enabled: !isLoading,
              onFieldSubmitted: (_) => _submit(),
              decoration: baseDecoration.copyWith(
                labelText: _strings.confirmPasswordLabel,
                hintText: _strings.confirmPasswordHint,
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,),
                ),
              ),
              validator: _validateConfirmPassword,
            ),
          ],

          const SizedBox(height: 24),

          // Submit button
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: isLoading ? null : _submit,
              style: widget.buttonStyle ??
                  ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : Text(widget.submitLabel ?? _strings.submitButton),
            ),
          ),
        ],
      ),
    );
  }
}
