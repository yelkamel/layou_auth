# LayouAuth - Recent Enhancements

## New Features Added

### 1. Logout with Callbacks ✅

Added optional callbacks to `signOut()` method for pre/post-logout actions.

**API:**
```dart
await service.signOut(
  onBeforeLogout: () async {
    // Cleanup before logout (e.g., cancel subscriptions)
    await subscriptionService.cancelAll();
  },
  onAfterLogout: () async {
    // Actions after logout (e.g., navigation, analytics)
    analytics.logLogout();
    context.go(Routes.home);
  },
);
```

**Features:**
- Callbacks are wrapped in try-catch to prevent blocking logout
- Errors are logged but don't affect logout result
- `onAfterLogout` only executes if logout succeeds

---

### 2. Debug Mode Email Generation ✅

Long-press on email label in `LayouEmailForm` to auto-generate test credentials.

**Features:**
- Only active in `kDebugMode`
- Generates email: `test_XXX@yopmail.com` (XXX = random 3-digit number)
- Generates password: `azerty123`
- Auto-fills confirm password field if visible
- Shows optional snackbar confirmation

**API:**
```dart
LayouEmailForm(
  onSubmit: _handleSubmit,
  debugCredentialsMessage: 'Debug credentials generated', // Optional
)
```

**Usage:**
1. Run app in debug mode
2. Long-press on "Email" label
3. Both email and password fields are auto-filled

---

### 3. Account Deletion with Reauthentication ✅

New `LayouDeleteAccountSheet` widget for safe account deletion.

**Features:**
- Confirmation UI with warning icon
- Red destructive button styling
- Automatic reauthentication handling
- Auto-retry after successful reauth
- Auto-logout after deletion
- Callbacks for custom cleanup
- Fully customizable strings

**API:**
```dart
// Simple usage
LayouDeleteAccountSheet.show(context);

// Full customization
LayouDeleteAccountSheet.show(
  context,
  title: 'Delete Account?',
  message: 'Your data will be permanently deleted.',
  deleteButtonText: 'Yes, Delete',
  cancelButtonText: 'Keep Account',
  deletingMessage: 'Deleting...',
  successMessage: 'Account deleted',
  errorMessage: 'Failed to delete',
  onBeforeDelete: () async {
    // Custom cleanup (e.g., delete Firestore documents)
    await firestore.collection('users').doc(uid).delete();
  },
  onAfterDelete: () async {
    // Post-deletion actions
    analytics.logAccountDeleted();
  },
);
```

**Flow:**
1. User clicks delete → confirmation shown
2. User confirms → deletion attempted
3. If `requires-recent-login` error → reauthentication UI shown
4. User reauthenticates → deletion auto-retries
5. On success → auto-logout + callbacks executed

**Reauthentication:**
- Supports Google, Apple, and Email reauthentication
- Automatically shows available auth methods
- Seamless retry after successful reauth

---

### 4. Credential Already In Use Handling ✅

When linking a provider that exists on another account, show dialog offering to sign in instead.

**Features:**
- Custom bottom sheet (not AlertDialog)
- Matches package design system
- Fully customizable strings
- Automatic sign-in if user confirms
- Graceful error handling

**API:**
```dart
LayouAuthSheet.show(
  context,
  mode: LayouAuthMode.link,
  credentialInUseTitle: 'Account Exists',
  credentialInUseMessage: 'This {provider} account is already linked. Sign in instead?',
  credentialInUseSignInButton: 'Sign In',
  credentialInUseCancelButton: 'Cancel',
);
```

**Flow:**
1. Anonymous user tries to link Google/Apple/Email
2. Provider is already linked to another account
3. Bottom sheet appears: "Account already exists. Sign in instead?"
4. If user confirms → signs into existing account (anonymous data discarded)
5. If user cancels → stays anonymous, can try another provider

**Note:** For email, the flow is slightly different since we don't have the password in memory. The user will need to re-enter credentials.

---

## Updated Components

