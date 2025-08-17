import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatbytes_assignment/core/logger.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<User?> signUpWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
  AppLogger.info('AuthService: Signing up user with email: $email');
      
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      final User? user = result.user;
      
      if (user != null && displayName != null && displayName.isNotEmpty) {
        // Update display name if provided
        await user.updateDisplayName(displayName.trim());
        await user.reload();
      }
      
  AppLogger.info('AuthService: User signed up successfully: ${user?.uid}');
      return user;
    } on FirebaseAuthException catch (e) {
  AppLogger.error('AuthService: Sign up failed - ${e.code}: ${e.message}', e);
      throw _handleAuthException(e);
    } catch (e) {
  AppLogger.error('AuthService: Sign up error', e);
      throw Exception('An unexpected error occurred during sign up');
    }
  }

  // Sign in with email and password
  Future<User?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
  AppLogger.info('AuthService: Signing in user with email: $email');
      
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      final User? user = result.user;
  AppLogger.info('AuthService: User signed in successfully: ${user?.uid}');
      return user;
    } on FirebaseAuthException catch (e) {
  AppLogger.error('AuthService: Sign in failed - ${e.code}: ${e.message}', e);
      throw _handleAuthException(e);
    } catch (e) {
  AppLogger.error('AuthService: Sign in error', e);
      throw Exception('An unexpected error occurred during sign in');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
  AppLogger.info('AuthService: Signing out user: ${_auth.currentUser?.uid}');
      await _auth.signOut();
  AppLogger.info('AuthService: User signed out successfully');
    } catch (e) {
  AppLogger.error('AuthService: Sign out error', e);
      throw Exception('Failed to sign out');
    }
  }

  // Reset password
  Future<void> resetPassword({required String email}) async {
    try {
  AppLogger.info('AuthService: Sending password reset email to: $email');
      await _auth.sendPasswordResetEmail(email: email.trim());
  AppLogger.info('AuthService: Password reset email sent successfully');
    } on FirebaseAuthException catch (e) {
  AppLogger.error('AuthService: Password reset failed - ${e.code}: ${e.message}', e);
      throw _handleAuthException(e);
    } catch (e) {
  AppLogger.error('AuthService: Password reset error', e);
      throw Exception('Failed to send password reset email');
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }
      
  AppLogger.info('AuthService: Deleting account: ${user.uid}');
      await user.delete();
  AppLogger.info('AuthService: Account deleted successfully');
    } on FirebaseAuthException catch (e) {
  AppLogger.error('AuthService: Account deletion failed - ${e.code}: ${e.message}', e);
      throw _handleAuthException(e);
    } catch (e) {
  AppLogger.error('AuthService: Account deletion error', e);
      throw Exception('Failed to delete account');
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

  AppLogger.info('AuthService: Updating profile for user: ${user.uid}');
      
      if (displayName != null) {
        await user.updateDisplayName(displayName.trim());
      }
      
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }
      
      await user.reload();
  AppLogger.info('AuthService: Profile updated successfully');
    } on FirebaseAuthException catch (e) {
      AppLogger.error('AuthService: Profile update failed - ${e.code}: ${e.message}', e);
      throw _handleAuthException(e);
    } catch (e) {
      AppLogger.error('AuthService: Profile update error', e);
      throw Exception('Failed to update profile');
    }
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      AppLogger.info('AuthService: Changing password for user: ${user.uid}');

      // Re-authenticate user before changing password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      AppLogger.info('AuthService: Password changed successfully');
    } on FirebaseAuthException catch (e) {
      AppLogger.error('AuthService: Password change failed - ${e.code}: ${e.message}', e);
      throw _handleAuthException(e);
    } catch (e) {
      AppLogger.error('AuthService: Password change error', e);
      throw Exception('Failed to change password');
    }
  }

  // Handle Firebase Auth exceptions and provide user-friendly messages
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return Exception('Password is too weak. Please choose a stronger password.');
      case 'email-already-in-use':
        return Exception('An account already exists with this email address.');
      case 'invalid-email':
        return Exception('Please enter a valid email address.');
      case 'user-not-found':
        return Exception('No account found with this email address.');
      case 'wrong-password':
        return Exception('Incorrect password. Please try again.');
      case 'user-disabled':
        return Exception('This account has been disabled.');
      case 'too-many-requests':
        return Exception('Too many attempts. Please try again later.');
      case 'requires-recent-login':
        return Exception('Please log in again to perform this action.');
      case 'invalid-credential':
        return Exception('Invalid email or password.');
      case 'network-request-failed':
        return Exception('Network error. Please check your connection.');
      default:
        return Exception(e.message ?? 'Authentication failed');
    }
  }

  // Validation helpers
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPassword(String password) {
    // At least 6 characters
    return password.length >= 6;
  }

  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (!isValidPassword(password)) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Name is required';
    }
    if (name.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }
    return null;
  }
}
