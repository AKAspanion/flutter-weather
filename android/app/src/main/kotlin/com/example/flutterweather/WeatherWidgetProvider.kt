package com.example.flutterweather

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/** Home-screen widget. The Flutter side (lib/services/weather_widget.dart) writes the values. */
class WeatherWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val city = widgetData.getString("city", null)

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.weather_widget).apply {
                setOnClickPendingIntent(
                    R.id.widget_root,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
                )
                if (city == null) {
                    setTextViewText(R.id.widget_city, context.getString(R.string.widget_empty))
                } else {
                    setTextViewText(R.id.widget_city, city)
                    setTextViewText(R.id.widget_icon, widgetData.getString("icon", ""))
                    setTextViewText(R.id.widget_temperature, widgetData.getString("temperature", ""))
                    setTextViewText(R.id.widget_description, widgetData.getString("description", ""))
                    setTextViewText(R.id.widget_range, widgetData.getString("range", ""))
                    setTextViewText(
                        R.id.widget_updated,
                        context.getString(R.string.widget_updated, widgetData.getString("updated", "")),
                    )
                }
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
