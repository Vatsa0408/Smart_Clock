package com.smartclock.smart_clock

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.net.Uri
import android.os.BatteryManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "smart_clock/battery"
    private var batteryReceiver: BroadcastReceiver? = null
    private val batteryChannel by lazy { MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL) }

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