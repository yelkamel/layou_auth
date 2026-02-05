import '../../exceptions/auth_exceptions.dart';

/// Localized strings for LayouAuth widgets
class LayouAuthStrings {
  // Sheet/Section titles
  final String signInTitle;
  final String signInSubtitle;
  final String linkAccountTitle;
  final String linkAccountSubtitle;

  // Button labels
  final String googleButton;
  final String appleButton;
  final String emailButton;
  final String signOutButton;
  final String deleteAccountButton;
  final String closeButton;
  final String backButton;
  final String submitButton;

  // Email form
  final String emailLabel;
  final String emailHint;
  final String passwordLabel;
  final String passwordHint;
  final String confirmPasswordLabel;
  final String confirmPasswordHint;

  // Validation errors
  final String emailRequired;
  final String emailInvalid;
  final String passwordRequired;
  final String passwordTooShort;
  final String passwordsDontMatch;

  // Success messages
  final String signInSuccess;
  final String linkSuccess;
  final String signOutSuccess;

  // Error messages
  final String errorGeneric;
  final String errorNetwork;
  final String errorCancelled;
  final String errorCredentialInUse;
  final String errorEmailInUse;
  final String errorWeakPassword;
  final String errorInvalidEmail;
  final String errorUserNotFound;
  final String errorWrongPassword;
  final String errorUserDisabled;

  // Linked status
  final String linkedWith;

  const LayouAuthStrings({
    this.signInTitle = 'Sign In',
    this.signInSubtitle = 'Access your existing account',
    this.linkAccountTitle = 'Link Account',
    this.linkAccountSubtitle = 'Secure your data by linking a sign-in method',
    this.googleButton = 'Continue with Google',
    this.appleButton = 'Continue with Apple',
    this.emailButton = 'Continue with Email',
    this.signOutButton = 'Sign Out',
    this.deleteAccountButton = 'Delete Account',
    this.closeButton = 'Close',
    this.backButton = 'Back',
    this.submitButton = 'Submit',
    this.emailLabel = 'Email',
    this.emailHint = 'Enter your email',
    this.passwordLabel = 'Password',
    this.passwordHint = 'Enter your password',
    this.confirmPasswordLabel = 'Confirm Password',
    this.confirmPasswordHint = 'Re-enter your password',
    this.emailRequired = 'Email is required',
    this.emailInvalid = 'Invalid email format',
    this.passwordRequired = 'Password is required',
    this.passwordTooShort = 'Password is too short',
    this.passwordsDontMatch = 'Passwords do not match',
    this.signInSuccess = 'Signed in successfully',
    this.linkSuccess = 'Account linked successfully',
    this.signOutSuccess = 'Signed out successfully',
    this.errorGeneric = 'Something went wrong. Please try again.',
    this.errorNetwork = 'Network error. Please check your connection.',
    this.errorCancelled = 'Sign-in was cancelled',
    this.errorCredentialInUse = 'This account is already linked to another user',
    this.errorEmailInUse = 'This email is already in use',
    this.errorWeakPassword = 'Password is too weak',
    this.errorInvalidEmail = 'Invalid email address',
    this.errorUserNotFound = 'No account found with this email',
    this.errorWrongPassword = 'Incorrect password',
    this.errorUserDisabled = 'This account has been disabled',
    this.linkedWith = 'Linked',
  });

  /// English strings (default)
  factory LayouAuthStrings.en() => const LayouAuthStrings();

  /// French strings
  factory LayouAuthStrings.fr() => const LayouAuthStrings(
        signInTitle: 'Connexion',
        signInSubtitle: 'Accédez à votre compte existant',
        linkAccountTitle: 'Lier un compte',
        linkAccountSubtitle:
            'Sécurisez vos données en liant une méthode de connexion',
        googleButton: 'Continuer avec Google',
        appleButton: 'Continuer avec Apple',
        emailButton: 'Continuer avec Email',
        signOutButton: 'Déconnexion',
        deleteAccountButton: 'Supprimer le compte',
        closeButton: 'Fermer',
        backButton: 'Retour',
        submitButton: 'Valider',
        emailLabel: 'Email',
        emailHint: 'Entrez votre email',
        passwordLabel: 'Mot de passe',
        passwordHint: 'Entrez votre mot de passe',
        confirmPasswordLabel: 'Confirmer le mot de passe',
        confirmPasswordHint: 'Ressaisissez votre mot de passe',
        emailRequired: 'L\'email est requis',
        emailInvalid: 'Format d\'email invalide',
        passwordRequired: 'Le mot de passe est requis',
        passwordTooShort: 'Le mot de passe est trop court',
        passwordsDontMatch: 'Les mots de passe ne correspondent pas',
        signInSuccess: 'Connexion réussie',
        linkSuccess: 'Compte lié avec succès',
        signOutSuccess: 'Déconnexion réussie',
        errorGeneric: 'Une erreur est survenue. Veuillez réessayer.',
        errorNetwork: 'Erreur réseau. Vérifiez votre connexion.',
        errorCancelled: 'Connexion annulée',
        errorCredentialInUse: 'Ce compte est déjà lié à un autre utilisateur',
        errorEmailInUse: 'Cet email est déjà utilisé',
        errorWeakPassword: 'Le mot de passe est trop faible',
        errorInvalidEmail: 'Adresse email invalide',
        errorUserNotFound: 'Aucun compte trouvé avec cet email',
        errorWrongPassword: 'Mot de passe incorrect',
        errorUserDisabled: 'Ce compte a été désactivé',
        linkedWith: 'Lié',
      );

