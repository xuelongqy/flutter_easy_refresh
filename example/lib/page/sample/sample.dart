import 'package:example/page/sample/basic.dart';
import 'package:example/page/sample/chat.dart';
import 'package:example/page/sample/link_header.dart';
import 'package:example/page/sample/empty.dart';
import 'package:example/page/sample/first_refresh.dart';
import 'package:example/page/sample/nested_scroll_view.dart';
import 'package:example/page/sample/second_floor.dart';
import 'package:example/page/sample/swiper.dart';
import 'package:example/page/sample/test.dart';
import 'package:example/page/sample/user_profile.dart';
import 'package:example/widget/circular_icon.dart';
import 'package:example/widget/list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:example/generated/i18n.dart';
import 'package:flutter/foundation.dart';

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
      body: EasyRefresh.custom(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 100.0,
            pinned: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              title: Text(S.of(context).sample),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              // 基本使用
              ListItem(
                title: S.of(context).basicUse,
                describe: S.of(context).basicUseDescribe,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (BuildContext context) {
                      return BasicPage(S.of(context).basicUse);
                    },
                  ));
                },
                icon: CircularIcon(
                  bgColor: Theme.of(context).primaryColor,
                  icon: Icons.format_list_bulleted,
                ),
              ),
              // 个人中心
              ListItem(
                title: S.of(context).userProfile,
                describe: S.of(context).userProfileDescribe,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (BuildContext context) {
                      return UserProfilePage();
                    },
                  ));
                },
                icon: CircularIcon(
                  bgColor: Colors.red,
                  icon: Icons.person,
                ),
              ),
              //  NestedScrollView
              ListItem(
                title: 'NestedScrollView',
                describe: S.of(context).nestedScrollViewDescribe,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (BuildContext context) {
                      return NestedScrollViewPage();
                    },
                  ));
                },
                icon: CircularIcon(
                  bgColor: Colors.green,
                  icon: Icons.line_style,
                ),
              ),
              //  Swiper
              ListItem(
                title: 'Swiper',
                describe: S.of(context).swiperDescribe,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (BuildContext context) {
                      return SwiperPage();
                    },
                  ));
                },
                icon: CircularIcon(
                  bgColor: Colors.deepOrangeAccent,
                  icon: Icons.view_array,
                ),
              ),
              //  首次刷新
              ListItem(
                title: S.of(context).firstRefresh,
                describe: S.of(context).firstRefreshDescribe,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (BuildContext context) {
                      return FirstRefreshPage();
                    },
                  ));
                },
                icon: CircularIcon(
                  bgColor: Colors.blueGrey,
                  icon: Icons.refresh,
                ),
              ),
              //  空视图
              ListItem(
                title: S.of(context).emptyWidget,
                describe: S.of(context).emptyWidgetDescribe,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (BuildContext context) {
                      return EmptyPage();
                    },
                  ));
                },
                icon: CircularIcon(
                  bgColor: Colors.grey,
                  icon: Icons.inbox,
                ),
              ),
              //  CustomHeader
              ListItem(
                title: S.of(context).linkHeader,
                describe: S.of(context).linkHeaderDescribeDescribe,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (BuildContext context) {
                      return LinkHeaderPage();
                    },
                  ));
                },
                icon: CircularIcon(
                  bgColor: Colors.amber[700],
                  icon: Icons.format_line_spacing,
                ),
              ),
              //  二楼
              ListItem(
                title: S.of(context).secondFloor,
                describe: S.of(context).secondFloorDescribe,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (BuildContext context) {
                      return SecondFloorPage();
                    },
                  ));
                },
                icon: CircularIcon(
                  bgColor: Colors.purple,
                  icon: Icons.view_agenda,
                ),
              ),
              //  聊天页面
              ListItem(
                title: S.of(context).chatPage,
                describe: S.of(context).chatPageDescribe,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (BuildContext context) {
                      return ChatPage();
                    },
                  ));
                },
                icon: CircularIcon(
                  bgColor: Colors.blueAccent,
                  icon: Icons.chat,
                ),
              ),
              //  测试页面
              kDebugMode
                  ? ListItem(
                      title: 'Test',
                      describe: 'EasyRefresh test page',
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (BuildContext context) {
                            return TestPage();
                          },
                        ));
                      },
                      icon: CircularIcon(
                        bgColor: Colors.black,
                        icon: Icons.build,
                      ),
                    )
                  : SizedBox(),
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
