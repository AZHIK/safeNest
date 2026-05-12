# Authentication System Refactoring - WhatsApp-Style Persistent Login

## Overview

This document describes the refinements made to the existing authentication system to implement WhatsApp-style persistent login behavior. The changes ensure users stay logged in indefinitely until manual logout, token expiration, or app uninstall.

## Changes Summary

### 1. Automatic Token Refresh in Dio Interceptor
**File:** `lib/core/api/api_interceptors.dart`

**Changes:**
- Enhanced `AuthInterceptor` to automatically handle 401 errors
- Implemented request queuing during token refresh to prevent race conditions
- Added logic to retry failed requests after successful token refresh
- Skips auth headers for refresh/logout endpoints to prevent circular calls

**Behavior:**
- When an API call returns 401, the interceptor automatically attempts to refresh the access token
- Concurrent requests during refresh are queued and retried after refresh completes
- If refresh fails, tokens are cleared and the error is propagated
- Prevents infinite retry loops with a refresh flag

### 2. Platform-Specific Uninstall Protection

#### Android
**File:** `android/app/src/main/AndroidManifest.xml`

**Changes:**
- Added `android:allowBackup="false"` to prevent app data backup
- Added `android:fullBackupContent="@xml/backup_rules"` reference

**File:** `android/app/src/main/res/xml/backup_rules.xml` (NEW)

**Changes:**
- Created backup rules to exclude secure storage data from backup
- Explicitly excludes `flutter_secure_storage.xml` and related auth data

**Behavior:**
- Tokens stored in secure storage will NOT survive app uninstall/reinstall
- Reinstalling the app requires fresh OTP authentication

#### iOS
**File:** `ios/Runner/Info.plist`

**Changes:**
- Added keychain access group configuration tied to app bundle identifier
- Set `synchronizable: false` to prevent iCloud sync

**Behavior:**
- Keychain data is tied to the app bundle identifier
- Data is deleted when the app is uninstalled
- No cross-device sync of authentication tokens

### 3. Token Storage Service Enhancement
**File:** `lib/core/services/token_storage_service.dart`

**Changes:**
- Added platform-specific secure storage configuration
- Android: Uses encrypted SharedPreferences
- iOS: Uses keychain with `first_unlock` accessibility
- Added `session_created` timestamp tracking
- Added `hasSession()` method for reinstall detection
- Added `deleteAll()` method for forced cleanup

**Behavior:**
- Tokens are stored with platform-appropriate security settings
- Session creation time is tracked for potential session age validation
- All token data is cleared on logout

### 4. Robust Session Restoration
**File:** `lib/features/auth/presentation/auth_controller.dart`

**Changes:**
- Enhanced `_loadSession()` with multi-layered session restoration
- Attempts silent token refresh if initial auth check fails
- Retries user fetch after successful token refresh
- Falls back gracefully to unauthenticated state on all failures

**Behavior:**
- App startup checks for valid tokens
- If access token is expired, attempts silent refresh
- If refresh succeeds, user is automatically logged in
- If refresh fails, user is sent to login screen
- No login screen flash - splash screen shows during auth check

### 5. Complete Logout Cleanup
**File:** `lib/features/auth/presentation/auth_controller.dart`

**Changes:**
- Enhanced `signOut()` method with complete state cleanup
- Added `_clearAuthState()` helper method
- Clears user data, phone number, and error state

**Behavior:**
- Logout calls backend to revoke session
- Clears all tokens from secure storage
- Resets all auth-related state
- Prevents back navigation to authenticated screens

### 6. Refresh Token Rotation Support
**File:** `lib/core/repositories/auth_repository.dart`

**Changes:**
- Enhanced `refreshAccessToken()` with refresh token rotation support
- Uses `RefreshTokenRequest` model for API calls
- Saves new refresh token if backend rotates it

**Behavior:**
- Supports backend refresh token rotation for enhanced security
- If backend returns new refresh token, it replaces the old one
- If backend returns same refresh token, it's still saved
- Maintains session continuity during refresh

## Authentication Flow

### First Login (OTP)
1. User enters phone number
2. User verifies OTP
3. Backend returns access token + refresh token
4. Tokens are securely stored
5. User navigates to dashboard

### Subsequent App Launches
1. App shows splash screen
2. AuthController checks secure storage for tokens
3. If access token valid → navigate to dashboard immediately
4. If access token expired:
   - Attempt silent refresh using refresh token
   - If refresh succeeds → navigate to dashboard
   - If refresh fails → clear tokens, navigate to login
5. No login screen flash during this process

