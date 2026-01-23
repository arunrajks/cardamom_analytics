package com.cardamom.analytics

import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Enable edge-to-edge display before calling super.onCreate()
        // to comply with Android 15 standards.
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
    }
}
