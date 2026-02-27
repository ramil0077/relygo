import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:relygo/services/cloudinary_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current user
  static User? get currentUser => _auth.currentUser;

  /// Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is logged in
  static bool get isLoggedIn => _auth.currentUser != null;

  /// Sign in with email and password
  static Future<Map<String, dynamic>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
   
    if (email.trim() == 'admin@relygo.com' && password == 'admin123') {
      if (!kIsWeb) {
        return {
          'success': false,
          'error': 'Admin access is only available on the web application. Please use a web browser.',
        };
      }
      return {
        'success': true,
        'user': null, 
        'userData': {
          'name': 'Admin User',
          'email': 'admin@relygo.com',
          'userType': 'admin',
          'status': 'approved',
        },
        'userType': 'admin',
      };
    }
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email.trim(), password: password);

      if (userCredential.user != null) {
        final DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          final Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;
          final userType = (userData['userType'] ?? 'user').toString();
          final status = (userData['status'] ?? '').toString();

          // Enforce platform restrictions
          if (userType.toLowerCase() == 'admin' && !kIsWeb) {
            await _auth.signOut();
            return {
              'success': false,
              'error': 'Admin access is restricted to the web application.',
            };
          }
          
          if ((userType.toLowerCase() == 'user' || userType.toLowerCase() == 'driver') && kIsWeb) {
            await _auth.signOut();
            return {
              'success': false,
              'error': 'Mobile app accounts (User/Driver) cannot log in on the web. Please use our mobile app.',
            };
          }

          if (userType.toLowerCase() == 'driver' &&
              status.toLowerCase() != 'approved') {
            await _auth.signOut();
            return {
              'success': false,
              'error':
                  'Your driver application is not approved yet. Please wait for admin approval.',
            };
          }
          return {
            'success': true,
            'user': userCredential.user,
            'userData': userData,
            'userType': userType,
          };
        } else {
          // New user or user without document - default to user type
          if (kIsWeb) {
             await _auth.signOut();
             return {
              'success': false,
              'error': 'Please use our mobile app for user/driver registration and access.',
            };
          }
          return {
            'success': true,
            'user': userCredential.user,
            'userData': {},
            'userType': 'user',
          };
        }
      } else {
        return {'success': false, 'error': 'Authentication failed'};
      }
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': _getAuthErrorMessage(e.code)};
    } catch (e) {
      return {'success': false, 'error': 'An unexpected error occurred: $e'};
    }
  }

  static Future<Map<String, dynamic>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String userType,
    Map<String, String>? documents,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      if (userCredential.user != null) {
        // Save user data to Firestore
        final Map<String, dynamic> userData = {
          'name': name.trim(),
          'email': email.trim(),
          'phone': phone.trim(),
          'userType': userType,
          'status': userType == 'driver' ? 'pending' : 'approved',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        // Add documents if provided
        if (documents != null && documents.isNotEmpty) {
          userData['documents'] = documents;
        }

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userData);

        return {
          'success': true,
          'user': userCredential.user,
          'userData': userData,
        };
      } else {
        return {'success': false, 'error': 'User creation failed'};
      }
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': _getAuthErrorMessage(e.code)};
    } catch (e) {
      return {'success': false, 'error': 'An unexpected error occurred: $e'};
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Reset password
  static Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return {
        'success': true,
        'message': 'Password reset email sent successfully',
      };
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': _getAuthErrorMessage(e.code)};
    } catch (e) {
      return {'success': false, 'error': 'An unexpected error occurred: $e'};
    }
  }

  /// Update user profile
  static Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    Map<String, String>? documents,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updateData['name'] = name.trim();
      if (phone != null) updateData['phone'] = phone.trim();
      if (documents != null) updateData['documents'] = documents;

      await _firestore.collection('users').doc(userId).update(updateData);

      return {'success': true, 'message': 'Profile updated successfully'};
    } catch (e) {
      return {'success': false, 'error': 'Failed to update profile: $e'};
    }
  }

  /// Upload user documents with Cloudinary
  static Future<Map<String, dynamic>> uploadUserDocuments({
    required String userId,
    required String userType,
    required Map<String, String> documentPaths,
  }) async {
    try {
      final Map<String, String> uploadedUrls = {};

      // Upload each document to Cloudinary
      for (String documentType in documentPaths.keys) {
        final String filePath = documentPaths[documentType]!;
        final String folder = 'relygo/$userType/$userId';

        final String? uploadedUrl = await CloudinaryService.uploadImage(
          File(filePath),
          folder,
        );

        if (uploadedUrl != null) {
          uploadedUrls[documentType] = uploadedUrl;
        }
      }

      if (uploadedUrls.isNotEmpty) {
        // Save URLs to Firestore
        final bool saved = await CloudinaryService.saveDocumentUrls(
          userId,
          userType,
          uploadedUrls,
        );

        if (saved) {
          return {
            'success': true,
            'message': 'Documents uploaded successfully',
            'uploadedUrls': uploadedUrls,
          };
        } else {
          return {
            'success': false,
            'error': 'Failed to save document URLs to database',
          };
        }
      } else {
        return {'success': false, 'error': 'Failed to upload documents'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error uploading documents: $e'};
    }
  }

  /// Get user data from Firestore
  static Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  /// Listen to auth state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get auth error message
  static String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
