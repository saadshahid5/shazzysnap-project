package com.shazzysnap

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import vn.hunghd.flutterdownloader.FlutterDownloaderPlugin

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        FlutterDownloaderPlugin.enqueueIsolate()
    }
}
