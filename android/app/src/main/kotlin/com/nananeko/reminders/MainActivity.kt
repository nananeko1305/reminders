package com.nananeko.reminders

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.ActivityNotFoundException
import android.content.Intent
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

/**
 * Shows the app over the lock screen and turns the screen on only while it was
 * launched by an alarm notification, so the rest of the time the app still
 * requires unlocking. Dart calls `release` on [LOCK_SCREEN_CHANNEL] once the
 * alarm is dismissed.
 *
 * [DEVICE_CHANNEL] answers what the notification plugin cannot: whether
 * full-screen alarms are allowed, the system sound picker, and sound names.
 * Also creates the notification channel for release pushes.
 */
class MainActivity : FlutterActivity() {
    companion object {
        private const val LOCK_SCREEN_CHANNEL = "reminders/lock_screen"
        private const val DEVICE_CHANNEL = "reminders/device"
        private const val PICK_SOUND_REQUEST = 7301

        // Intent contract of flutter_local_notifications (FlutterLocalNotificationsPlugin.java).
        private const val SELECT_NOTIFICATION = "SELECT_NOTIFICATION"
        private const val PAYLOAD = "payload"
    }

    private var pendingSoundResult: MethodChannel.Result? = null

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
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        MethodChannel(messenger, LOCK_SCREEN_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "release" -> {
                    showOverLockScreen(false)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        MethodChannel(messenger, DEVICE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "canUseFullScreenIntent" -> result.success(canUseFullScreenIntent())
                "pickSound" -> pickSound(call.argument("current"), call.argument("title"), result)
                "soundTitle" -> result.success(call.argument<String>("uri")?.let(::soundTitle))
                else -> result.notImplemented()
            }
        }
    }

    /** Android 14 made full-screen alarms a permission users can revoke. */
    private fun canUseFullScreenIntent(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE ||
            getSystemService(NotificationManager::class.java).canUseFullScreenIntent()

    /**
     * Opens the system sound picker (ringtones, alarms, notifications, with
     * preview). Replies null when cancelled, {"uri": null} for the default
     * alarm sound, otherwise {"uri", "title"}.
     */
    private fun pickSound(current: String?, title: String?, result: MethodChannel.Result) {
        if (pendingSoundResult != null) {
            result.error("busy", "The sound picker is already open", null)
            return
        }
        val defaultUri = Settings.System.DEFAULT_ALARM_ALERT_URI
        val intent = Intent(RingtoneManager.ACTION_RINGTONE_PICKER).apply {
            putExtra(RingtoneManager.EXTRA_RINGTONE_TYPE, RingtoneManager.TYPE_ALL)
            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_DEFAULT, true)
            putExtra(RingtoneManager.EXTRA_RINGTONE_DEFAULT_URI, defaultUri)
            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_SILENT, false)
            putExtra(RingtoneManager.EXTRA_RINGTONE_EXISTING_URI, current?.let(Uri::parse) ?: defaultUri)
            if (title != null) putExtra(RingtoneManager.EXTRA_RINGTONE_TITLE, title)
        }
        pendingSoundResult = result
        try {
            startActivityForResult(intent, PICK_SOUND_REQUEST)
        } catch (e: ActivityNotFoundException) {
            pendingSoundResult = null
            result.error("unavailable", e.message, null)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != PICK_SOUND_REQUEST) return
        val result = pendingSoundResult ?: return
        pendingSoundResult = null
        val picked: Uri? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            data?.getParcelableExtra(RingtoneManager.EXTRA_RINGTONE_PICKED_URI, Uri::class.java)
        } else {
            @Suppress("DEPRECATION")
            data?.getParcelableExtra(RingtoneManager.EXTRA_RINGTONE_PICKED_URI)
        }
        if (resultCode != RESULT_OK || picked == null) {
            result.success(null)
        } else if (picked == Settings.System.DEFAULT_ALARM_ALERT_URI) {
            result.success(mapOf("uri" to null))
        } else {
            result.success(mapOf("uri" to picked.toString(), "title" to soundTitle(picked.toString())))
        }
    }

    private fun soundTitle(uri: String): String? = try {
        RingtoneManager.getRingtone(this, Uri.parse(uri))?.getTitle(this)
    } catch (e: Exception) {
        null
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
