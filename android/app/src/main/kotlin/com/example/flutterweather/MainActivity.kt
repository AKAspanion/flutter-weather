package com.example.flutterweather

import android.app.ActivityOptions
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "pin" -> result.success(pinWidget())
                else -> result.notImplemented()
            }
        }
    }

    /**
     * Asks the launcher to pin the widget. home_widget passes no callback, so the launcher's "Add" button
     * would leave the user in the app; this one opens the home screen.
     */
    private fun pinWidget(): Boolean {
        val manager = AppWidgetManager.getInstance(this)
        if (!manager.isRequestPinAppWidgetSupported) return false

        val home = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        // The launcher sends this intent, and Android 14+ blocks the launch unless its creator allows it.
        val options =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                ActivityOptions.makeBasic()
                    .setPendingIntentCreatorBackgroundActivityStartMode(
                        ActivityOptions.MODE_BACKGROUND_ACTIVITY_START_ALLOWED
                    )
                    .toBundle()
            } else {
                null
            }
        val callback = PendingIntent.getActivity(this, 0, home, PendingIntent.FLAG_IMMUTABLE, options)
        return manager.requestPinAppWidget(ComponentName(this, WeatherWidgetProvider::class.java), null, callback)
    }

    private companion object {
        const val CHANNEL = "in.spanion.weather/widget"
    }
}
