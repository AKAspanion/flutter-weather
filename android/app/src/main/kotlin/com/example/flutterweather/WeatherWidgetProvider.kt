package com.example.flutterweather

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.os.Bundle
import android.util.SizeF
import android.util.TypedValue
import android.widget.RemoteViews
import androidx.core.widget.RemoteViewsCompat
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import org.json.JSONObject

/**
 * Home-screen widget: one card whose content changes when the user swipes up or
 * down inside it, between the current weather and the next 24 hours. (Home
 * screens keep left/right swipes for paging, so the hours are laid out side by
 * side.) The Flutter side (lib/services/weather_widget.dart) writes the values.
 *
 * The pages live in a StackView, the one widget view that snaps between items
 * on a swipe. A StackView normally looks like a fanned deck: it caps each page
 * (wrapped in a frame with [FRAME_PADDING] on every side) at 90% of its own
 * size and shifts the pages behind into the leftover space. On Android 12+,
 * where the exact card size is known, each page is sized to the card and the
 * StackView is enlarged past the card's edges so the front page lands exactly
 * on the card; the card clips to its outline, hiding the page behind.
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

    // The StackView's overhang follows the card's size, so re-render on resize.
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
            hours = parseArray(widgetData.getString("hours", null)),
        )

        // From Android 12 the launcher reports the exact sizes the widget is shown
        // at, which the overhang needs. Earlier versions show the stacked look.
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
                RemoteViews(sizes.associateWith { widgetViews(context, widgetId, content, it) })
            } else {
                widgetViews(context, widgetId, content, null)
            }
        appWidgetManager.updateAppWidget(widgetId, views)
    }

    private class Content(
        val city: String?,
        val updated: String,
        val now: JSONObject?,
        val hours: List<JSONObject>,
    )

    private fun widgetViews(context: Context, widgetId: Int, content: Content, size: SizeF?): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.weather_widget).apply {
            if (size != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) flattenStack(this, size)
            setEmptyView(R.id.widget_stack, R.id.widget_empty)
            setOnClickPendingIntent(
                R.id.widget_empty,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
            )
            setPendingIntentTemplate(R.id.widget_stack, openAppTemplate(context))
        }

        val items = RemoteViewsCompat.RemoteCollectionItems.Builder().setViewTypeCount(2)
        if (content.city != null && content.now != null) {
            items.addItem(0, nowCard(context, content.city, content.updated, content.now, size).sizedTo(size))
            if (content.hours.isNotEmpty()) {
                items.addItem(1, hoursCard(context, content.city, content.hours, size).sizedTo(size))
            }
        }
        RemoteViewsCompat.setRemoteAdapter(context, views, widgetId, R.id.widget_stack, items.build())
        return views
    }

    /**
     * Enlarges the StackView so a card-sized page fits inside its 90% cap with
     * [SLACK] to spare. With spare room StackView offsets the front page by
     * exactly (stack height - framed page height), which keeps the maths
     * independent of pixel rounding, and the margins place that page on the card.
     */
    private fun flattenStack(views: RemoteViews, card: SizeF) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return
        val stackWidth = (card.width + 2 * FRAME_PADDING) / 0.9f + SLACK
        val stackHeight = (card.height + 2 * FRAME_PADDING) / 0.9f + SLACK
        fun margin(type: Int, value: Float) =
            views.setViewLayoutMargin(R.id.widget_stack, type, value, TypedValue.COMPLEX_UNIT_DIP)
        margin(RemoteViews.MARGIN_START, -FRAME_PADDING)
        margin(RemoteViews.MARGIN_BOTTOM, -FRAME_PADDING)
        margin(RemoteViews.MARGIN_TOP, -(stackHeight - card.height - FRAME_PADDING))
        margin(RemoteViews.MARGIN_END, -(stackWidth - card.width - FRAME_PADDING))
    }

    /** Pages must be exactly the card's size for [flattenStack]; the root is the page's first view. */
    private fun RemoteViews.sizedTo(card: SizeF?) = apply {
        if (card == null || Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return@apply
        val root = if (layoutId == R.layout.weather_widget_item) R.id.card_root else R.id.hours_root
        setViewLayoutWidth(root, card.width, TypedValue.COMPLEX_UNIT_DIP)
        setViewLayoutHeight(root, card.height, TypedValue.COMPLEX_UNIT_DIP)
    }

    private fun nowCard(context: Context, city: String, updated: String, now: JSONObject, card: SizeF?) =
        RemoteViews(context.packageName, R.layout.weather_widget_item).apply {
            setTextViewText(R.id.card_city, city)
            setImageViewResource(R.id.card_icon, iconFor(now.optString("icon")))
            setTextViewText(R.id.card_temperature, now.optString("temperature"))
            setTextViewText(R.id.card_description, now.optString("description"))
            setTextViewText(R.id.card_detail, now.optString("detail"))
            setTextViewText(R.id.card_sunrise, now.optString("sunrise"))
            setTextViewText(R.id.card_wind, now.optString("wind"))
            setTextViewText(R.id.card_humidity, now.optString("humidity"))
            setTextViewText(R.id.card_updated, context.getString(R.string.widget_updated, updated))
            setOnClickFillInIntent(R.id.card_root, Intent())

            val scale = scaleFor(card)
            text(R.id.card_city, 12f, scale)
            text(R.id.card_label, 12f, scale)
            text(R.id.card_temperature, 44f, scale)
            text(R.id.card_description, 13f, scale)
            text(R.id.card_detail, 13f, scale)
            listOf(R.id.card_sunrise, R.id.card_wind, R.id.card_humidity).forEach { text(it, 12f, scale) }
            text(R.id.card_updated, 10f, scale)
            image(R.id.card_icon, 64f, scale)
            listOf(R.id.card_sunrise_icon, R.id.card_wind_icon, R.id.card_humidity_icon).forEach { image(it, 16f, scale) }
        }

    private fun hoursCard(context: Context, city: String, hours: List<JSONObject>, card: SizeF?) =
        RemoteViews(context.packageName, R.layout.weather_widget_hours).apply {
            val scale = scaleFor(card)
            setTextViewText(R.id.hours_city, city)
            text(R.id.hours_city, 12f, scale)
            text(R.id.hours_label, 12f, scale)
            removeAllViews(R.id.hours_row)
            hours.forEach { hour ->
                addView(
                    R.id.hours_row,
                    RemoteViews(context.packageName, R.layout.weather_widget_hour).apply {
                        setTextViewText(R.id.hour_label, hour.optString("label"))
                        setImageViewResource(R.id.hour_icon, iconFor(hour.optString("icon")))
                        setTextViewText(R.id.hour_temperature, hour.optString("temperature"))
                        text(R.id.hour_label, 11f, scale)
                        text(R.id.hour_temperature, 14f, scale)
                        image(R.id.hour_icon, 30f, scale)
                    },
                )
            }
            setOnClickFillInIntent(R.id.hours_root, Intent())
        }

    /**
     * How much to enlarge the pages' text and icons so they fill a bigger card.
     * The layouts are designed for the minimum size (about 250 x 110 dp); the
     * scale is capped by both dimensions so nothing overflows.
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

    private companion object {
        /** StackView wraps each page in a frame with this padding (dp), see StackView.FRAME_PADDING. */
        const val FRAME_PADDING = 4f

        /** Extra stack size (dp) beyond the 90% cap, so StackView spreads the pages predictably. */
        const val SLACK = 2f
    }
}
