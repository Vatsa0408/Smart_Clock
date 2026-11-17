package com.smartclock.smart_clock

import android.service.notification.NotificationListenerService

// Empty on purpose: being an *enabled* notification listener is what unlocks
// MediaSessionManager.getActiveSessions() for MainActivity.
class MediaListener : NotificationListenerService()
