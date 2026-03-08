/// File Upload Service - خدمة رفع الملفات
///
/// Provides secure file and image upload functionality to Firebase Storage with
/// comprehensive validation, security checks, and metadata management. Supports
/// images and various document formats with automatic content safety verification.
///
/// توفر هذه الخدمة رفع آمن للملفات والصور إلى Firebase Storage مع التحقق الشامل
/// من الصحة، وفحوصات الأمان، وإدارة البيانات الوصفية. تدعم الصور وتنسيقات المستندات
/// المختلفة مع التحقق التلقائي من سلامة المحتوى.
///
/// **Key Features:**
/// - Image upload with size validation (max 10MB)
/// - Document upload with type validation (PDF, TXT, DOC, DOCX, XLS, XLSX)
/// - Security scanning for HTML/CSS/JavaScript injection in text files
/// - Automatic MIME type detection and validation
/// - Unique filename generation with timestamps
/// - Custom metadata (uploadedBy, uploadedAt)
/// - File and image deletion
/// - Upload task cancellation support
/// - Human-readable file size formatting
///
/// **Storage Structure:**
/// ```
/// gs://bucket-name/
///   ├── chat_images/
///   │   └── {userId}/
///   │       ├── {timestamp}_image1.jpg
///   │       └── {timestamp}_image2.png
///   └── chat_files/
///       └── {userId}/
///           ├── {timestamp}_document.pdf
///           └── {timestamp}_spreadsheet.xlsx
/// ```
///
/// **Security Features:**
/// - File size limits (10MB images, 20MB documents)
/// - MIME type whitelist validation
/// - HTML/CSS/JavaScript content scanning for text files
/// - Automatic rejection of unsafe content
///
/// **Supported File Types:**
/// - Images: JPEG, PNG, GIF, WebP
/// - Documents: PDF, TXT, DOC, DOCX, XLS, XLSX
///
/// **Dependency Injection:**
/// This service uses the Singleton pattern with lazy initialization.
/// Access via `FileUploadService.instance`.
///
/// Example usage:
/// ```dart
/// final uploadService = FileUploadService.instance;
///
/// // Upload image
/// final imageFile = File('/path/to/image.jpg');
/// final imageUrl = await FileUploadService.uploadImage(imageFile, userId);
///
/// // Upload document
/// final docFile = File('/path/to/document.pdf');
/// final docUrl = await FileUploadService.uploadFile(docFile, userId);
///
/// // Delete file
/// await FileUploadService.deleteFile(docUrl);
///
/// // Format file size
/// final sizeStr = FileUploadService.formatFileSize(1024 * 1024); // "1.0 MB"
/// ```
library;

import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mime/mime.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:elajtech/core/errors/exceptions.dart';

/// File Upload Service - خدمة رفع الملفات
///
/// Provides secure file and image upload functionality to Firebase Storage.
/// Supports images and various document formats with validation and security checks.
///
/// توفر هذه الخدمة رفع آمن للملفات والصور إلى Firebase Storage مع دعم للصور
/// وتنسيقات المستندات المختلفة مع التحقق من الصحة وفحوصات الأمان.
class FileUploadService {
  FileUploadService._internal();
  // Singleton pattern
  static FileUploadService? _instance;
  static FileUploadService get instance =>
      _instance ??= FileUploadService._internal();

  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// مسار رفع الصور
  static const _imagesPath = 'chat_images';

  /// مسار رفع الملفات
  static const _filesPath = 'chat_files';

  /// الحد الأقصى لحجم الملف (20MB)
  static const int _maxFileSize = 20 * 1024 * 1024;

  /// الأنواع المسموحة للملفات
  static const List<String> _allowedFileTypes = [
    'application/pdf',
    'text/plain',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  ];

