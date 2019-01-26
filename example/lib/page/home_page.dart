import 'package:example/generated/translations.dart';
import 'package:example/page/more_page.dart';
import 'package:example/page/sample_page.dart';
import 'package:example/page/style_page.dart';
import 'package:flutter/material.dart';

/// 主页面
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // 页面控制
  TabController _tabController;

  // 底部栏切换
  void _onBottomNavigationBarTap(int index) {
    setState(() {
      _tabController.index = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(initialIndex: 0, length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
              title: Text(Translations.of(context).text("sample"))),
          BottomNavigationBarItem(
              icon: Icon(Icons.style),
              title: Text(Translations.of(context).text("style"))),
          BottomNavigationBarItem(
              icon: Icon(Icons.more_vert),
              title: Text(Translations.of(context).text("more")))
        ],
      ),
    );
  }
}
