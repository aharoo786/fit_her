package com.abtechnologies.fitHer

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import android.util.Log
import us.zoom.sdk.*

class MainActivity : FlutterFragmentActivity(), ZoomSDKInitializeListener {
    private val CHANNEL = "zoom_meeting"
    private val TAG = "MainActivity"
    private var isInitialized = false
    private var pendingInitResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initializeZoom" -> {
                    initializeZoomSDK(call, result)
                }
                "joinMeeting" -> {
                    joinMeeting(call, result)
                }
                "leaveMeeting" -> {
                    leaveMeeting(result)
                }
                "isInitialized" -> {
                    result.success(isInitialized)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun initializeZoomSDK(call: MethodCall, result: MethodChannel.Result) {
        try {
            val jwtToken = call.argument<String>("jwtToken")
            if (jwtToken.isNullOrEmpty()) {
                result.error("NO_JWT", "JWT token is required", null)
                return
            }
            val sdk = ZoomSDK.getInstance()

            if (sdk.isInitialized) {
                isInitialized = true
                result.success(true)
                return
            }

            pendingInitResult = result

            val params = ZoomSDKInitParams().apply {
                domain = "zoom.us"
                enableLog = true
                this.jwtToken = jwtToken
            }

            sdk.initialize(applicationContext, this, params)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize Zoom SDK", e)
            result.error("INIT_ERROR", "Failed to initialize Zoom SDK", e.message)
        }
    }

    private fun joinMeeting(call: MethodCall, result: MethodChannel.Result) {
        try {
            if (!isInitialized) {
                result.error("NOT_INITIALIZED", "Zoom SDK not initialized", null)
                return
            }

            val meetingNumber = call.argument<String>("meetingNumber")
            val displayName = call.argument<String>("displayName")
            val password = call.argument<String>("password")

            if (meetingNumber.isNullOrEmpty() || displayName.isNullOrEmpty()) {
                result.error("INVALID_PARAMS", "Meeting number and display name are required", null)
                return
            }

            val sdk = ZoomSDK.getInstance()
            val meetingService = sdk.meetingService ?: run {
                result.error("SERVICE_ERROR", "Meeting service not available", null)
                return
            }

            val options = JoinMeetingOptions().apply {
                no_driving_mode = true
                no_invite = true
                no_meeting_end_message = true
                no_titlebar = false
                no_bottom_toolbar = false
                no_dial_in_via_phone = true
                no_dial_out_to_phone = true
            }

            val paramsJoin = JoinMeetingParams().apply {
                meetingNo = meetingNumber
                this.displayName = displayName
                this.password = password
            }

            val ret = meetingService.joinMeetingWithParams(this, paramsJoin, options)

            if (ret == MeetingError.MEETING_ERROR_SUCCESS) {
                result.success(true)
            } else {
                result.error("JOIN_FAILED", "Zoom join failed with code: $ret", null)
            }

        } catch (e: Exception) {
            Log.e(TAG, "Failed to join meeting", e)
            result.error("JOIN_ERROR", "Failed to join meeting", e.message)
        }
    }

    private fun leaveMeeting(result: MethodChannel.Result) {
        try {
            val sdk = ZoomSDK.getInstance()
            val meetingService = sdk.meetingService

            if (meetingService != null && meetingService.meetingStatus != MeetingStatus.MEETING_STATUS_IDLE) {
                meetingService.leaveCurrentMeeting(false)
                result.success(true)
            } else {
                result.success(false)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to leave meeting", e)
            result.error("LEAVE_ERROR", "Failed to leave meeting", e.message)
        }
    }

    // ZoomSDKInitializeListener
    override fun onZoomSDKInitializeResult(errorCode: Int, internalErrorCode: Int) {
        if (errorCode == ZoomError.ZOOM_ERROR_SUCCESS) {
            isInitialized = true
            Log.d(TAG, "Zoom SDK initialized successfully")
            pendingInitResult?.success(true)
        } else {
            isInitialized = false
            Log.e(TAG, "Failed to initialize Zoom SDK: $errorCode, $internalErrorCode")
            pendingInitResult?.error("INIT_FAILED", "Initialization failed", "$errorCode")
        }
        pendingInitResult = null
    }

    override fun onZoomAuthIdentityExpired() {
        Log.w(TAG, "Zoom auth identity expired")
    }

    override fun onDestroy() {
        super.onDestroy()
        ZoomSDK.getInstance().logoutZoom()
    }
}
