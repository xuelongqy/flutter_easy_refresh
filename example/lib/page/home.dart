import 'package:example/page/sample/sample.dart';
import 'package:flutter/material.dart';
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
        children: <Widget>[SamplePage(), Container(), Container()],
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
              title: Text(FlutterI18n.translate(context, 'more')))
        ],
      ),
    );
  }
}