package com.example.elajtech

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest

/**
 * MainActivity مع MethodChannel لاستخراج SHA-256 Fingerprint
 * 
 * هذا الكود يوفر قناة اتصال بين Flutter و Android Native
 * لاستخراج بصمة SHA-256 المطلوبة لـ Zoom Marketplace
 */
class MainActivity : FlutterFragmentActivity() {
    
    private val CHANNEL = "com.elajtech.androcare/signature"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        registerIncomingCallsChannel()
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSHA256" -> {
                    try {
                        val sha256 = getAppSignatureSHA256()
                        result.success(sha256)
                    } catch (e: Exception) {
                        result.error("SIGNATURE_ERROR", "Failed to get SHA-256: ${e.message}", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun registerIncomingCallsChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return
        }

        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (manager.getNotificationChannel("incoming_calls") != null) {
            return
        }

        val channel = NotificationChannel(
            "incoming_calls",
            "Incoming Calls",
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = "Incoming video call notifications"
            lockscreenVisibility = Notification.VISIBILITY_PUBLIC
        }

        manager.createNotificationChannel(channel)
    }
    
    /**
     * استخراج SHA-256 Fingerprint من توقيع التطبيق
     * يعمل على جميع إصدارات Android
     */
    private fun getAppSignatureSHA256(): String {
        return try {
            val packageInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                packageManager.getPackageInfo(
                    packageName,
                    PackageManager.GET_SIGNING_CERTIFICATES
                )
            } else {
                @Suppress("DEPRECATION")
                packageManager.getPackageInfo(
                    packageName,
                    PackageManager.GET_SIGNATURES
                )
            }
            
            val signatures = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                packageInfo.signingInfo?.apkContentsSigners
            } else {
                @Suppress("DEPRECATION")
                packageInfo.signatures
            }
            
            if (signatures.isNullOrEmpty()) {
                return "NO_SIGNATURES_FOUND"
            }
            
            val signature = signatures[0]
            val md = MessageDigest.getInstance("SHA-256")
            val digest = md.digest(signature.toByteArray())
            
            // تنسيق كـ hex مع فواصل نقطتين (مثل: AB:CD:EF:...)
            digest.joinToString(":") { byte ->
                String.format("%02X", byte)
            }
        } catch (e: Exception) {
            "ERROR: ${e.message}"
        }
    }
}
