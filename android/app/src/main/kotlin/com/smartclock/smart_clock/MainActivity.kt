package com.smartclock.smart_clock

import android.app.ActivityManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Bitmap
import android.media.AudioAttributes
import android.media.MediaMetadata
import android.media.RingtoneManager
import android.media.session.MediaController
import android.media.session.MediaSessionManager
import android.media.session.PlaybackState
import android.net.Uri
import android.os.BatteryManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import io.flutter.plugin.common.EventChannel
import java.io.ByteArrayOutputStream
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "smart_clock/battery"
    private var batteryReceiver: BroadcastReceiver? = null
    private val batteryChannel by lazy { MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL) }

    // Now playing (MediaSessionManager via the enabled MediaListener)
    private var npSink: EventChannel.EventSink? = null
    private var controller: MediaController? = null
    private val main = Handler(Looper.getMainLooper())
    private val msm by lazy { getSystemService(MEDIA_SESSION_SERVICE) as MediaSessionManager }
    private val listenerName by lazy { ComponentName(this, MediaListener::class.java) }
    private val sessions = MediaSessionManager.OnActiveSessionsChangedListener { pick(it) }
    private val cb = object : MediaController.Callback() {
        override fun onMetadataChanged(metadata: MediaMetadata?) = send(withArt = true)
        override fun onPlaybackStateChanged(state: PlaybackState?) = send(withArt = false)
        override fun onSessionDestroyed() = pick(msm.getActiveSessions(listenerName))
    }

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        window.addFlags(android.view.WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        batteryChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getBattery" -> result.success(batteryArgs(registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))))
                "playSound" -> {
                    playSound(call.arguments as? String ?: "default")
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "smart_clock/display").setMethodCallHandler { call, result ->
            when (call.method) {
                "setBrightness" -> {
                    val v = (call.arguments as Double).toFloat() // -1f = follow system
                    runOnUiThread { window.attributes = window.attributes.apply { screenBrightness = v } }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        registerBatteryReceiver()
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        EventChannel(messenger, "smart_clock/now_playing/events").setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(args: Any?, sink: EventChannel.EventSink) {
                npSink = sink
                startNowPlaying()
            }

            override fun onCancel(args: Any?) {
                npSink = null
                msm.removeOnActiveSessionsChangedListener(sessions)
                controller?.unregisterCallback(cb)
                controller = null
            }
        })
        MethodChannel(messenger, "smart_clock/now_playing").setMethodCallHandler { call, result ->
            when (call.method) {
                "transport" -> {
                    controller?.transportControls?.let { t ->
                        when (call.arguments as String) {
                            "play" -> t.play()
                            "pause" -> t.pause()
                            "next" -> t.skipToNext()
                            "previous" -> t.skipToPrevious()
                        }
                    }
                    result.success(null)
                }
                "openAccessSettings" -> {
                    try {
                        startActivity(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                    } catch (_: Exception) {
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun hasAccess() = Settings.Secure.getString(contentResolver, "enabled_notification_listeners")
        ?.contains(packageName) == true

    private fun startNowPlaying() {
        val sink = npSink ?: return
        val am = getSystemService(ACTIVITY_SERVICE) as ActivityManager
        // Notification listeners cannot be bound on low-RAM devices running Android Q and below.
        if (am.isLowRamDevice && Build.VERSION.SDK_INT <= Build.VERSION_CODES.Q) {
            sink.success(mapOf("access" to "unsupported"))
            return
        }
        if (!hasAccess()) {
            sink.success(mapOf("access" to "denied"))
            return
        }
        try {
            msm.removeOnActiveSessionsChangedListener(sessions)
            msm.addOnActiveSessionsChangedListener(sessions, listenerName, main)
            pick(msm.getActiveSessions(listenerName))
        } catch (e: SecurityException) {
            sink.success(mapOf("access" to "denied"))
        }
    }

    private fun pick(list: List<MediaController>?) {
        val next = list?.firstOrNull { it.playbackState?.state == PlaybackState.STATE_PLAYING } ?: list?.firstOrNull()
        if (next?.sessionToken != controller?.sessionToken) {
            controller?.unregisterCallback(cb)
            controller = next
            next?.registerCallback(cb, main)
        }
        send(withArt = true)
    }

    private fun send(withArt: Boolean) {
        val c = controller
        val m = c?.metadata
        val map = mutableMapOf<String, Any?>(
            "access" to "granted",
            "pkg" to c?.packageName,
            "title" to m?.getString(MediaMetadata.METADATA_KEY_TITLE),
            "artist" to (m?.getString(MediaMetadata.METADATA_KEY_ARTIST) ?: m?.getString(MediaMetadata.METADATA_KEY_ALBUM_ARTIST)),
            "playing" to (c?.playbackState?.state == PlaybackState.STATE_PLAYING),
        )
        if (withArt) map["art"] = artBytes(m) // key absent = keep previous art
        npSink?.success(map)
    }

    /// Scaled to a 160 px JPEG (~10-20 KB) so the channel never carries a full bitmap.
    private fun artBytes(m: MediaMetadata?): ByteArray? {
        val b = m?.getBitmap(MediaMetadata.METADATA_KEY_ALBUM_ART) ?: m?.getBitmap(MediaMetadata.METADATA_KEY_ART) ?: return null
        val s = Bitmap.createScaledBitmap(b, 160, (160L * b.height / b.width.coerceAtLeast(1)).toInt().coerceAtLeast(1), true)
        return ByteArrayOutputStream().also { s.compress(Bitmap.CompressFormat.JPEG, 80, it) }.toByteArray()
    }

    override fun onResume() {
        super.onResume()
        startNowPlaying() // picks up a grant made in Settings
    }

    private fun batteryArgs(i: Intent?): Map<String, Any?> {
        val level = i?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
        val scale = i?.getIntExtra(BatteryManager.EXTRA_SCALE, 100) ?: 100
        val temp = i?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, Int.MIN_VALUE) ?: Int.MIN_VALUE
        return mapOf(
            "level" to if (level >= 0 && scale > 0) level * 100 / scale else null,
            "isCharging" to (i?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) == BatteryManager.BATTERY_STATUS_CHARGING),
            "tempC" to if (temp == Int.MIN_VALUE) null else temp / 10.0,
            "overheat" to (i?.getIntExtra(BatteryManager.EXTRA_HEALTH, 0) == BatteryManager.BATTERY_HEALTH_OVERHEAT),
        )
    }

    private fun registerBatteryReceiver() {
        batteryReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                batteryChannel.invokeMethod("onBatteryChanged", batteryArgs(intent))
            }
        }
        val filter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(batteryReceiver, filter, RECEIVER_NOT_EXPORTED)
        } else {
            @Suppress("DEPRECATION")
            registerReceiver(batteryReceiver, filter)
        }
    }

    override fun onDestroy() {
        batteryReceiver?.let { unregisterReceiver(it) }
        super.onDestroy()
    }

    private fun playSound(type: String) {
        try {
            val notificationSound: Uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
            val audioAttributes = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()
            val ringtone = RingtoneManager.getRingtone(applicationContext, notificationSound)
            ringtone.setAudioAttributes(audioAttributes)
            ringtone.play()
        } catch (e: Exception) {
            // Ignore errors playing sound (every type plays the notification tone for now)
        }
    }
}