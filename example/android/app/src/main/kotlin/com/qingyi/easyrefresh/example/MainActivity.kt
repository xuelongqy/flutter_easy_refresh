package com.qingyi.easyrefresh.example

import android.os.Build
import android.os.Bundle
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel
import moe.feng.alipay.zerosdk.AlipayZeroSdk


class MainActivity: FlutterActivity() {
  // 伴生对象
  companion object {
    // 交互通道名字
    val CHANNEL = "com.qingyi.easyrefresh.example/channel"
    // 支付宝捐赠
    val ALIPAY_DONATION = "aliPayDonation"
  }
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      //API>21,设置状态栏颜色透明
      window.statusBarColor = 0
    }
    // 注册通道
    MethodChannel(flutterView, CHANNEL).setMethodCallHandler { methodCall, result ->
      // 判断交互方法
      when (methodCall.method) {
        ALIPAY_DONATION -> AlipayZeroSdk.startAlipayClient(this, "FKX03889Z997BS1BNALOC9")
      }
    }
    GeneratedPluginRegistrant.registerWith(this)
  }
}
