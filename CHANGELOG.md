# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.3] - 2026-02-03

### 📚 Documentation

#### Complete README with UX Philosophy + Technical Content
- Fixed incomplete README that was missing all practical content
- Now includes BOTH UX philosophy section AND complete technical documentation:
  - Screenshots and visual examples
  - Quick Start guide
  - Advanced usage examples
  - Customization options (strings, theme, builders)
  - Riverpod providers documentation
  - Error handling guide
  - Platform setup instructions
  - Common patterns and best practices
  - Contributing guide and roadmap

---

## [1.0.2] - 2026-02-03

### 📚 Documentation

#### Enhanced README with UX-First Approach
- Added "This README is for everyone" note targeting designers, PMs, and developers
- Restructured Features section with separate "For Product & UX Teams" and "For Developers" subsections
- Enhanced "Why?" section with explicit "aha moment" concept and funnel leak awareness
- Added "Real-world UX Strategies" section with production-tested approaches:
  - Anonymous-first strategy with linking best practices
  - Email-only approach considerations
  - Apple/Google only considerations (Hide My Email awareness)
- New "When to prompt account linking" code examples showing:
  - ✅ Good timing: Post-purchase, after meaningful engagement
  - ❌ Bad timing: App launch, before value demonstration
- Expanded Philosophy section with targeted messaging for:
  - Designers & product people: UX friction perspective
  - Developers: Technical simplicity
  - Everyone: Core value proposition questions
- Emphasized that anonymous-first is a UX philosophy, not just a technical choice
- Added real-world insights from teams testing different auth strategies

### 🎯 Positioning
- Package now explicitly positioned as "UX mindset + technical implementation"
- Clear focus on minimizing friction to "aha moment"
- Documentation speaks to broader audience beyond Flutter developers

---

## [1.0.1] - 2026-02-02

### 🎉 Added

#### Account Deletion with Reauthentication
- New `LayouDeleteAccountSheet` widget for safe account deletion
- Automatic reauthentication when `requires-recent-login` error occurs
- Reauthentication support for Google, Apple, and Email providers
- Auto-logout after successful account deletion
- Per-operation callbacks: `onBeforeDelete` and `onAfterDelete`
- Fully customizable UI strings

#### Smart Credential Handling
- New `LayouCredentialInUseSheet` widget for better UX
- When linking a provider that exists elsewhere, offer to sign in instead
- Seamless account switching from anonymous to existing account
- Customizable messaging with `{provider}` placeholder

#### Debug Mode Features
- Long-press email field to auto-generate test credentials
- Generates `test_XXX@yopmail.com` / `azerty123`
- Only active in `kDebugMode` (safe for production)
- Optional snackbar confirmation message

#### Lifecycle Callbacks
- `signOut()` now accepts `onBeforeLogout` and `onAfterLogout` callbacks
- `deleteUser()` now accepts `onBeforeDelete` and `onAfterDelete` callbacks
- Callbacks wrapped in try-catch to prevent blocking operations

#### Reauthentication Methods
- `AuthService.reauthenticateWithEmail()`
- `AuthService.reauthenticateWithGoogle()`
- `AuthService.reauthenticateWithApple()`

#### New Exception
- Added `RequiresRecentLoginException` for sensitive operations

### 🔧 Changed
- `LayouAuthSheet` now handles `CredentialAlreadyInUseException` intelligently
- `LayouEmailForm` now supports debug credential generation
- Enhanced error handling across all auth flows

### 📚 Documentation
- Comprehensive README with screenshots
- New ENHANCEMENTS.md detailing all new features
- New CONTRIBUTING.md with contribution guidelines
- Updated examples for all new features

### ⚡ Performance
- All callbacks are non-blocking
- Errors in callbacks are logged but don't affect main operations

---

## [1.0.0] - 2026-01-15

### 🎉 Initial Release

#### Core Features
- Firebase Auth support (Anonymous, Google, Apple, Email/Password)
- Account linking support for converting anonymous users
- Ready-to-use Riverpod providers
- Typed exceptions for error handling

#### UI Components
- `LayouAuthSheet` - Beautiful bottom sheet for auth flows
- `LayouAuthSection` - Inline section for settings pages
- `LayouGoogleButton` - Google sign-in button
- `LayouAppleButton` - Apple sign-in button (iOS/macOS)
- `LayouEmailButton` - Email/password button
- `LayouEmailForm` - Email/password form with validation

#### Customization
- Theme customization support
- String customization (i18n ready)
- Full builder pattern for custom UI
- Per-provider configuration options

#### Developer Experience
- Clean API with only 3 steps to integrate
- Comprehensive documentation
- Example app included
- TypeScript-like error handling with `AuthResult`

#### Providers
- `layouCurrentUserProvider` - Current authenticated user
- `layouAuthStateProvider` - Auth state stream
- `layouIsAuthenticatedProvider` - Authentication status
- `layouIsAnonymousProvider` - Anonymous status check
- `layouHasGoogleProvider` - Google linked status
- `layouHasAppleProvider` - Apple linked status
- `layouHasEmailProvider` - Email linked status
- `layouLinkedProvidersProvider` - All linked providers list
- `layouAuthActionsProvider` - Auth actions (sign in, link, sign out, delete)

---

## Links

- [Compare v1.0.0...v1.1.0](https://github.com/yourusername/layou_auth/compare/v1.0.0...v1.1.0)
- [Full Changelog](https://github.com/yourusername/layou_auth/blob/main/CHANGELOG.md)
