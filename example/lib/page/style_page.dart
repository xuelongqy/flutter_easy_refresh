import 'package:example/generated/translations.dart';
import 'package:example/page/style/ball_pulse_page.dart';
import 'package:example/page/sample/basic_page.dart';
import 'package:example/page/style/bezier_circle_page.dart';
import 'package:example/page/style/bezier_hour_glass_page.dart';
import 'package:example/page/style/delivery_page.dart';
import 'package:example/page/style/material_page.dart';
import 'package:example/page/style/phoenix_page.dart';
import 'package:example/page/style/space_page.dart';
import 'package:example/page/style/taurus_page.dart';
import 'package:example/widget/list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

/// 样式页面
class StylePage extends StatefulWidget {
  @override
  _StylePageState createState() => _StylePageState();
}

class _StylePageState extends State<StylePage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text("style")),
      ),
      body: EasyRefresh(
        behavior: ScrollOverBehavior(),
        child: ListView(
          children: <Widget>[
            ListItem(
              title: "Classic",
              describe: Translations.of(context).text("classicDescribe"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return BasicPage();
                }));
              },
              icon: Icon(
                Icons.format_list_bulleted,
                color: Colors.orange,
              ),
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
              title: "Material",
              describe: Translations.of(context).text("materialDescribe"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return MaterialPage();
                }));
              },
              icon: Icon(
                Icons.android,
                color: Colors.orange,
              ),
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
              title: "BallPulse",
              describe: Translations.of(context).text("ballPulseDescribe"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return BallPulsePage();
                }));
              },
              icon: Icon(
                Icons.lens,
                color: Colors.orange,
              ),
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
              title: "BezierCircle",
              describe: Translations.of(context).text("bezierCircleDescribe"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return BezierCirclePage();
                }));
              },
              icon: Icon(
                Icons.radio_button_checked,
                color: Colors.orange,
              ),
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
              title: "BezierHourGlass",
              describe:
                  Translations.of(context).text("bezierHourGlassDescribe"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return BezierHourGlassPage();
                }));
              },
              icon: Icon(
                Icons.timelapse,
                color: Colors.orange,
              ),
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
              title: "Phoenix",
              describe: Translations.of(context).text("phoenixDescribe"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return PhoenixPage();
                }));
              },
              icon: Icon(
                Icons.location_city,
                color: Colors.orange,
              ),
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
              title: "Taurus",
              describe: Translations.of(context).text("taurusDescribe"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return TaurusPage();
                }));
              },
              icon: Icon(
                Icons.airplanemode_active,
                color: Colors.orange,
              ),
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
              title: "Space",
              describe: Translations.of(context).text("spaceDescribe"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return SpacePage();
                }));
              },
              icon: Icon(
                Icons.stars,
                color: Colors.orange,
              ),
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
              title: "Delivery",
              describe: Translations.of(context).text("deliveryDescribe"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return DeliveryPage();
                }));
              },
              icon: Icon(
                Icons.cloud,
                color: Colors.orange,
              ),
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
              title: Translations.of(context).text("moreStyle"),
              describe: Translations.of(context).text("moreStyleDescribe"),
              icon: Icon(
                Icons.style,
                color: Colors.orange,
              ),
              onPressed: () {
                launch(
                    "mqqopensdkapi://bizAgent/qm/qr?url=http%3A%2F%2Fqm.qq.com%2Fcgi-bin%2Fqm%2Fqr%3Ffrom%3Dapp%26p%3Dandroid%26k%3DMNLtkvnn4n28UIB0gEgm2-WBmqmGWk0Q");
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