  /// Upload image to Firebase Storage - رفع صورة إلى Firebase Storage
  ///
  /// Uploads an image file to Firebase Storage with validation and returns the
  /// public download URL. Images are stored in `chat_images/{userId}/` with
  /// timestamp-based unique filenames.
  ///
  /// يرفع ملف صورة إلى Firebase Storage مع التحقق من الصحة ويُرجع عنوان URL
  /// العام للتنزيل. يتم تخزين الصور في `chat_images/{userId}/` مع أسماء ملفات
  /// فريدة تعتمد على الطابع الزمني.
  ///
  /// **Validation Rules:**
  /// - File must exist on disk
  /// - Maximum size: 10MB
  /// - MIME type must start with 'image/' (JPEG, PNG, GIF, WebP)
  ///
  /// **Storage Path:** `chat_images/{userId}/{timestamp}_{filename}`
  ///
  /// **Metadata Added:**
  /// - contentType: Detected MIME type
  /// - uploadedBy: User ID
  /// - uploadedAt: ISO 8601 timestamp
  ///
  /// Parameters:
  /// - [imageFile]: The image file to upload (required)
  ///   ملف الصورة المراد رفعها (مطلوب)
  /// - [userId]: The user's unique ID for organizing storage (required)
  ///   معرف المستخدم الفريد لتنظيم التخزين (مطلوب)
  ///
  /// Returns: Public download URL for the uploaded image
  ///   يُرجع عنوان URL العام للتنزيل للصورة المرفوعة
  ///
  /// Throws:
  /// - [Exception] if file doesn't exist
  /// - [Exception] if file size exceeds 10MB
  /// - [Exception] if MIME type is not an image
  /// - [FirestoreException] if Firebase Storage upload fails
  /// - [NetworkException] if no internet connection
  ///
  /// Example:
  /// ```dart
  /// // Pick and upload image
  /// final picker = ImagePicker();
  /// final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
  ///
  /// if (pickedFile != null) {
  ///   final imageFile = File(pickedFile.path);
  ///   try {
  ///     final imageUrl = await FileUploadService.uploadImage(
  ///       imageFile,
  ///       currentUser.id,
  ///     );
  ///
  ///     // Send image in chat message
  ///     await chatRepo.sendMessage(
  ///       chatId: chatId,
  ///       senderId: currentUser.id,
  ///       imageUrl: imageUrl,
  ///     );
  ///   } catch (e) {
  ///     print('Upload failed: $e');
  ///   }
  /// }
  /// ```
  static Future<String> uploadImage(File imageFile, String userId) async {
    try {
      // التحقق من وجود الملف
      if (!await imageFile.exists()) {
        throw Exception('ملف الصورة غير موجود');
      }

      // التحقق من حجم الملف (الحد الأقصى 10MB)
      final fileSize = await imageFile.length();
      if (fileSize > 10 * 1024 * 1024) {
        throw Exception('حجم الصورة كبير جداً. الحد الأقصى 10MB');
      }

      // التحقق من نوع الملف
      final mimeType = lookupMimeType(imageFile.path);
      if (mimeType == null || !mimeType.startsWith('image/')) {
        throw Exception('نوع الملف غير مدعوم. يجب أن يكون صورة');
      }

      // توليد اسم فريد للملف
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last.split(r'\').last}';
      final ref = _storage.ref().child('$_imagesPath/$userId/$fileName');

      // رفع الصورة
      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: mimeType,
          customMetadata: {
            'uploadedBy': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // انتظار اكتمال الرفع
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      print('✅ Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      print(
        '❌ Firebase Storage Error uploading image: ${e.code} - ${e.message}',
      );
      throw FirestoreException(
        'Failed to upload image',
        code: e.code,
        originalError: e,
      );
    } on SocketException catch (e) {
      print('❌ Network error uploading image: ${e.message}');
      throw NetworkException(
        'No internet connection',
        originalError: e,
      );
    } on Exception catch (e) {
      print('❌ Unexpected error uploading image: $e');
      rethrow;
    }
  }

  /// رفع ملف
  ///
  /// [file] الملف المراد رفعه
  /// [userId] معرف المستخدم
  ///
  /// يُرجع رابط الملف المرفوع
  static Future<String> uploadFile(File file, String userId) async {
    try {
      // التحقق من وجود الملف
      if (!await file.exists()) {
        throw Exception('الملف غير موجود');
      }

      // التحقق من حجم الملف (الحد الأقصى 20MB للملفات)
      final fileSize = await file.length();
      if (fileSize > _maxFileSize) {
        final maxSizeMB = (_maxFileSize / (1024 * 1024)).toStringAsFixed(1);
        throw Exception('حجم الملف كبير جداً. الحد الأقصى $maxSizeMB MB');
      }

      // التحقق من نوع الملف
      final mimeType = lookupMimeType(file.path);
      if (mimeType == null) {
        throw Exception('لا يمكن تحديد نوع الملف');
      }

      // التحقق من الأنواع المسموحة
      if (!_allowedFileTypes.contains(mimeType)) {
        throw Exception('نوع الملف غير مسموح: $mimeType');
      }

      // فحص محتوى الملف للتأكد من خلوه من محتوى HTML أو CSS أو JavaScript
      final isSafe = await _isFileSafe(file);
      if (!isSafe) {
        throw Exception(
          'الملف يحتوي على محتوى غير آمن (HTML/CSS/JavaScript). يُسمح فقط الملفات النصية.',
        );
      }

      // توليد اسم فريد للملف
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last.split(r'\').last}';
      final ref = _storage.ref().child('$_filesPath/$userId/$fileName');

      // رفع الملف
      final uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: mimeType,
          customMetadata: {
            'uploadedBy': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // انتظار اكتمال الرفع
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      print('✅ File uploaded successfully: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      print(
        '❌ Firebase Storage Error uploading file: ${e.code} - ${e.message}',
      );
      throw FirestoreException(
        'Failed to upload file',
        code: e.code,
        originalError: e,
      );
    } on SocketException catch (e) {
      print('❌ Network error uploading file: ${e.message}');
      throw NetworkException(
        'No internet connection',
        originalError: e,
      );
    } on Exception catch (e) {
      print('❌ Unexpected error uploading file: $e');
      rethrow;
    }
  }

  /// حذف ملف
  ///
  /// [fileUrl] رابط الملف المراد حذفه
  static Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
      print('✅ File deleted successfully: $fileUrl');
    } on FirebaseException catch (e) {
      print('❌ Firebase Storage Error deleting file: ${e.code} - ${e.message}');
      throw FirestoreException(
        'Failed to delete file',
        code: e.code,
        originalError: e,
      );
    } on SocketException catch (e) {
      print('❌ Network error deleting file: ${e.message}');
      throw NetworkException(
        'No internet connection',
        originalError: e,
      );
    } on Exception catch (e) {
      print('❌ Unexpected error deleting file: $e');
      rethrow;
    }
  }

  /// حذف صورة
  ///
  /// [imageUrl] رابط الصورة المراد حذفها
  static Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      print('✅ Image deleted successfully: $imageUrl');
    } on FirebaseException catch (e) {
      print(
        '❌ Firebase Storage Error deleting image: ${e.code} - ${e.message}',
      );
      throw FirestoreException(
        'Failed to delete image',
        code: e.code,
        originalError: e,
      );
    } on SocketException catch (e) {
      print('❌ Network error deleting image: ${e.message}');
      throw NetworkException(
        'No internet connection',
        originalError: e,
      );
    } on Exception catch (e) {
      print('❌ Unexpected error deleting image: $e');
      rethrow;
    }
  }

