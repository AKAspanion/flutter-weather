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
 * Three layouts: a mini one (just the temperature) for a card shorter than [STRIP_HEIGHT] or
 * narrower than [MINI_WIDTH], the wide card from [WIDE_WIDTH] (full width), and a compact
 * one for anything in between, which keeps its sunrise / wind / humidity row from
 * [DETAILS_WIDTH] (3 cells) and hides it below (2x2). On Android 12+ the
 * launcher reports every size the widget can be shown at, and one RemoteViews is
 * rendered per size so the host picks the layout that fits; earlier versions get
 * the layout for the size the options report.
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
        // The mini layout is chosen first; without a known size, the wide layout is the default.
        val mini = size != null && (size.height < STRIP_HEIGHT || size.width < MINI_WIDTH)
        val small = !mini && size != null && size.width < WIDE_WIDTH
        val views = RemoteViews(
            context.packageName,
            when {
                mini -> R.layout.weather_widget_mini
                small -> R.layout.weather_widget_small
                else -> R.layout.weather_widget
            },
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

        if (mini && size != null) {
            fillMini(context, views, now, size)
            return views
        }

        // A compact card taller than it is wide stacks the icon above the temperature; the others
        // put them side by side. The ids the provider fills are those of the arrangement it shows.
        val tall = small && size != null && size.height > size.width
        val iconSlot = if (tall) R.id.card_icon_slot_tall else R.id.card_icon_slot
        val temperature = if (tall) R.id.card_temperature_tall else R.id.card_temperature
        if (small) {
            views.setViewVisibility(R.id.card_row, if (tall) View.GONE else View.VISIBLE)
            views.setViewVisibility(R.id.card_stack, if (tall) View.VISIBLE else View.GONE)
        }

        views.setTextViewText(R.id.card_city, city)
        // The icon is an animated layout, swapped into the slot on every render.
        views.removeAllViews(iconSlot)
        views.addView(iconSlot, RemoteViews(context.packageName, iconLayoutFor(now.optString("icon"))))
        views.setTextViewText(temperature, now.optString("temperature"))
        views.setTextViewText(R.id.card_description, now.optString("description"))
        views.setTextViewText(R.id.card_detail, now.optString("detail"))

        views.setTextViewText(R.id.card_sunrise, now.optString("sunrise"))
        views.setTextViewText(R.id.card_wind, now.optString("wind"))
        views.setTextViewText(R.id.card_humidity, now.optString("humidity"))

        val scale = scaleFor(size)
        if (small) {
            // The details row is for 3 cells and wider; a 2x2 has no room for it.
            val details = size != null && size.width >= DETAILS_WIDTH
            views.setViewVisibility(R.id.card_details, if (details) View.VISIBLE else View.GONE)

            views.text(R.id.card_city, 12f, scale)
            views.text(R.id.card_label, 12f, scale)
            // The icon and the temperature fill the card's middle block, so they grow with it.
            val compactScale = compactScaleFor(size)
            views.text(temperature, 30f, compactScale)
            views.text(R.id.card_description, 12f, scale)
            views.text(R.id.card_detail, 12f, scale)
            listOf(R.id.card_sunrise, R.id.card_wind, R.id.card_humidity).forEach { views.text(it, 12f, scale) }
            views.image(iconSlot, 40f, compactScale)
            listOf(R.id.card_sunrise_icon, R.id.card_wind_icon, R.id.card_humidity_icon).forEach {
                views.image(it, 16f, scale)
            }
        } else {
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
     * The mini layout: only the temperature, centred, sized to the card, with the icon before it
     * from [MINI_WIDTH]. The temperature grows with the card's height (about half of it) but is
     * held to what fits the width, so "-12°" is never clipped in a 1x1.
     */
    private fun fillMini(context: Context, views: RemoteViews, now: JSONObject, size: SizeF) {
        val icon = size.width >= MINI_WIDTH
        val widthForText = size.width - 2 * MINI_PADDING - if (icon) MINI_ICON_GAP else 0f
        val ems = MINI_TEXT_EMS + if (icon) MINI_ICON_EMS else 0f
        val textSp = minOf(size.height * MINI_TEXT_HEIGHT_RATIO, widthForText / ems)

        views.setTextViewText(R.id.card_temperature, now.optString("temperature"))
        views.setTextViewTextSize(R.id.card_temperature, TypedValue.COMPLEX_UNIT_SP, textSp)

        views.setViewVisibility(R.id.card_icon_slot, if (icon) View.VISIBLE else View.GONE)
        if (icon) {
            views.removeAllViews(R.id.card_icon_slot)
            views.addView(R.id.card_icon_slot, RemoteViews(context.packageName, iconLayoutFor(now.optString("icon"))))
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                views.setViewLayoutWidth(R.id.card_icon_slot, textSp * MINI_ICON_EMS, TypedValue.COMPLEX_UNIT_DIP)
                views.setViewLayoutHeight(R.id.card_icon_slot, textSp * MINI_ICON_EMS, TypedValue.COMPLEX_UNIT_DIP)
            }
        }
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

    /**
     * The scale of the compact layout's icon and temperature, which grow with the card. A card at
     * least as wide as it is tall (side by side) is capped by both dimensions, and a 3x2 (about
     * 235 x 217 dp) reaches the 1.6x cap; a taller one (stacked, a 2x2 of about 150 x 217 dp) uses
     * its own design size and gets about 1.45x.
     */
    private fun compactScaleFor(card: SizeF?): Float {
        if (card == null) return 1f
        val scale =
            if (card.height > card.width) {
                minOf(card.width / TALL_DESIGN_WIDTH, card.height / TALL_DESIGN_HEIGHT)
            } else {
                minOf(card.width / COMPACT_DESIGN_WIDTH, card.height / COMPACT_DESIGN_HEIGHT)
            }
        return scale.coerceIn(1f, 1.6f)
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
         * Cards at least this wide (dp) use the wide layout, which is full width (4 cells);
         * narrower ones use the compact layout. Launchers report a 3x2 card as about 235dp
         * (One UI) and a 4-cell one above 300dp.
         */
        const val WIDE_WIDTH = 300f

        /**
         * The compact layout shows its sunrise / wind / humidity row at least this wide (dp),
         * which is 3 cells (about 235dp); a 2x2 (about 129dp) has no room for it.
         */
        const val DETAILS_WIDTH = 220f

        /**
         * The size (dp) the side-by-side compact layout is designed for; [compactScaleFor] scales
         * from it. The height is lower than a 2x2's so a 3x2 (about 235 x 217 dp) reaches the cap.
         */
        const val COMPACT_DESIGN_WIDTH = 130f
        const val COMPACT_DESIGN_HEIGHT = 135f

        /** The size (dp) the stacked compact layout (a card taller than wide, a 2x2) is designed for. */
        const val TALL_DESIGN_WIDTH = 100f
        const val TALL_DESIGN_HEIGHT = 150f

        /** A card shorter than this (dp) is one row (1x2, 1x3, 1x4) and uses weather_widget_mini.xml. */
        const val STRIP_HEIGHT = 150f

        /**
         * A card narrower than this (dp) is one cell (1x1) and uses weather_widget_mini.xml; the mini
         * layout shows the icon from this width.
         */
        const val MINI_WIDTH = 110f

        /** The mini layout's padding and the gap before its temperature (dp); match weather_widget_mini.xml. */
        const val MINI_PADDING = 8f
        const val MINI_ICON_GAP = 4f

        /** The mini temperature's size (sp) as a share of the card's height: it fills about half of it. */
        const val MINI_TEXT_HEIGHT_RATIO = 0.45f

        /** The width of "-12°" in sans-serif-medium, in ems (about 1.85, rounded up), so it never clips. */
        const val MINI_TEXT_EMS = 2.1f

        /** The mini icon's size, in ems of the temperature's size, so the icon grows with the text. */
        const val MINI_ICON_EMS = 1.1f
    }
}
