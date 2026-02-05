import '../../exceptions/auth_exceptions.dart';
import 'auth_provider_config.dart';

/// Configuration for Email/Password authentication
class EmailProviderConfig extends AuthProviderConfig {
  /// Minimum password length
  final int passwordMinLength;

  /// Require password confirmation in forms
  final bool requireConfirmPassword;

  /// Custom password validator
  final String? Function(String password)? passwordValidator;

  /// Custom email validator
  final String? Function(String email)? emailValidator;

  const EmailProviderConfig({
    this.passwordMinLength = 8,
    this.requireConfirmPassword = true,
    this.passwordValidator,
    this.emailValidator,
  });

  @override
  AuthMethod get method => AuthMethod.email;

  /// Default email validation
  String? validateEmail(String email) {
    if (emailValidator != null) {
      return emailValidator!(email);
    }
    if (email.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Invalid email format';
    }
    return null;
  }

  /// Default password validation
  String? validatePassword(String password) {
    if (passwordValidator != null) {
      return passwordValidator!(password);
    }
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < passwordMinLength) {
      return 'Password must be at least $passwordMinLength characters';
    }
    return null;
  }
}
