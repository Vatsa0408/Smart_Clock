package com.smartclock.smart_clock

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

/** Taps Samsung's Protect battery switch when the app asked for it (see ProtectBattery.request). */
class ProtectBatteryService : AccessibilityService() {
    override fun onAccessibilityEvent(e: AccessibilityEvent) {
        val want = ProtectBattery.take() ?: return
        val root = rootInActiveWindow ?: return
        val title = root.findAccessibilityNodeInfosByText("Protect battery")
            .firstOrNull { it.viewIdResourceName == "android:id/title" } ?: return
        val sw = switchOf(title) ?: return
        ProtectBattery.clear()
        if (sw.isChecked != want) sw.performAction(AccessibilityNodeInfo.ACTION_CLICK) // Samsung reboots the tablet on a real change
        else { performGlobalAction(GLOBAL_ACTION_BACK) } // already as wanted: leave Settings
    }

    /** The row's id is generic (android:id/switch_widget everywhere), so go up from the title to the row and search down. */
    private fun switchOf(title: AccessibilityNodeInfo): AccessibilityNodeInfo? {
        var row: AccessibilityNodeInfo? = title
        repeat(4) {
            row = row?.parent
            row?.let { r -> find(r)?.let { return it } }
        }
        return null
    }

    private fun find(n: AccessibilityNodeInfo): AccessibilityNodeInfo? {
        if (n.className == "android.widget.Switch") return n
        for (i in 0 until n.childCount) n.getChild(i)?.let { c -> find(c)?.let { return it } }
        return null
    }

    override fun onInterrupt() {}
}
