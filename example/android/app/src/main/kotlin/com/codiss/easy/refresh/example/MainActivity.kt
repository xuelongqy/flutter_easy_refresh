package com.codiss.easy.refresh.example

import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel
import moe.feng.alipay.zerosdk.AlipayZeroSdk

class MainActivity: FlutterActivity() {
  // 伴生对象
  companion object {
    // 交互通道名字
    const val CHANNEL = "com.codiss.easy.refresh.example/channel"
    // 支付宝捐赠
    const val ALIPAY_DONATION = "aliPayDonation"
  }
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    // 取消全屏
    window.clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      //API>21,设置状态栏颜色透明
      window.statusBarColor = 0
    }
  }

  // 配置Flutter引擎
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    // 注册插件
    GeneratedPluginRegistrant.registerWith(flutterEngine)
    flutterEngine.plugins.add(object : FlutterPlugin {
      override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // 注册通道
        MethodChannel(binding.binaryMessenger, CHANNEL).setMethodCallHandler { methodCall, _ ->
          // 判断交互方法
          when (methodCall.method) {
            ALIPAY_DONATION -> AlipayZeroSdk.startAlipayClient(this@MainActivity, "FKX03889Z997BS1BNALOC9")
          }
        }
      }

      override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {}
    })
  }
}
