import 'package:example/page/more/more.dart';
import 'package:example/page/sample/sample.dart';
import 'package:example/page/stype/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// 主页面
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}
class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // 页面控制
  TabController _tabController;

  // 初始化
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    SchedulerBinding.instance.addPostFrameCallback((Duration timestamp) {
      // 设置EasyRefresh的默认样式
      EasyRefresh.defaultHeader = ClassicalHeader(
        enableInfiniteRefresh: false,
        refreshText: FlutterI18n.translate(context, 'pullToRefresh'),
        refreshReadyText: FlutterI18n.translate(context, 'releaseToRefresh'),
        refreshingText: FlutterI18n.translate(context, 'refreshing'),
        refreshedText: FlutterI18n.translate(context, 'refreshed'),
        refreshFailedText: FlutterI18n.translate(context, 'refreshFailed'),
        noMoreText: FlutterI18n.translate(context, 'noMore'),
        infoText: FlutterI18n.translate(context, 'updateAt'),
      );
      EasyRefresh.defaultFooter = ClassicalFooter(
        enableInfiniteLoad: true,
        loadText: FlutterI18n.translate(context, 'pushToLoad'),
        loadReadyText: FlutterI18n.translate(context, 'releaseToLoad'),
        loadingText: FlutterI18n.translate(context, 'loading'),
        loadedText: FlutterI18n.translate(context, 'loaded'),
        loadFailedText: FlutterI18n.translate(context, 'loadFailed'),
        noMoreText: FlutterI18n.translate(context, 'noMore'),
        infoText: FlutterI18n.translate(context, 'updateAt'),
      );
    });
  }

  // 底部栏切换
  void _onBottomNavigationBarTap(int index) {
    setState(() {
      _tabController.index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[SamplePage(), StylePage(), MorePage()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabController.index,
        type: BottomNavigationBarType.fixed,
        fixedColor: Colors.black,
        onTap: _onBottomNavigationBarTap,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              title: Text(FlutterI18n.translate(context, 'sample'))),
          BottomNavigationBarItem(
              icon: Icon(Icons.style),
              title: Text(FlutterI18n.translate(context, 'style'))),
          BottomNavigationBarItem(
              icon: Icon(Icons.more_vert),
              title: Text(FlutterI18n.translate(context, 'more'))),
        ],
      ),
    );
  }
}