### Logout
1. User taps logout
2. Backend session is revoked
3. All tokens cleared from secure storage
4. All auth state reset
5. User navigated to login screen
6. Back navigation prevented

### App Uninstall/Reinstall
1. User uninstalls app
2. All secure storage data is deleted (platform-specific)
3. User reinstalls app
4. No tokens exist in storage
5. App shows login screen
6. Fresh OTP authentication required

## Testing Checklist

### Basic Authentication Flow
- [ ] User can request OTP
- [ ] User can verify OTP and login
- [ ] User is navigated to dashboard after successful login
- [ ] User data is displayed correctly

### Persistent Login
- [ ] Close and reopen app - user stays logged in
- [ ] Force close app and reopen - user stays logged in
- [ ] Navigate away from app and return - user stays logged in
- [ ] Login screen does NOT flash before dashboard

### Token Refresh
- [ ] Wait for access token to expire (or manually invalidate)
- [ ] Make an API call that requires authentication
- [ ] Token is automatically refreshed in background
- [ ] API call succeeds with new token
- [ ] User remains logged in without interruption

### Concurrent Requests During Refresh
- [ ] Trigger token refresh by making multiple API calls simultaneously
- [ ] All requests are queued during refresh
- [ ] All requests are retried after refresh succeeds
- [ ] No requests fail due to 401 after refresh

### Logout
- [ ] User can logout successfully
- [ ] Tokens are cleared from secure storage
- [ ] User is navigated to login screen
- [ ] Back navigation does not return to authenticated screens
- [ ] Subsequent app launch shows login screen

### App Uninstall/Reinstall
- [ ] Login with OTP
- [ ] Uninstall the app
- [ ] Reinstall the app
- [ ] App shows login screen (not dashboard)
- [ ] Fresh OTP authentication is required

### Network Scenarios
- [ ] App launches with no network - shows login if no valid token
- [ ] App launches with network but backend unavailable - handles gracefully
- [ ] Token refresh fails due to network error - clears tokens, shows login
- [ ] API call fails during refresh - request is queued and retried

## Migration Steps

### For Existing Users
No migration needed. Existing authentication flow continues to work. The enhancements are backward compatible.

### For Developers
1. Review the changes in the modified files
2. Test the authentication flow thoroughly
3. Verify platform-specific uninstall protection
4. Test token refresh behavior
5. Test logout cleanup

## Backend Requirements

The backend should support:
- `POST /auth/refresh` - Refresh access token (optionally rotate refresh token)
- `POST /auth/logout` - Revoke refresh token/session
- Return `access_token`, `refresh_token`, `expires_in`, and `user` in token response

## Security Considerations

1. **Token Storage:** All tokens are stored using `flutter_secure_storage` with platform-appropriate encryption
2. **Refresh Token Rotation:** Backend can rotate refresh tokens for enhanced security
3. **No Backup:** Tokens are excluded from app backups on both platforms
4. **Session Revocation:** Logout calls backend to revoke session
5. **Automatic Cleanup:** Failed refresh attempts clear local tokens

## Troubleshooting

### User stays logged in after logout
- Verify backend logout endpoint is working
- Check that `_tokenStorage.clearTokens()` is called
- Verify auth state is reset in AuthController

### Login screen flashes before dashboard
- Check that splash screen is shown during auth check
- Verify `_loadSession()` completes before navigation
- Ensure router redirect logic is correct

### Tokens persist after app reinstall
- Android: Verify `android:allowBackup="false"` is set
- Android: Verify backup rules exclude secure storage
- iOS: Verify keychain access group is tied to app bundle

### Token refresh not working
- Verify refresh endpoint is correct in API constants
- Check that refresh token is being stored correctly
- Verify backend returns new tokens on refresh
- Check interceptor logs for 401 handling

## Modified Files

1. `lib/core/api/api_interceptors.dart` - Automatic token refresh
2. `lib/core/services/token_storage_service.dart` - Platform-specific storage
3. `lib/core/repositories/auth_repository.dart` - Refresh token rotation
4. `lib/features/auth/presentation/auth_controller.dart` - Session restoration & logout
5. `android/app/src/main/AndroidManifest.xml` - Backup prevention
6. `android/app/src/main/res/xml/backup_rules.xml` - Backup rules (NEW)
7. `ios/Runner/Info.plist` - Keychain configuration

## Next Steps

1. Thoroughly test all authentication flows
2. Verify platform-specific uninstall protection
3. Test with actual backend to ensure token refresh works
4. Monitor for any edge cases or issues in production
5. Consider adding analytics for auth failures if needed
