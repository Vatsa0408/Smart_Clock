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

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getBatteryLevel" -> {
                    result.success(getBatteryLevel())
                }
                "isCharging" -> {
                    result.success(isCharging())
                }
                "playLowBatterySound" -> {
                    playLowBatterySound()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
        registerBatteryReceiver()
    }

    private fun getBatteryLevel(): Int {
        val batteryManager = getSystemService(BATTERY_SERVICE) as BatteryManager
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intent = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            intent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
        }
    }

    private fun isCharging(): Boolean {
        val batteryManager = getSystemService(BATTERY_SERVICE) as BatteryManager
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_STATUS) == BatteryManager.BATTERY_STATUS_CHARGING
        } else {
            val intent = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            val status = intent?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
            status == BatteryManager.BATTERY_STATUS_CHARGING || status == BatteryManager.BATTERY_STATUS_FULL
        }
    }

    private fun registerBatteryReceiver() {
        batteryReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val level = getBatteryLevel()
                val charging = isCharging()
                val args = mapOf("level" to level, "isCharging" to charging)
                val binaryMessenger = flutterEngine?.dartExecutor?.binaryMessenger
                if (binaryMessenger != null) {
                    val channel = MethodChannel(binaryMessenger, CHANNEL)
                    channel.invokeMethod("onBatteryChanged", args)
                }
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

    private fun playLowBatterySound() {
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
            // Ignore errors playing sound
        }
    }
}