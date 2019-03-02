import 'package:example/generated/translations.dart';
import 'package:example/page/sample/auto_load_page.dart';
import 'package:example/page/sample/basic_page.dart';
import 'package:example/page/sample/cupertino_page.dart';
import 'package:example/page/sample/empty_widget_page.dart';
import 'package:example/page/sample/first_refresh_page.dart';
import 'package:example/page/sample/float_page.dart';
import 'package:example/page/sample/list_embed_page.dart';
import 'package:example/page/sample/manual_control_page.dart';
import 'package:example/page/sample/nested_scroll_view_page.dart';
import 'package:example/page/sample/scrollbar_page.dart';
import 'package:example/page/sample/second_floor_page.dart';
import 'package:example/page/sample/sliver_page.dart';
import 'package:example/page/sample/swiper_page.dart';
import 'package:example/page/sample/tab_view_page.dart';
import 'package:example/page/sample/user_profile_page.dart';
import 'package:example/widget/list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

/// 示例页面
class SamplePage extends StatefulWidget {
  @override
  _SamplePageState createState() => _SamplePageState();
}

class _SamplePageState extends State<SamplePage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text("sample")),
      ),
      body: EasyRefresh(
        behavior: ScrollOverBehavior(),
        child: ListView(
          children: <Widget>[
            ListItem(
              title: Translations.of(context).text("basicUse"),
              describe: Translations.of(context).text("basicUseDescribe"),
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
              title: Translations.of(context).text("manualControl"),
              describe: Translations.of(context).text("manualControlDescribe"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return ManualControlPage();
                }));
              },
              icon: Icon(
                Icons.gamepad,
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
              title: Translations.of(context).text("autoLoad"),
              describe: Translations.of(context).text("autoLoadDescribe"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return AutoLoadPage();
                }));
              },
              icon: Icon(
                Icons.autorenew,
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
              title: Translations.of(context).text("floatView"),
              describe: Translations.of(context).text("floatViewDescribe"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return FloatPage();
                }));
              },
              icon: Icon(
                Icons.layers,
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
              title: Translations.of(context).text("userProfile"),
              describe: Translations.of(context).text("userProfileDescribe"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return UserProfilePage();
                }));
              },
              icon: Icon(
                Icons.person,
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
              title: Translations.of(context).text("CustomScrollView"),
              describe:
                  Translations.of(context).text("customScrollViewDescribe"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return SliverPage();
                }));
              },
              icon: Icon(
                Icons.format_line_spacing,
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
              title: "Swiper",
              describe: Translations.of(context).text("swiperDescribe"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return SwiperPage();
                }));
              },
              icon: Icon(
                Icons.view_array,
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
              title: Translations.of(context).text("listEmbed"),
              describe: Translations.of(context).text("listEmbedDescribe"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return ListEmbedPage();
                }));
              },
              icon: Icon(
                Icons.view_day,
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
              title: "Cupertino",
              describe: Translations.of(context).text("cupertinoDescribe"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return CupertinoPage();
                }));
              },
              icon: Icon(
                Icons.color_lens,
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
              title: Translations.of(context).text("firstRefresh"),
              describe: Translations.of(context).text("firstRefreshDescribe"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return FirstRefreshPage();
                }));
              },
              icon: Icon(
                Icons.refresh,
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
              title: Translations.of(context).text("emptyWidget"),
              describe: Translations.of(context).text("emptyWidgetDescribe"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return EmptyWidgetPage();
                }));
              },
              icon: Icon(
                Icons.inbox,
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
              title: Translations.of(context).text("TabView"),
              describe: Translations.of(context).text("tabViewWidgetDescribe"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return TabViewPage();
                }));
              },
              icon: Icon(
                Icons.tab,
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
              title: Translations.of(context).text("NestedScrollView"),
              describe:
                  Translations.of(context).text("nestedScrollViewDescribe"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return NestedScrollViewPage();
                }));
              },
              icon: Icon(
                Icons.line_style,
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
              title: Translations.of(context).text("secondFloor"),
              describe: Translations.of(context).text("secondFloorDescribe"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return SecondFloorPage();
                }));
              },
              icon: Icon(
                Icons.view_agenda,
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
              title: Translations.of(context).text("scrollBar"),
              describe: Translations.of(context).text("scrollBarDescribe"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return ScrollBarPage();
                }));
              },
              icon: Icon(
                Icons.border_right,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
