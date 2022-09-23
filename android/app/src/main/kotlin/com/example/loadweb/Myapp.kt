package com.example.loadweb

import android.os.StrictMode
import io.flutter.app.FlutterApplication

class MyApp:FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        val builder: StrictMode.VmPolicy.Builder = StrictMode.VmPolicy.Builder()
        StrictMode.setVmPolicy(builder.build())
    }
}