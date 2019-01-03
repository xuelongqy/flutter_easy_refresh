import 'package:example/generated/translations.dart';
import 'package:example/page/auto_load_page.dart';
import 'package:example/page/basic_page.dart';
import 'package:example/page/float_page.dart';
import 'package:example/page/list_embed_page.dart';
import 'package:example/page/sliver_page.dart';
import 'package:example/page/swiper_page.dart';
import 'package:example/page/user_profile_page.dart';
import 'package:example/widget/list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

/// 示例页面
class SamplePage extends StatefulWidget {
  @override
  _SamplePageState createState() => _SamplePageState();

}
class _SamplePageState extends State<SamplePage> {
  @override
  Widget build(BuildContext context) {
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
                Navigator.push(context,MaterialPageRoute(builder: (BuildContext context){
                  return BasicPage();
                }));
              },
              icon: Icon(Icons.format_list_bulleted,
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
                Navigator.push(context,MaterialPageRoute(builder: (BuildContext context){
                  return AutoLoadPage();
                }));
              },
              icon: Icon(Icons.autorenew,
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
                Navigator.push(context,MaterialPageRoute(builder: (BuildContext context){
                  return FloatPage();
                }));
              },
              icon: Icon(Icons.layers,
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
                Navigator.push(context,MaterialPageRoute(builder: (BuildContext context){
                  return UserProfilePage();
                }));
              },
              icon: Icon(Icons.person,
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
              describe: Translations.of(context).text("customScrollViewDescribe"),
              onPressed: () {
                Navigator.push(context,MaterialPageRoute(builder: (BuildContext context){
                  return SliverPage();
                }));
              },
              icon: Icon(Icons.format_line_spacing,
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
                Navigator.push(context,MaterialPageRoute(builder: (BuildContext context){
                  return SwiperPage();
                }));
              },
              icon: Icon(Icons.view_array,
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
                Navigator.push(context,MaterialPageRoute(builder: (BuildContext context){
                  return ListEmbedPage();
                }));
              },
              icon: Icon(Icons.view_day,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}