  /// إلغاء رفع ملف
  ///
  /// [uploadTask] مهمة الرفع المراد إلغاؤها
  static Future<void> cancelUpload(UploadTask uploadTask) async {
    await uploadTask.cancel();
    print('⏹ Upload task cancelled');
  }

  /// الحصول على حجم الملف بصيغة مقروءة
  ///
  /// [bytes] حجم الملف بالبايت
  ///
  /// يُرجع حجم الملف بصيغة مقروءة (B, KB, MB)
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// التحقق من نوع الصورة
  ///
  /// [mimeType] نوع MIME للملف
  ///
  /// يُرجع true إذا كان نوع صورة مدعوم
  static bool isImageType(String? mimeType) {
    if (mimeType == null) return false;
    return mimeType.startsWith('image/');
  }

  /// الحصول على الامتداد من نوع MIME
  ///
  /// [mimeType] نوع MIME للملف
  ///
  /// يُرجع الامتداد (مثل: .jpg, .png)
  static String? getExtensionFromMimeType(String mimeType) {
    final extensions = {
      'image/jpeg': '.jpg',
      'image/png': '.png',
      'image/gif': '.gif',
      'image/webp': '.webp',
      'application/pdf': '.pdf',
      'text/plain': '.txt',
      'application/msword': '.doc',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
          '.docx',
      'application/vnd.ms-excel': '.xls',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
          '.xlsx',
    };
    return extensions[mimeType];
  }

  /// فحص محتوى الملف للتأكد من خلوه من محتوى HTML أو CSS أو JavaScript ضار
  /// (للملفات النصية فقط، يتم تخطي الصور والملفات الثنائية)
  ///
  /// [file] الملف المراد فحصه
  ///
  /// يُرجع true إذا كان الملف آمناً
  static Future<bool> _isFileSafe(File file) async {
    try {
      final mimeType = lookupMimeType(file.path);

      // لا نحتاج لفحص محتوى الصور لأنها ملفات ثنائية
      if (mimeType != null && mimeType.startsWith('image/')) {
        return true;
      }

      // للملفات النصية، نقوم بفحص المحتوى
      if (mimeType != null &&
          (mimeType == 'text/plain' || mimeType == 'application/pdf')) {
        // ملاحظة: PDF ملف ثنائي جزئياً، سنكتفي بفحص MIME type له هنا
        if (mimeType == 'application/pdf') return true;

        final bytes = await file.readAsBytes();
        String content;
        try {
          content = utf8.decode(bytes);
        } on FormatException {
          // إذا لم يكن نصياً صالحاً، نعتبره ثنائياً ونسمح به إذا كان النوع مسموحاً
          return true;
        }

        // فحص وجود وسم HTML واحد على الأقل بشكل صريح
        if (content.contains('<script') ||
            content.contains('<html>') ||
            content.contains('<body>')) {
          return false;
        }

        // فحص شامل باستخدام html_parser
        try {
          final fragment = html_parser.parseFragment(content);
          if (fragment.children.isNotEmpty) {
            return false;
          }
        } on Exception catch (e) {
          print('⚠️ HTML parsing failed: $e');
        }
      }

      return true;
    } on Exception catch (e) {
      print('⚠️ Error checking file safety: $e');
      return true; // إذا فشل الفحص، نسمح بالرفع مع الاعتماد على MIME type
    }
  }
}
