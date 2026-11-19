package com.smartclock.smart_clock

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.SystemClock
import android.provider.Settings

object ProtectBattery {
    private const val SETTINGS_PKG = "com.samsung.android.lool"
    private const val SETTINGS_ACTIVITY = "com.samsung.android.sm.battery.ui.BatteryActivity" // probed: hosts the switch
    private const val WANT_TTL_MS = 30_000L

    /** Read only. Never write this key: it desyncs from the real switch (verified on the tablet). */
    fun read(ctx: Context): Boolean = Settings.System.getInt(ctx.contentResolver, "protect_battery", 0) == 1

    @Volatile private var wanted: Boolean? = null
    @Volatile private var wantedAt = 0L

    /** The service takes the request once, and only within [WANT_TTL_MS]. */
    fun take(): Boolean? {
        val w = wanted ?: return null
        if (SystemClock.elapsedRealtime() - wantedAt > WANT_TTL_MS) wanted = null
        return wanted
    }

    fun clear() { wanted = null }

    /** Opens Samsung's battery screen; the accessibility service then taps the switch if needed. */
    fun request(ctx: Context, on: Boolean) {
        wanted = on
        wantedAt = SystemClock.elapsedRealtime()
        ctx.startActivity(
            Intent().setComponent(ComponentName(SETTINGS_PKG, SETTINGS_ACTIVITY)).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
        )
    }

    fun serviceEnabled(ctx: Context): Boolean {
        val me = ComponentName(ctx, ProtectBatteryService::class.java).flattenToString()
        return Settings.Secure.getString(ctx.contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES)
            ?.split(':')?.contains(me) == true
    }
}
