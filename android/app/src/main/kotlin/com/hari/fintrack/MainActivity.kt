package com.hari.fintrack

import android.content.ContentValues
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.MediaStore
import android.view.WindowManager
import androidx.activity.result.contract.ActivityResultContracts
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private var pendingPick: MethodChannel.Result? = null
    private var pendingSave: MethodChannel.Result? = null
    private var pendingSaveBytes: ByteArray? = null

    private val openDocument = registerForActivityResult(ActivityResultContracts.OpenDocument()) { uri ->
        val result = pendingPick
        pendingPick = null
        if (uri == null) {
            result?.success(null)
        } else {
            try {
                val bytes = contentResolver.openInputStream(uri)?.use { it.readBytes() }
                result?.success(bytes)
            } catch (error: Exception) {
                result?.error("read_failed", error.message, null)
            }
        }
    }

    private val createDocument =
        registerForActivityResult(ActivityResultContracts.CreateDocument("application/octet-stream")) { uri ->
            val result = pendingSave
            val bytes = pendingSaveBytes
            pendingSave = null
            pendingSaveBytes = null
            if (uri == null || bytes == null) {
                result?.success(null)
            } else {
                try {
                    writeTo(uri, bytes)
                    result?.success(uri.lastPathSegment ?: "")
                } catch (error: Exception) {
                    result?.error("write_failed", error.message, null)
                }
            }
        }

    override fun onCreate(savedInstanceState: Bundle?) {
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        MethodChannel(messenger, "fintrack/window").setMethodCallHandler { call, result ->
            when (call.method) {
                "setSecure" -> {
                    val secure = call.arguments as? Boolean ?: true
                    runOnUiThread {
                        if (secure) {
                            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        } else {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        }
                        result.success(null)
                    }
                }
                else -> result.notImplemented()
            }
        }
        MethodChannel(messenger, "fintrack/files").setMethodCallHandler { call, result ->
            when (call.method) {
                "saveToDownloads" -> {
                    val name = call.argument<String>("name") ?: "fintrack-backup"
                    val bytes = call.argument<ByteArray>("bytes")
                    if (bytes == null) {
                        result.error("no_bytes", null, null)
                    } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        try {
                            result.success(saveToDownloads(name, bytes))
                        } catch (error: Exception) {
                            result.error("write_failed", error.message, null)
                        }
                    } else {
                        pendingSave = result
                        pendingSaveBytes = bytes
                        createDocument.launch(name)
                    }
                }
                "pickFile" -> {
                    pendingPick = result
                    openDocument.launch(arrayOf("*/*"))
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun saveToDownloads(name: String, bytes: ByteArray): String {
        val values = ContentValues().apply {
            put(MediaStore.Downloads.DISPLAY_NAME, name)
            put(MediaStore.Downloads.MIME_TYPE, "application/octet-stream")
            put(MediaStore.Downloads.IS_PENDING, 1)
        }
        val uri = contentResolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
            ?: throw IllegalStateException("Downloads is not available")
        writeTo(uri, bytes)
        values.clear()
        values.put(MediaStore.Downloads.IS_PENDING, 0)
        contentResolver.update(uri, values, null, null)
        return "Download/$name"
    }

    private fun writeTo(uri: Uri, bytes: ByteArray) {
        contentResolver.openOutputStream(uri, "w")?.use { it.write(bytes) }
            ?: throw IllegalStateException("Cannot open the file")
    }
}
