package com.nananeko.reminders

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

/**
 * Shows the app over the lock screen and turns the screen on only while it was
 * launched by an alarm notification, so the rest of the time the app still
 * requires unlocking. Dart calls `release` on [CHANNEL] once the alarm is
 * dismissed. Also creates the notification channel for release pushes.
 */
class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "reminders/lock_screen"

        // Intent contract of flutter_local_notifications (FlutterLocalNotificationsPlugin.java).
        private const val SELECT_NOTIFICATION = "SELECT_NOTIFICATION"
        private const val PAYLOAD = "payload"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (isAlarmLaunch(intent)) showOverLockScreen(true)
        createUpdatesChannel()
    }

    // Channel used by release push notifications (see the FCM meta-data in
    // AndroidManifest.xml). Creating an existing channel is a no-op.
    private fun createUpdatesChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            "updates",
            getString(R.string.notification_channel_updates),
            NotificationManager.IMPORTANCE_HIGH,
        )
        getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (isAlarmLaunch(intent)) showOverLockScreen(true)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "release" -> {
                        showOverLockScreen(false)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun isAlarmLaunch(intent: Intent?): Boolean {
        if (intent?.action != SELECT_NOTIFICATION) return false
        val payload = intent.getStringExtra(PAYLOAD) ?: return false
        return try {
            JSONObject(payload).optBoolean("a", false)
        } catch (e: Exception) {
            false
        }
    }

    private fun showOverLockScreen(enabled: Boolean) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(enabled)
            setTurnScreenOn(enabled)
        } else {
            @Suppress("DEPRECATION")
            val flags = WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            if (enabled) window.addFlags(flags) else window.clearFlags(flags)
        }
    }
}
