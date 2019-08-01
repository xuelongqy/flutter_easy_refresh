import 'package:example/page/sample/basic.dart';
import 'package:example/page/style/ball_pulse.dart';
import 'package:example/page/style/bezier_circle.dart';
import 'package:example/page/style/bezier_hour_glass.dart';
import 'package:example/page/style/bob_minion.dart';
import 'package:example/page/style/delivery.dart';
import 'package:example/page/style/material.dart';
import 'package:example/page/style/phoenix.dart';
import 'package:example/page/style/space.dart';
import 'package:example/page/style/taurus.dart';
import 'package:example/widget/circular_icon.dart';
import 'package:example/widget/list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// 样式页面
class StylePage extends StatefulWidget {
  @override
  _StylePageState createState() => _StylePageState();
}
class _StylePageState extends State<StylePage>
    with AutomaticKeepAliveClientMixin{
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: EasyRefresh.custom(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 100.0,
            pinned: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              title: Text(FlutterI18n.translate(context, 'style')),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              // 经典样式
              ListItem(
                title: FlutterI18n.translate(context, 'classic'),
                describe: FlutterI18n.translate(context, 'classicDescribe'),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                        return BasicPage(
                            FlutterI18n.translate(context, 'classic'));
                      },));
                },
                icon: CircularIcon(
                  bgColor: Theme.of(context).primaryColor,
                  icon: Icons.format_list_bulleted,
                ),
              ),
              // 质感设计
              ListItem(
                title: 'Material',
                describe: FlutterI18n.translate(context, 'materialDescribe'),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                        return MaterialPage();
                      },));
                },
                icon: CircularIcon(
                  bgColor: Colors.pink,
                  icon: Icons.android,
                ),
              ),
              // 球脉冲
              ListItem(
                title: 'BallPulse',
                describe: FlutterI18n.translate(context, 'ballPulseDescribe'),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                        return BallPulsePage();
                      },));
                },
                icon: CircularIcon(
                  bgColor: Colors.blue,
                  icon: Icons.lens,
                ),
              ),
              // 弹出圆圈
              ListItem(
                title: 'BezierCircle',
                describe: FlutterI18n.translate(context, 'bezierCircleDescribe'),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                        return BezierCirclePage();
                      },));
                },
                icon: CircularIcon(
                  bgColor: Colors.green,
                  icon: Icons.radio_button_checked,
                ),
              ),
              // BezierHourGlass
              ListItem(
                title: 'BezierHourGlass',
                describe: FlutterI18n.translate(context, 'bezierHourGlassDescribe'),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                        return BezierHourGlassPage();
                      },));
                },
                icon: CircularIcon(
                  bgColor: Colors.teal,
                  icon: Icons.timelapse,
                ),
              ),
              // 冲上云霄
              ListItem(
                title: 'Taurus',
                describe: FlutterI18n.translate(context, 'taurusDescribe'),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                        return TaurusPage();
                      },));
                },
                icon: CircularIcon(
                  bgColor: Colors.lightBlue,
                  icon: Icons.airplanemode_active,
                ),
              ),
              // 金色校园
              ListItem(
                title: 'Phoenix',
                describe: FlutterI18n.translate(context, 'phoenixDescribe'),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                        return PhoenixPage();
                      },));
                },
                icon: CircularIcon(
                  bgColor: Colors.amber[700],
                  icon: Icons.location_city,
                ),
              ),
              // 快递气球
              ListItem(
                title: 'Delivery',
                describe: FlutterI18n.translate(context, 'deliveryDescribe'),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                        return DeliveryPage();
                      },));
                },
                icon: CircularIcon(
                  bgColor: Colors.red,
                  icon: Icons.cloud,
                ),
              ),
              // 星空
              ListItem(
                title: 'Space',
                describe: FlutterI18n.translate(context, 'spaceDescribe'),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                        return SpacePage();
                      },));
                },
                icon: CircularIcon(
                  bgColor: Colors.blue,
                  icon: Icons.stars,
                ),
              ),
              // 小黄人
              ListItem(
                title: FlutterI18n.translate(context, 'bobMinion'),
                describe: FlutterI18n.translate(context, 'bobMinionDescribe'),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                        return BobMinionPage();
                      },));
                },
                icon: CircularIcon(
                  bgColor: Colors.amber[600],
                  icon: Icons.accessibility,
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}