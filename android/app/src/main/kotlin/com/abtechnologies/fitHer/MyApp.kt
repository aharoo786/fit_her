package com.abtechnologies.fitHer

import android.app.Application
import com.facebook.appevents.AppEventsLogger
import com.facebook.FacebookSdk

class MyApp : Application() {
    override fun onCreate() {
        super.onCreate()
        FacebookSdk.sdkInitialize(applicationContext)
        AppEventsLogger.activateApp(this)
    }
}
