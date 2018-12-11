package com.qingyi.easyrefresh.example

import android.os.Build
import android.os.Bundle
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      //API>21,设置状态栏颜色透明
      window.statusBarColor = 0
    }
    GeneratedPluginRegistrant.registerWith(this)
  }
}
