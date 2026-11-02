package com.example.flutterweather

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.widget.RemoteViews
import androidx.core.widget.RemoteViewsCompat
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import org.json.JSONObject

/**
 * Home-screen widget: a looping stack of two cards, the current weather and the
 * next 24 hours, which the user swipes up or down between. (Home screens keep
 * left/right swipes for paging, so the hours are laid out side by side.) The
 * Flutter side (lib/services/weather_widget.dart) writes the values.
 */
class WeatherWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val city = widgetData.getString("city", null)
        val updated = widgetData.getString("updated", "") ?: ""
        val now = parseObject(widgetData.getString("now", null))
        val hours = parseArray(widgetData.getString("hours", null))

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.weather_widget).apply {
                setEmptyView(R.id.widget_stack, R.id.widget_empty)
                setOnClickPendingIntent(
                    R.id.widget_empty,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
                )
                setPendingIntentTemplate(R.id.widget_stack, openAppTemplate(context))
            }

            val items = RemoteViewsCompat.RemoteCollectionItems.Builder().setViewTypeCount(2)
            if (city != null && now != null) {
                items.addItem(0, nowCard(context, city, updated, now))
                if (hours.isNotEmpty()) items.addItem(1, hoursCard(context, city, hours))
            }
            RemoteViewsCompat.setRemoteAdapter(context, views, widgetId, R.id.widget_stack, items.build())
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun nowCard(context: Context, city: String, updated: String, now: JSONObject) =
        RemoteViews(context.packageName, R.layout.weather_widget_item).apply {
            setTextViewText(R.id.card_city, city)
            setTextViewText(R.id.card_label, context.getString(R.string.widget_now))
            setImageViewResource(R.id.card_icon, iconFor(now.optString("icon")))
            setTextViewText(R.id.card_temperature, now.optString("temperature"))
            setTextViewText(R.id.card_description, now.optString("description"))
            setTextViewText(R.id.card_detail, now.optString("detail"))
            setTextViewText(R.id.card_updated, context.getString(R.string.widget_updated, updated))
            setOnClickFillInIntent(R.id.card_root, Intent())
        }

    private fun hoursCard(context: Context, city: String, hours: List<JSONObject>) =
        RemoteViews(context.packageName, R.layout.weather_widget_hours).apply {
            setTextViewText(R.id.hours_city, city)
            removeAllViews(R.id.hours_row)
            hours.forEach { hour ->
                addView(
                    R.id.hours_row,
                    RemoteViews(context.packageName, R.layout.weather_widget_hour).apply {
                        setTextViewText(R.id.hour_label, hour.optString("label"))
                        setImageViewResource(R.id.hour_icon, iconFor(hour.optString("icon")))
                        setTextViewText(R.id.hour_temperature, hour.optString("temperature"))
                    },
                )
            }
            setOnClickFillInIntent(R.id.hours_root, Intent())
        }

    /** Collection items can't have their own PendingIntents, only fill-ins for this template. */
    private fun openAppTemplate(context: Context): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).setAction(HomeWidgetLaunchIntent.HOME_WIDGET_LAUNCH_ACTION)
        var flags = PendingIntent.FLAG_UPDATE_CURRENT
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) flags = flags or PendingIntent.FLAG_MUTABLE
        return PendingIntent.getActivity(context, 1, intent, flags)
    }

    private fun parseObject(json: String?): JSONObject? =
        try {
            json?.let { JSONObject(it) }
        } catch (e: Exception) {
            null
        }

    private fun parseArray(json: String?): List<JSONObject> {
        if (json == null) return emptyList()
        return try {
            val array = JSONArray(json)
            (0 until array.length()).map { array.getJSONObject(it) }
        } catch (e: Exception) {
            emptyList()
        }
    }

    /**
     * Icons rendered from the app's Flare animations by tool/render_widget_icons_test.dart.
     * Mapped explicitly (not by name lookup) so resource shrinking keeps them.
     */
    private fun iconFor(name: String) =
        when (name) {
            "clear" -> R.drawable.widget_icon_clear
            "clear-night" -> R.drawable.widget_icon_clear_night
            "sunny" -> R.drawable.widget_icon_sunny
            "sunny-night" -> R.drawable.widget_icon_sunny_night
            "few-night" -> R.drawable.widget_icon_few_night
            "broken" -> R.drawable.widget_icon_broken
            "rain" -> R.drawable.widget_icon_rain
            "snow" -> R.drawable.widget_icon_snow
            "thunder" -> R.drawable.widget_icon_thunder
            "foggy" -> R.drawable.widget_icon_foggy
            else -> R.drawable.widget_icon_few
        }
}
