package com.abtechnologies.fitHer

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import android.util.Log
// Zoom SDK commented out — .aar not available
// import us.zoom.sdk.*

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "zoom_meeting"
    private val TAG = "MainActivity"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initializeZoom" -> {
                    result.error("ZOOM_DISABLED", "Zoom SDK not available", null)
                }
                "joinMeeting" -> {
                    result.error("ZOOM_DISABLED", "Zoom SDK not available", null)
                }
                "leaveMeeting" -> {
                    result.error("ZOOM_DISABLED", "Zoom SDK not available", null)
                }
                "isInitialized" -> {
                    result.success(false)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