  /// Get error message for an exception
  String getErrorMessage(AuthException error) {
    return switch (error) {
      UserCancelledException() => errorCancelled,
      NetworkException() => errorNetwork,
      CredentialAlreadyInUseException() => errorCredentialInUse,
      EmailAlreadyInUseException() => errorEmailInUse,
      WeakPasswordException() => errorWeakPassword,
      InvalidEmailException() => errorInvalidEmail,
      UserNotFoundException() => errorUserNotFound,
      WrongPasswordException() => errorWrongPassword,
      UserDisabledException() => errorUserDisabled,
      _ => errorGeneric,
    };
  }

  /// Copy with new values
  LayouAuthStrings copyWith({
    String? signInTitle,
    String? signInSubtitle,
    String? linkAccountTitle,
    String? linkAccountSubtitle,
    String? googleButton,
    String? appleButton,
    String? emailButton,
    String? signOutButton,
    String? deleteAccountButton,
    String? closeButton,
    String? backButton,
    String? submitButton,
    String? emailLabel,
    String? emailHint,
    String? passwordLabel,
    String? passwordHint,
    String? confirmPasswordLabel,
    String? confirmPasswordHint,
    String? emailRequired,
    String? emailInvalid,
    String? passwordRequired,
    String? passwordTooShort,
    String? passwordsDontMatch,
    String? signInSuccess,
    String? linkSuccess,
    String? signOutSuccess,
    String? errorGeneric,
    String? errorNetwork,
    String? errorCancelled,
    String? errorCredentialInUse,
    String? errorEmailInUse,
    String? errorWeakPassword,
    String? errorInvalidEmail,
    String? errorUserNotFound,
    String? errorWrongPassword,
    String? errorUserDisabled,
    String? linkedWith,
  }) {
    return LayouAuthStrings(
      signInTitle: signInTitle ?? this.signInTitle,
      signInSubtitle: signInSubtitle ?? this.signInSubtitle,
      linkAccountTitle: linkAccountTitle ?? this.linkAccountTitle,
      linkAccountSubtitle: linkAccountSubtitle ?? this.linkAccountSubtitle,
      googleButton: googleButton ?? this.googleButton,
      appleButton: appleButton ?? this.appleButton,
      emailButton: emailButton ?? this.emailButton,
      signOutButton: signOutButton ?? this.signOutButton,
      deleteAccountButton: deleteAccountButton ?? this.deleteAccountButton,
      closeButton: closeButton ?? this.closeButton,
      backButton: backButton ?? this.backButton,
      submitButton: submitButton ?? this.submitButton,
      emailLabel: emailLabel ?? this.emailLabel,
      emailHint: emailHint ?? this.emailHint,
      passwordLabel: passwordLabel ?? this.passwordLabel,
      passwordHint: passwordHint ?? this.passwordHint,
      confirmPasswordLabel: confirmPasswordLabel ?? this.confirmPasswordLabel,
      confirmPasswordHint: confirmPasswordHint ?? this.confirmPasswordHint,
      emailRequired: emailRequired ?? this.emailRequired,
      emailInvalid: emailInvalid ?? this.emailInvalid,
      passwordRequired: passwordRequired ?? this.passwordRequired,
      passwordTooShort: passwordTooShort ?? this.passwordTooShort,
      passwordsDontMatch: passwordsDontMatch ?? this.passwordsDontMatch,
      signInSuccess: signInSuccess ?? this.signInSuccess,
      linkSuccess: linkSuccess ?? this.linkSuccess,
      signOutSuccess: signOutSuccess ?? this.signOutSuccess,
      errorGeneric: errorGeneric ?? this.errorGeneric,
      errorNetwork: errorNetwork ?? this.errorNetwork,
      errorCancelled: errorCancelled ?? this.errorCancelled,
      errorCredentialInUse: errorCredentialInUse ?? this.errorCredentialInUse,
      errorEmailInUse: errorEmailInUse ?? this.errorEmailInUse,
      errorWeakPassword: errorWeakPassword ?? this.errorWeakPassword,
      errorInvalidEmail: errorInvalidEmail ?? this.errorInvalidEmail,
      errorUserNotFound: errorUserNotFound ?? this.errorUserNotFound,
      errorWrongPassword: errorWrongPassword ?? this.errorWrongPassword,
      errorUserDisabled: errorUserDisabled ?? this.errorUserDisabled,
      linkedWith: linkedWith ?? this.linkedWith,
    );
  }
}
