package com.example.loadweb

import android.app.Activity
import android.os.Bundle
import android.util.Log
import android.view.View
import android.webkit.WebSettings
import android.webkit.WebView

class WebViewActivity: Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val filePath = intent.extras?.getString("filePath","")?:""
        setContentView(R.layout.activity_webview)
        val webView: WebView = findViewById<View>(R.id.webview) as WebView

        Log.e("filePath",filePath)

        webView.settings.javaScriptEnabled = true
        webView.settings.allowFileAccess = true
        webView.settings.domStorageEnabled = true
        webView.settings.setSupportMultipleWindows(true)
        webView.settings.allowContentAccess = true
        webView.settings.allowUniversalAccessFromFileURLs = true
        val url = "file://" + filePath
        Log.e("url",url)
        webView.loadUrl(url)
    }
}