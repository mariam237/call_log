package com.example.call_log

import android.app.role.RoleManager
import android.content.Context
import android.content.Intent
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.call_log/dialer_role"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "requestDialerRole") {
                    requestDialerRole(result)
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun requestDialerRole(result: MethodChannel.Result) {
        val roleManager = getSystemService(Context.ROLE_SERVICE) as RoleManager
        if (roleManager.isRoleAvailable(RoleManager.ROLE_DIALER)) {
            if (roleManager.isRoleHeld(RoleManager.ROLE_DIALER)) {
                result.success(true)
            } else {
                val intent = roleManager.createRequestRoleIntent(RoleManager.ROLE_DIALER)
                startActivityForResult(intent, 1)
                result.success(true)
            }
        } else {
            result.error("UNAVAILABLE", "Dialer role is unavailable", null)
        }
    }
}
