/// Firebase Auth package with Google, Apple, and Email sign-in/linking support.
///
/// Provides ready-to-use widgets and Riverpod providers for authentication.
library layou_auth;

// Config
export 'src/config/layou_auth_config.dart';
export 'src/config/providers/auth_provider_config.dart';
export 'src/config/providers/google_provider_config.dart';
export 'src/config/providers/apple_provider_config.dart';
export 'src/config/providers/email_provider_config.dart';

// Core
export 'src/core/layou_auth.dart';
export 'src/core/auth_user.dart';
export 'src/core/auth_service.dart';
export 'src/core/auth_result.dart';

// Exceptions
export 'src/exceptions/auth_exceptions.dart';

// Providers
export 'src/providers/auth_providers.dart';

// Widgets
export 'src/widgets/layou_auth_sheet.dart';
export 'src/widgets/layou_auth_section.dart';
export 'src/widgets/layou_delete_account_sheet.dart';
export 'src/widgets/layou_credential_in_use_sheet.dart';
export 'src/widgets/buttons/layou_google_button.dart';
export 'src/widgets/buttons/layou_apple_button.dart';
export 'src/widgets/buttons/layou_email_button.dart';
export 'src/widgets/forms/layou_email_form.dart';
export 'src/widgets/theme/layou_auth_theme.dart';
export 'src/widgets/theme/layou_auth_strings.dart';
