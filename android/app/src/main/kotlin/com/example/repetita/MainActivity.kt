package com.example.repetita

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.view.HapticFeedbackConstants
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.math.abs

class MainActivity : FlutterActivity() {
    private val displayChannelName = "com.example.repetita/display_mode"
    private val hapticChannelName = "com.example.repetita/haptics"
    private val widgetChannelName = "com.example.repetita/widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 1. Display Mode & Refresh Rate Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, displayChannelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSupportedModes" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        @Suppress("DEPRECATION")
                        val display = windowManager.defaultDisplay
                        val modes = display.supportedModes.map { mode ->
                            mapOf(
                                "id" to mode.modeId,
                                "width" to mode.physicalWidth,
                                "height" to mode.physicalHeight,
                                "refreshRate" to mode.refreshRate.toDouble()
                            )
                        }
                        result.success(modes)
                    } else {
                        result.success(emptyList<Map<String, Any>>())
                    }
                }
                "setPreferredMode" -> {
                    val modeId = call.argument<Int>("modeId") ?: 0
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val params = window.attributes
                        params.preferredDisplayModeId = modeId
                        window.attributes = params
                        result.success(true)
                    } else {
                        result.success(false)
                    }
                }
                "setPreferredRefreshRate" -> {
                    val targetFps = call.argument<Double>("fps") ?: 0.0
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        if (targetFps <= 0.0) {
                            val params = window.attributes
                            params.preferredDisplayModeId = 0
                            window.attributes = params
                            result.success(true)
                        } else {
                            @Suppress("DEPRECATION")
                            val display = windowManager.defaultDisplay
                            val modes = display.supportedModes
                            val bestMode = modes.minByOrNull { abs(it.refreshRate - targetFps) }
                            if (bestMode != null) {
                                val params = window.attributes
                                params.preferredDisplayModeId = bestMode.modeId
                                window.attributes = params
                                result.success(true)
                            } else {
                                result.success(false)
                            }
                        }
                    } else {
                        result.success(false)
                    }
                }
                "getCurrentRefreshRate" -> {
                    val display = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                        context.display
                    } else {
                        @Suppress("DEPRECATION")
                        windowManager.defaultDisplay
                    }
                    result.success(display?.refreshRate?.toDouble() ?: 60.0)
                }
                else -> result.notImplemented()
            }
        }

        // 2. Direct Haptic & Tactile Feedback Channel (Bypasses global suppress when enabled in app)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, hapticChannelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "vibrate" -> {
                    val type = call.argument<String>("type") ?: "click"
                    val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        val vibratorManager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager
                        vibratorManager?.defaultVibrator
                    } else {
                        @Suppress("DEPRECATION")
                        getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
                    }

                    if (vibrator != null && vibrator.hasVibrator()) {
                        try {
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                                val effect = when (type) {
                                    "light" -> VibrationEffect.createPredefined(VibrationEffect.EFFECT_TICK)
                                    "medium" -> VibrationEffect.createPredefined(VibrationEffect.EFFECT_CLICK)
                                    "heavy" -> VibrationEffect.createPredefined(VibrationEffect.EFFECT_HEAVY_CLICK)
                                    "double_click" -> VibrationEffect.createPredefined(VibrationEffect.EFFECT_DOUBLE_CLICK)
                                    else -> VibrationEffect.createPredefined(VibrationEffect.EFFECT_CLICK)
                                }
                                vibrator.vibrate(effect)
                            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                val (duration, amplitude) = when (type) {
                                    "light" -> Pair(15L, 80)
                                    "medium" -> Pair(30L, 160)
                                    "heavy" -> Pair(50L, 255)
                                    else -> Pair(25L, 120)
                                }
                                vibrator.vibrate(VibrationEffect.createOneShot(duration, amplitude))
                            } else {
                                @Suppress("DEPRECATION")
                                vibrator.vibrate(25L)
                            }
                            result.success(true)
                            return@setMethodCallHandler
                        } catch (_: Exception) {
                            // Fall through to performHapticFeedback fallback
                        }
                    }

                    // Fallback using View with FLAG_IGNORE_GLOBAL_SETTING
                    val constant = when (type) {
                        "light" -> HapticFeedbackConstants.KEYBOARD_TAP
                        "medium" -> HapticFeedbackConstants.VIRTUAL_KEY
                        "heavy" -> HapticFeedbackConstants.LONG_PRESS
                        else -> HapticFeedbackConstants.KEYBOARD_TAP
                    }
                    window.decorView.performHapticFeedback(
                        constant,
                        HapticFeedbackConstants.FLAG_IGNORE_GLOBAL_SETTING
                    )
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // 3. App Widget Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, widgetChannelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "updateWidget" -> {
                    val dueCount = call.argument<Int>("dueCount") ?: 0
                    val newCount = call.argument<Int>("newCount") ?: 0
                    RepetitaAppWidgetProvider.updateWidget(this, dueCount, newCount)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
}
