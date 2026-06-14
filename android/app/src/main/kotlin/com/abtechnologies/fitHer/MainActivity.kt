package com.abtechnologies.fitHer

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import android.util.Log
import us.zoom.sdk.*

class MainActivity : FlutterFragmentActivity(), ZoomSDKInitializeListener, MeetingServiceListener {
    private val CHANNEL = "zoom_meeting"
    private val EVENTS_CHANNEL = "zoom_meeting/events"
    private val TAG = "MainActivity"
    private var isInitialized = false
    private var pendingInitResult: MethodChannel.Result? = null
    private var eventSink: EventChannel.EventSink? = null

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

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENTS_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            }
        )
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
            meetingService.removeListener(this)
            meetingService.addListener(this)

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

    override fun onMeetingStatusChanged(meetingStatus: MeetingStatus?, errorCode: Int, internalErrorCode: Int) {
        val event = when (meetingStatus) {
            MeetingStatus.MEETING_STATUS_INMEETING -> "meeting_in"
            MeetingStatus.MEETING_STATUS_ENDED,
            MeetingStatus.MEETING_STATUS_IDLE -> "meeting_left"
            MeetingStatus.MEETING_STATUS_FAILED -> "meeting_failed"
            else -> null
        }

        if (event != null) {
            sendZoomEvent(
                mapOf(
                    "event" to event,
                    "status" to (meetingStatus?.name ?: "unknown"),
                    "errorCode" to errorCode,
                    "internalErrorCode" to internalErrorCode
                )
            )
        }
    }

    override fun onMeetingParameterNotification(meetingParameter: MeetingParameter?) {
        sendZoomEvent(mapOf("event" to "meeting_ready"))
    }

    private fun sendZoomEvent(payload: Map<String, Any?>) {
        runOnUiThread {
            eventSink?.success(payload)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        ZoomSDK.getInstance().meetingService?.removeListener(this)
        ZoomSDK.getInstance().logoutZoom()
    }
}