### `AuthService` (core/auth_service.dart)
- ✅ Added `signOut()` callbacks
- ✅ Added `deleteUser()` callbacks
- ✅ Added `reauthenticateWithEmail()`
- ✅ Added `reauthenticateWithGoogle()`
- ✅ Added `reauthenticateWithApple()`

### `LayouEmailForm` (widgets/forms/layou_email_form.dart)
- ✅ Added debug mode email generation
- ✅ Added `debugCredentialsMessage` parameter

### `LayouAuthSheet` (widgets/layou_auth_sheet.dart)
- ✅ Added credential-already-in-use handling
- ✅ Added customization parameters

### `AuthException` (exceptions/auth_exceptions.dart)
- ✅ Added `RequiresRecentLoginException`

---

## New Widgets

### `LayouDeleteAccountSheet`
Location: `lib/src/widgets/layou_delete_account_sheet.dart`

Complete account deletion UI with reauthentication support.

### `LayouCredentialInUseSheet`
Location: `lib/src/widgets/layou_credential_in_use_sheet.dart`

Bottom sheet for handling credential-already-in-use scenarios.

---

## Breaking Changes

**None!** All changes are backward compatible:
- New parameters are optional
- Existing code continues to work
- Default behavior unchanged

---

## Examples

### Example 1: Delete Account Button

```dart
ElevatedButton(
  onPressed: () async {
    final confirmed = await LayouDeleteAccountSheet.show(
      context,
      onBeforeDelete: () async {
        // Delete user documents
        await _deleteUserData(userId);
      },
    );

    if (confirmed == true) {
      // User deleted and logged out
      context.go(Routes.welcome);
    }
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.red,
  ),
  child: const Text('Delete My Account'),
);
```

### Example 2: Logout with Navigation

```dart
final service = ref.read(layouAuthServiceProvider);

await service.signOut(
  onBeforeLogout: () async {
    // Cancel subscriptions
    await _cancelSubscriptions();
  },
  onAfterLogout: () async {
    // Navigate to home
    context.go(Routes.home);
  },
);
```

### Example 3: Custom Credential-in-Use Messages

```dart
LayouAuthSheet.show(
  context,
  mode: LayouAuthMode.link,
  credentialInUseTitle: t.auth.accountExists,
  credentialInUseMessage: t.auth.accountExistsMessage,
  credentialInUseSignInButton: t.auth.signInInstead,
  credentialInUseCancelButton: t.common.cancel,
);
```

---

## Implementation Notes

### Design Decisions

1. **Callbacks in Service Layer**: Callbacks added to service methods (not config) for maximum flexibility per operation
2. **Bottom Sheets > Dialogs**: All new UI uses bottom sheets to match package design language
3. **No i18n Dependencies**: All strings passed as parameters for flexibility
4. **Auto-Logout After Deletion**: Security best practice
5. **Reauthentication in UI Layer**: Consistent with Firebase best practices

### Error Handling

All callbacks are wrapped in try-catch blocks:
- Callback errors are logged but don't block operations
- User is notified of operation result, not callback failures
- Ensures robust behavior even with buggy callbacks

---

## Testing Checklist

- [x] Logout callbacks execute in correct order
- [x] Debug email generation works (debug mode only)
- [x] Account deletion with recent login succeeds
- [x] Account deletion with old login triggers reauth
- [x] Reauthentication with each provider works
- [x] Credential-already-in-use shows correct provider name
- [x] Sign-in redirect works after credential-in-use confirmation
- [x] All strings can be customized
- [x] No breaking changes to existing API

---

## Migration Guide

No migration needed! Just update your dependency version and start using new features:

```yaml
dependencies:
  layou_auth: ^latest_version
```

---

## Future Considerations

Possible future enhancements (not implemented):
- [ ] Unlink provider with reauthentication
- [ ] Password reset flow
- [ ] Email verification UI
- [ ] Phone auth support
- [ ] Multi-factor authentication

---

## Credits

Enhancements requested by user and implemented following the existing package patterns and design philosophy.
