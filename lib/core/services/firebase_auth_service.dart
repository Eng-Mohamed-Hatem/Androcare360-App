import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Authentication Service - User Authentication Management
///
/// Provides a simplified interface for Firebase Authentication operations.
/// Handles user registration, login, logout, and profile management.
///
/// **Key Features:**
/// - Email/password authentication
/// - User session management
/// - Password reset functionality
/// - Profile updates (display name)
/// - Auth state change monitoring
///
/// **Authentication Flow:**
/// 1. Sign up new users with email/password
/// 2. Sign in existing users
/// 3. Monitor auth state changes
/// 4. Sign out when needed
///
/// **Static Service Pattern:**
/// This service uses static methods for global access without instantiation.
/// All methods interact directly with FirebaseAuth instance.
///
/// Example usage:
/// ```dart
/// // Sign up new user
/// final credential = await FirebaseAuthService.signUp(
///   email: 'user@example.com',
///   password: 'securePassword123',
/// );
///
/// // Sign in existing user
/// await FirebaseAuthService.signIn(
///   email: 'user@example.com',
///   password: 'securePassword123',
/// );
///
/// // Check if user is logged in
/// if (FirebaseAuthService.isLoggedIn) {
///   print('User ID: ${FirebaseAuthService.currentUserId}');
/// }
///
/// // Listen to auth state changes
/// FirebaseAuthService.authStateChanges.listen((user) {
///   if (user != null) {
///     print('User signed in: ${user.email}');
///   } else {
///     print('User signed out');
///   }
/// });
///
/// // Sign out
/// await FirebaseAuthService.signOut();
/// ```
class FirebaseAuthService {
  /// Firebase Auth instance
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current authenticated user
  ///
  /// Returns the currently signed-in [User] or null if no user is signed in.
  ///
  /// Example:
  /// ```dart
  /// final user = FirebaseAuthService.currentUser;
  /// if (user != null) {
  ///   print('Email: ${user.email}');
  /// }
  /// ```
  static User? get currentUser => _auth.currentUser;

  /// Get current user ID
  ///
  /// Returns the UID of the currently signed-in user or null if no user is signed in.
  ///
  /// Example:
  /// ```dart
  /// final userId = FirebaseAuthService.currentUserId;
  /// ```
  static String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is logged in
  ///
  /// Returns true if a user is currently signed in, false otherwise.
  ///
  /// Example:
  /// ```dart
  /// if (FirebaseAuthService.isLoggedIn) {
  ///   // Navigate to home screen
  /// } else {
  ///   // Navigate to login screen
  /// }
  /// ```
  static bool get isLoggedIn => _auth.currentUser != null;

  /// Sign up with email and password
  ///
  /// Creates a new user account with the provided email and password.
  ///
  /// Parameters:
  /// - [email]: User's email address (required)
  /// - [password]: User's password (required, minimum 6 characters)
  ///
  /// Returns: [UserCredential] containing the newly created user
  ///
  /// Throws:
  /// - [FirebaseAuthException] if sign up fails (e.g., email already in use, weak password)
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final credential = await FirebaseAuthService.signUp(
  ///     email: 'newuser@example.com',
  ///     password: 'securePassword123',
  ///   );
  ///   print('User created: ${credential.user?.uid}');
  /// } on FirebaseAuthException catch (e) {
  ///   print('Sign up failed: ${e.message}');
  /// }
  /// ```
  static Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async => _auth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );

  /// Sign in with email and password
  ///
  /// Authenticates an existing user with their email and password.
  ///
  /// Parameters:
  /// - [email]: User's email address (required)
  /// - [password]: User's password (required)
  ///
  /// Returns: [UserCredential] containing the authenticated user
  ///
  /// Throws:
  /// - [FirebaseAuthException] if sign in fails (e.g., wrong password, user not found)
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final credential = await FirebaseAuthService.signIn(
  ///     email: 'user@example.com',
  ///     password: 'password123',
  ///   );
  ///   print('Signed in: ${credential.user?.email}');
  /// } on FirebaseAuthException catch (e) {
  ///   if (e.code == 'user-not-found') {
  ///     print('No user found for that email');
  ///   } else if (e.code == 'wrong-password') {
  ///     print('Wrong password provided');
  ///   }
  /// }
  /// ```
  static Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async => _auth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );

  /// Sign out current user
  ///
  /// Signs out the currently authenticated user and clears the session.
  ///
  /// Example:
  /// ```dart
  /// await FirebaseAuthService.signOut();
  /// // Navigate to login screen
  /// ```
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Listen to authentication state changes
  ///
  /// Returns a stream that emits the current [User] whenever the authentication
  /// state changes (sign in, sign out, token refresh).
  ///
  /// Returns: Stream of [User?] - emits user when signed in, null when signed out
  ///
  /// Example:
  /// ```dart
  /// FirebaseAuthService.authStateChanges.listen((user) {
  ///   if (user != null) {
  ///     print('User is signed in: ${user.email}');
  ///     // Navigate to home screen
  ///   } else {
  ///     print('User is signed out');
  ///     // Navigate to login screen
  ///   }
  /// });
  /// ```
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Send password reset email
  ///
  /// Sends a password reset email to the specified email address.
  /// The user will receive an email with a link to reset their password.
  ///
  /// Parameters:
  /// - [email]: Email address to send reset link to (required)
  ///
  /// Throws:
  /// - [FirebaseAuthException] if email is invalid or user not found
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await FirebaseAuthService.sendPasswordResetEmail('user@example.com');
  ///   print('Password reset email sent');
  /// } on FirebaseAuthException catch (e) {
  ///   print('Failed to send reset email: ${e.message}');
  /// }
  /// ```
  static Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Update user display name
  ///
  /// Updates the display name of the currently signed-in user.
  ///
  /// Parameters:
  /// - [displayName]: New display name for the user (required)
  ///
  /// Note: This only updates the display name in Firebase Auth.
  /// User profile in Firestore should be updated separately.
  ///
  /// Example:
  /// ```dart
  /// await FirebaseAuthService.updateDisplayName('Dr. Ahmed Ali');
  /// print('Display name updated');
  /// ```
  static Future<void> updateDisplayName(String displayName) async {
    await _auth.currentUser?.updateDisplayName(displayName);
  }
}
