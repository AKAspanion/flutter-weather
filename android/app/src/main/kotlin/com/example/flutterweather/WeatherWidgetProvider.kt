package com.example.flutterweather

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.os.Build
import android.os.Bundle
import android.util.SizeF
import android.util.TypedValue
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONObject

/**
 * Home-screen widget: one card with the current weather, drawn in the app's
 * accent. The Flutter side (lib/services/weather_widget.dart) writes the values.
 *
 * Two layouts: the full card, and a compact one for cards narrower than
 * [SMALL_WIDTH] (about 2x2). On Android 12+ the launcher reports every size the
 * widget can be shown at, and one RemoteViews is rendered per size so the host
 * picks the layout that fits; earlier versions get the layout for the size the
 * options report.
 */
class WeatherWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { render(context, appWidgetManager, it, widgetData) }
    }

    // The layout and text scale follow the card's size, so re-render on resize.
    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle,
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        render(context, appWidgetManager, appWidgetId, HomeWidgetPlugin.getData(context))
    }

    private fun render(
        context: Context,
        appWidgetManager: AppWidgetManager,
        widgetId: Int,
        widgetData: SharedPreferences,
    ) {
        val content = Content(
            city = widgetData.getString("city", null),
            updated = widgetData.getString("updated", "") ?: "",
            now = parseObject(widgetData.getString("now", null)),
            accent = accentOf(widgetData),
        )

        val sizes =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                @Suppress("DEPRECATION")
                appWidgetManager.getAppWidgetOptions(widgetId)
                    .getParcelableArrayList<SizeF>(AppWidgetManager.OPTION_APPWIDGET_SIZES)
            } else {
                null
            }

        val views =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && !sizes.isNullOrEmpty()) {
                RemoteViews(sizes.associateWith { widgetViews(context, content, it) })
            } else {
                widgetViews(context, content, portraitSize(appWidgetManager, widgetId))
            }
        appWidgetManager.updateAppWidget(widgetId, views)
    }

    /**
     * Before Android 12 there's no list of exact sizes; the options give the
     * portrait size as min width x max height. Only the layout choice and the
     * text scale use it, since sizing views needs Android 12.
     */
    private fun portraitSize(appWidgetManager: AppWidgetManager, widgetId: Int): SizeF? {
        val options = appWidgetManager.getAppWidgetOptions(widgetId)
        val width = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH)
        val height = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT)
        return if (width > 0 && height > 0) SizeF(width.toFloat(), height.toFloat()) else null
    }

    private class Content(
        val city: String?,
        val updated: String,
        val now: JSONObject?,
        val accent: Int,
    )

    private fun widgetViews(context: Context, content: Content, size: SizeF?): RemoteViews {
        val small = size != null && size.width < SMALL_WIDTH
        val views = RemoteViews(
            context.packageName,
            if (small) R.layout.weather_widget_small else R.layout.weather_widget,
        )
        views.setInt(R.id.widget_root, "setBackgroundResource", backgroundFor(content.accent))

        // The whole card opens the app, and so does the empty view.
        val open = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
        views.setOnClickPendingIntent(R.id.widget_root, open)
        views.setOnClickPendingIntent(R.id.widget_empty, open)

        val city = content.city
        val now = content.now
        if (city == null || now == null) {
            views.setViewVisibility(R.id.widget_content, View.GONE)
            views.setViewVisibility(R.id.widget_empty, View.VISIBLE)
            return views
        }
        views.setViewVisibility(R.id.widget_content, View.VISIBLE)
        views.setViewVisibility(R.id.widget_empty, View.GONE)

        views.setTextViewText(R.id.card_city, city)
        // The icon is an animated layout, swapped into the slot on every render.
        views.removeAllViews(R.id.card_icon_slot)
        views.addView(R.id.card_icon_slot, RemoteViews(context.packageName, iconLayoutFor(now.optString("icon"))))
        views.setTextViewText(R.id.card_temperature, now.optString("temperature"))
        views.setTextViewText(R.id.card_description, now.optString("description"))
        views.setTextViewText(R.id.card_detail, now.optString("detail"))

        val scale = scaleFor(size)
        if (small) {
            views.text(R.id.card_city, 12f, scale)
            views.text(R.id.card_temperature, 30f, scale)
            views.text(R.id.card_description, 12f, scale)
            views.text(R.id.card_detail, 12f, scale)
            views.image(R.id.card_icon_slot, 40f, scale)
        } else {
            views.setTextViewText(R.id.card_sunrise, now.optString("sunrise"))
            views.setTextViewText(R.id.card_wind, now.optString("wind"))
            views.setTextViewText(R.id.card_humidity, now.optString("humidity"))
            views.setTextViewText(R.id.card_updated, context.getString(R.string.widget_updated, content.updated))

            views.text(R.id.card_city, 12f, scale)
            views.text(R.id.card_label, 12f, scale)
            views.text(R.id.card_temperature, 44f, scale)
            views.text(R.id.card_description, 13f, scale)
            views.text(R.id.card_detail, 13f, scale)
            listOf(R.id.card_sunrise, R.id.card_wind, R.id.card_humidity).forEach { views.text(it, 12f, scale) }
            views.text(R.id.card_updated, 10f, scale)
            views.image(R.id.card_icon_slot, 64f, scale)
            listOf(R.id.card_sunrise_icon, R.id.card_wind_icon, R.id.card_humidity_icon).forEach {
                views.image(it, 16f, scale)
            }
        }
        return views
    }

    /**
     * How much to enlarge the text and icons so they fill a bigger card. The
     * layouts are designed for the minimum size (about 250 x 110 dp); the scale
     * is capped by both dimensions so nothing overflows.
     */
    private fun scaleFor(card: SizeF?): Float {
        if (card == null) return 1f
        return minOf(card.height / 125f, card.width / 300f).coerceIn(1f, 1.6f)
    }

    private fun RemoteViews.text(id: Int, sp: Float, scale: Float) {
        if (scale != 1f) setTextViewTextSize(id, TypedValue.COMPLEX_UNIT_SP, sp * scale)
    }

    private fun RemoteViews.image(id: Int, dp: Float, scale: Float) {
        if (scale == 1f || Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return
        setViewLayoutWidth(id, dp * scale, TypedValue.COMPLEX_UNIT_DIP)
        setViewLayoutHeight(id, dp * scale, TypedValue.COMPLEX_UNIT_DIP)
    }

    /** The accent index the app saved; a missing or non-integer value counts as the first accent. */
    private fun accentOf(widgetData: SharedPreferences): Int =
        try {
            widgetData.getInt("accent", 0)
        } catch (e: ClassCastException) {
            0
        }

    private fun parseObject(json: String?): JSONObject? =
        try {
            json?.let { JSONObject(it) }
        } catch (e: Exception) {
            null
        }

    /**
     * The card's background for an accent index, in the order of GradientValues
     * in lib/theme/gradients.dart. Mapped explicitly (not by name lookup) so
     * resource shrinking keeps the drawables; an unknown index uses the first.
     */
    private fun backgroundFor(index: Int): Int =
        when (index) {
            1 -> R.drawable.widget_background_1
            2 -> R.drawable.widget_background_2
            3 -> R.drawable.widget_background_3
            4 -> R.drawable.widget_background_4
            5 -> R.drawable.widget_background_5
            6 -> R.drawable.widget_background_6
            7 -> R.drawable.widget_background_7
            8 -> R.drawable.widget_background_8
            else -> R.drawable.widget_background_0
        }

    /**
     * The animated icon for a condition: a ProgressBar playing frames that
     * tool/render_widget_icons_test.dart rendered from the app's Flare loops
     * (ICON_LOOPS=1). Mapped explicitly (not by name lookup) so resource shrinking
     * keeps the layouts; an unknown name uses the "few" icon.
     */
    private fun iconLayoutFor(name: String) =
        when (name) {
            "clear" -> R.layout.widget_icon_clear
            "clear-night" -> R.layout.widget_icon_clear_night
            "sunny" -> R.layout.widget_icon_sunny
            "sunny-night" -> R.layout.widget_icon_sunny_night
            "few" -> R.layout.widget_icon_few
            "few-night" -> R.layout.widget_icon_few_night
            "broken" -> R.layout.widget_icon_broken
            "rain" -> R.layout.widget_icon_rain
            "snow" -> R.layout.widget_icon_snow
            "thunder" -> R.layout.widget_icon_thunder
            "foggy" -> R.layout.widget_icon_foggy
            else -> R.layout.widget_icon_few
        }

    private companion object {
        /**
         * Cards narrower than this (dp) use the compact layout. The full card needs about
         * 250dp for the icon, temperature and the sunrise / wind / humidity row, so a 2x2
         * and a 3x2 (about 180dp) fall below it.
         */
        const val SMALL_WIDTH = 220f
    }
}
