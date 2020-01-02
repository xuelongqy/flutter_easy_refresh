import 'package:example/widget/circular_icon.dart';
import 'package:example/widget/list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:example/generated/i18n.dart';
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
      body: EasyRefresh.custom(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 100.0,
            pinned: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              title: Text(S.of(context).supportAuthor),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              ListItem(
                title: S.of(context).star,
                icon: CircularIcon(
                  bgColor: Colors.green,
                  icon: Icons.star,
                ),
                onPressed: () {
                  launch("https://github.com/xuelongqy/flutter_easyrefresh");
                },
              ),
              ListItem(
                title: S.of(context).aliPay,
                icon: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  child: Center(
                    child: ImageIcon(
                      AssetImage("assets/image/alipay.png"),
                      color: Colors.white,
                    ),
                  ),
                ),
                onPressed: () {
                  _nativeChannel.invokeMethod(_alipayDonation);
                },
              ),
//            ListItem(
//              title: S.of(context).weiXinPay,
//              icon: ImageIcon(AssetImage("assets/image/weixin.png"),
//                color: Colors.orange,
//              ),
//            ),
//            ListItem(
//              title: S.of(context).qqPay,
//              icon: ImageIcon(AssetImage("assets/image/QQ.png"),
//                color: Colors.orange,
//              ),
//            ),
              ListItem(
                title: S.of(context).payPal,
                icon: Container(
                  padding: EdgeInsets.all(
                    5.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  child: Center(
                    child: ImageIcon(
                      AssetImage("assets/image/paypal.png"),
                      color: Colors.white,
                    ),
                  ),
                ),
                onPressed: () {
                  launch(
                      "https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=334PPRBZTY3J8&source=url");
                },
              ),
            ]),
          )
        ],
      ),
    );
  }
}
