import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  static User? get currentUser {
    try {
      return FirebaseAuth.instance.currentUser;
    } catch (_) {
      return null;
    }
  }

  static Stream<User?> get authStateChanges {
    try {
      return FirebaseAuth.instance.authStateChanges();
    } catch (_) {
      return const Stream.empty();
    }
  }

  // ==========================================
  // AUTHENTICATION SERVICES
  // ==========================================

  /// Register a new reader or admin user with Firebase Auth
  static Future<UserCredential> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
    String role = 'reader', // 'reader' or 'admin'
  }) async {
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        // Update Firebase Auth display name
        await user.updateDisplayName(name.trim());
        await user.reload();

        // Save custom profile in Cloud Firestore
        try {
          await firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'name': name.trim(),
            'email': email.trim().toLowerCase(),
            'role': role,
            'title': role == 'admin' ? 'Chief Archival Curator' : 'Avid Reader',
            'createdAt': FieldValue.serverTimestamp(),
            'favoriteGenres': ['Technology', 'Philosophy'],
            'dailyTargetMinutes': 25,
            'booksCompleted': 0,
            'streakDays': 1,
            'avatarUrl': user.photoURL ?? '',
          }, SetOptions(merge: true));
        } catch (firestoreError) {
          debugPrint('Firestore profile save notice: $firestoreError');
        }
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth SignUp Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected SignUp Error: $e');
      rethrow;
    }
  }

  /// Sign in an existing user with Firebase Auth
  static Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth SignIn Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected SignIn Error: $e');
      rethrow;
    }
  }

  /// Send a password reset email via Firebase Auth
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Password Reset Error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Sign out the current user
  static Future<void> signOut() async {
    try {
      await auth.signOut();
    } catch (e) {
      debugPrint('Firebase SignOut Error: $e');
    }
  }

  /// Fetch user profile from Cloud Firestore
  static Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }
    } catch (e) {
      debugPrint('Error fetching Firestore user profile: $e');
    }
    return null;
  }

  /// Update user profile in Cloud Firestore
  static Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? title,
    String? avatarUrl,
    int? dailyTargetMinutes,
    List<String>? favoriteGenres,
  }) async {
    final Map<String, dynamic> updates = {};
    if (name != null && name.trim().isNotEmpty) updates['name'] = name.trim();
    if (title != null && title.trim().isNotEmpty) updates['title'] = title.trim();
    if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;
    if (dailyTargetMinutes != null) updates['dailyTargetMinutes'] = dailyTargetMinutes;
    if (favoriteGenres != null) updates['favoriteGenres'] = favoriteGenres;

    if (updates.isNotEmpty) {
      try {
        await firestore.collection('users').doc(uid).set(updates, SetOptions(merge: true));
        if (name != null && currentUser != null) {
          await currentUser!.updateDisplayName(name.trim());
        }
        if (avatarUrl != null && currentUser != null) {
          await currentUser!.updatePhotoURL(avatarUrl);
        }
      } catch (e) {
        debugPrint('Error updating Firestore profile: $e');
      }
    }
  }

  // ==========================================
  // FIREBASE STORAGE SERVICES
  // ==========================================

  /// Upload raw image bytes to Firebase Storage and retrieve the public download URL
  static Future<String> uploadImageBytes({
    required Uint8List bytes,
    required String storagePath,
    String contentType = 'image/jpeg',
  }) async {
    try {
      final ref = storage.ref().child(storagePath);
      final metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: {'uploadedAt': DateTime.now().toIso8601String()},
      );

      final uploadTask = await ref.putData(bytes, metadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      debugPrint('Firebase Storage Upload Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected Storage Error: $e');
      rethrow;
    }
  }

  /// Upload a user avatar to Firebase Storage
  static Future<String> uploadUserAvatar({
    required String uid,
    required Uint8List bytes,
    String fileExtension = 'jpg',
  }) async {
    final path = 'avatars/${uid}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
    return await uploadImageBytes(
      bytes: bytes,
      storagePath: path,
      contentType: 'image/$fileExtension',
    );
  }

  /// Upload a book cover to Firebase Storage
  static Future<String> uploadBookCover({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final cleanName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final path = 'book_covers/${DateTime.now().millisecondsSinceEpoch}_$cleanName';
    return await uploadImageBytes(
      bytes: bytes,
      storagePath: path,
      contentType: 'image/jpeg',
    );
  }
}
