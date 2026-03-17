import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';

/// Storage Service - خدمة التخزين السحابي
///
/// Manages file uploads and deletions in Firebase Cloud Storage for the elajtech
/// application. Currently handles profile image storage with automatic path
/// organization and URL generation.
///
/// تدير تحميل الملفات وحذفها في Firebase Cloud Storage لتطبيق elajtech.
/// تتعامل حالياً مع تخزين صور الملف الشخصي مع تنظيم المسار التلقائي وإنشاء عناوين URL.
///
/// **Key Features:**
/// - Profile image upload to Firebase Storage
/// - Automatic file path organization (profile_images/{userId}.jpg)
/// - Download URL generation for uploaded files
/// - Safe profile image deletion with error handling
/// - Automatic file overwrite for existing profile images
///
/// **Storage Structure:**
/// ```text
/// gs://bucket-name/
///   └── profile_images/
///       ├── user123.jpg
///       ├── user456.jpg
///       └── ...
/// ```
///
/// **Dependency Injection:**
/// This service uses direct instantiation of FirebaseStorage.instance.
/// Can be registered with GetIt for dependency injection if needed.
///
/// **Error Handling:**
/// - Upload failures throw exceptions with Arabic error messages
/// - Delete operations silently ignore missing files
///
/// Example usage:
/// ```dart
/// final storageService = StorageService();
///
/// // Upload profile image
/// final imageFile = File('/path/to/image.jpg');
/// final imageUrl = await storageService.uploadProfileImage(imageFile, userId);
///
/// // Update user profile with new image URL
/// await userRepo.updateUser(userId, {'profileImageUrl': imageUrl});
///
/// // Delete old profile image
/// if (oldImageUrl != null) {
///   await storageService.deleteProfileImage(oldImageUrl);
/// }
/// ```
@lazySingleton
class StorageService {
  StorageService(this._storage);
  final FirebaseStorage _storage;

  /// Upload profile image to Firebase Storage - رفع صورة الملف الشخصي إلى Firebase Storage
  ///
  /// Uploads a user's profile image to Firebase Cloud Storage and returns the
  /// public download URL. The image is stored at `profile_images/{userId}.jpg`.
  /// If a profile image already exists for this user, it will be automatically
  /// overwritten.
  ///
  /// يرفع صورة الملف الشخصي للمستخدم إلى Firebase Cloud Storage ويُرجع عنوان URL
  /// العام للتنزيل. يتم تخزين الصورة في `profile_images/{userId}.jpg`. إذا كانت
  /// صورة الملف الشخصي موجودة بالفعل لهذا المستخدم، فسيتم استبدالها تلقائياً.
  ///
  /// **Storage Path:** `gs://bucket-name/profile_images/{userId}.jpg`
  ///
  /// **File Format:** Always saved as .jpg regardless of original format
  ///
  /// Parameters:
  /// - [file]: The image file to upload (required)
  ///   ملف الصورة المراد رفعه (مطلوب)
  /// - [userId]: The user's unique ID for organizing storage (required)
  ///   معرف المستخدم الفريد لتنظيم التخزين (مطلوب)
  ///
  /// Returns: Public download URL for the uploaded image
  ///   يُرجع عنوان URL العام للتنزيل للصورة المرفوعة
  ///
  /// Throws:
  /// - [Exception] with Arabic message if upload fails
  ///   يرمي استثناء برسالة عربية إذا فشل الرفع
  ///
  /// **Performance Note:** Upload time depends on file size and network speed.
  /// Consider compressing images before upload for better performance.
  ///
  /// Example:
  /// ```dart
  /// final storageService = StorageService();
  /// final picker = ImagePicker();
  ///
  /// // Pick image from gallery
  /// final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  /// if (image != null) {
  ///   final imageFile = File(image.path);
  ///
  ///   // Upload to Firebase Storage
  ///   try {
  ///     final imageUrl = await storageService.uploadProfileImage(
  ///       imageFile,
  ///       currentUser.id,
  ///     );
  ///
  ///     // Update user profile
  ///     await userRepo.updateProfileImage(currentUser.id, imageUrl);
  ///     print('Profile image updated: $imageUrl');
  ///   } catch (e) {
  ///     print('Upload failed: $e');
  ///   }
  /// }
  /// ```
  Future<String> uploadProfileImage(File file, String userId) async {
    try {
      // Create a reference to the location
      final ref = _storage.ref().child('profile_images').child('$userId.jpg');

      // Upload the file
      await ref.putFile(file);

      // Get the download URL
      final url = await ref.getDownloadURL();
      return url;
    } on Exception catch (e) {
      throw Exception('فشل في رفع الصورة: $e');
    }
  }

  /// Delete profile image from Firebase Storage - حذف صورة الملف الشخصي من Firebase Storage
  ///
  /// Deletes a profile image from Firebase Cloud Storage using its download URL.
  /// This method is safe to call even if the image doesn't exist - it will silently
  /// ignore deletion errors to prevent app crashes from missing files.
  ///
  /// يحذف صورة الملف الشخصي من Firebase Cloud Storage باستخدام عنوان URL الخاص
  /// بالتنزيل. هذه الطريقة آمنة للاستدعاء حتى لو لم تكن الصورة موجودة - ستتجاهل
  /// أخطاء الحذف بصمت لمنع تعطل التطبيق من الملفات المفقودة.
  ///
  /// **Use Cases:**
  /// - User updates profile image (delete old, upload new)
  /// - User removes profile image
  /// - Cleanup during account deletion
  ///
  /// Parameters:
  /// - [imageUrl]: The full Firebase Storage download URL of the image to delete (required)
  ///   عنوان URL الكامل لتنزيل Firebase Storage للصورة المراد حذفها (مطلوب)
  ///
  /// **Error Handling:**
  /// - Silently ignores exceptions (e.g., file not found, permission denied)
  /// - Does not throw exceptions to prevent disrupting user flows
  ///
  /// **Important:** This method uses `refFromURL()` which requires a full Firebase
  /// Storage URL (gs://... or https://firebasestorage.googleapis.com/...).
  ///
  /// Example:
  /// ```dart
  /// final storageService = StorageService();
  ///
  /// // User updates profile image
  /// final oldImageUrl = user.profileImageUrl;
  /// final newImageFile = await pickNewImage();
  ///
  /// // Upload new image
  /// final newImageUrl = await storageService.uploadProfileImage(
  ///   newImageFile,
  ///   user.id,
  /// );
  ///
  /// // Delete old image (safe even if URL is invalid or file missing)
  /// if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
  ///   await storageService.deleteProfileImage(oldImageUrl);
  /// }
  ///
  /// // Update user profile with new URL
  /// await userRepo.updateProfileImage(user.id, newImageUrl);
  /// ```
  Future<void> deleteProfileImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } on Exception catch (_) {
      // Ignore if image doesn't exist
    }
  }
}
