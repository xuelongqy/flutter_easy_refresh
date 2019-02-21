import 'package:example/generated/translations.dart';
import 'package:example/widget/list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

/// 支持页面
class SupportPage extends StatefulWidget {
  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  // 交互通道名字
  final String _channel = "com.qingyi.easyrefresh.example/channel";
  // 支付宝捐赠
  final String _alipayDonation = "aliPayDonation";
  // 交互通道
  MethodChannel _nativeChannel;

  // 初始化
  @override
  void initState() {
    super.initState();
    _nativeChannel = MethodChannel(_channel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text("supportAuthor")),
      ),
      body: EasyRefresh(
        behavior: ScrollOverBehavior(),
        child: ListView(
          children: <Widget>[
            ListItem(
              title: Translations.of(context).text("star"),
              icon: Icon(
                Icons.star,
                size: 30.0,
                color: Colors.orange,
              ),
              onPressed: () {
                launch("https://github.com/xuelongqy/flutter_easyrefresh");
              },
            ),
            Container(
              width: double.infinity,
              height: 0.5,
              padding: EdgeInsets.only(left: 5.0, right: 5.0),
              child: Container(
                color: Colors.black12,
              ),
            ),
            ListItem(
              title: Translations.of(context).text("aliPay"),
              icon: ImageIcon(
                AssetImage("assets/image/alipay.png"),
                color: Colors.orange,
              ),
              onPressed: () {
                _nativeChannel.invokeMethod(_alipayDonation);
              },
            ),
//            Container(
//              width: double.infinity,
//              height: 0.5,
//              padding: EdgeInsets.only(left: 5.0, right: 5.0),
//              child: Container(
//                color: Colors.black12,
//              ),
//            ),
//            ListItem(
//              title: Translations.of(context).text("weiXinPay"),
//              icon: ImageIcon(AssetImage("assets/image/weixin.png"),
//                color: Colors.orange,
//              ),
//            ),
//            Container(
//              width: double.infinity,
//              height: 0.5,
//              padding: EdgeInsets.only(left: 5.0, right: 5.0),
//              child: Container(
//                color: Colors.black12,
//              ),
//            ),
//            ListItem(
//              title: Translations.of(context).text("qqPay"),
//              icon: ImageIcon(AssetImage("assets/image/QQ.png"),
//                color: Colors.orange,
//              ),
//            ),
            Container(
              width: double.infinity,
              height: 0.5,
              padding: EdgeInsets.only(left: 5.0, right: 5.0),
              child: Container(
                color: Colors.black12,
              ),
            ),
            ListItem(
              title: Translations.of(context).text("payPal"),
              icon: ImageIcon(
                AssetImage("assets/image/paypal.png"),
                color: Colors.orange,
              ),
              onPressed: () {
                launch(
                    "https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=334PPRBZTY3J8&source=url");
              },
            ),
          ],
        ),
      ),
    );
  }
}
