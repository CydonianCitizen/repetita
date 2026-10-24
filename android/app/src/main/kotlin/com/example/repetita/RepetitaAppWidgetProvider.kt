package com.example.repetita

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

class RepetitaAppWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val dueCount = prefs.getInt(KEY_DUE_COUNT, 0)
        val newCount = prefs.getInt(KEY_NEW_COUNT, 0)

        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId, dueCount, newCount)
        }
    }

    companion object {
        private const val PREFS_NAME = "repetita_widget_prefs"
        private const val KEY_DUE_COUNT = "widget_due_count"
        private const val KEY_NEW_COUNT = "widget_new_count"

        fun updateWidget(context: Context, dueCount: Int, newCount: Int) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            prefs.edit()
                .putInt(KEY_DUE_COUNT, dueCount)
                .putInt(KEY_NEW_COUNT, newCount)
                .apply()

            val appWidgetManager = AppWidgetManager.getInstance(context)
            val thisAppWidget = ComponentName(context, RepetitaAppWidgetProvider::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(thisAppWidget)

            for (appWidgetId in appWidgetIds) {
                updateAppWidget(context, appWidgetManager, appWidgetId, dueCount, newCount)
            }
        }

        private fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
            dueCount: Int,
            newCount: Int
        ) {
            val views = RemoteViews(context.packageName, R.layout.repetita_appwidget)
            views.setTextViewText(R.id.widget_due_count, dueCount.toString())
            views.setTextViewText(
                R.id.widget_status,
                when (dueCount) {
                    0 -> "Tutto ripassato per oggi!"
                    1 -> "1 carta da ripassare"
                    else -> "$dueCount carte da ripassare"
                }
            )
            if (newCount > 0) {
                views.setViewVisibility(R.id.widget_new_count, android.view.View.VISIBLE)
                views.setTextViewText(R.id.widget_new_count, "+$newCount nuove")
            } else {
                views.setViewVisibility(R.id.widget_new_count, android.view.View.GONE)
            }

            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
