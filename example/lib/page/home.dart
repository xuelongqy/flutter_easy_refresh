import 'package:example/page/more/more.dart';
import 'package:example/page/sample/sample.dart';
import 'package:example/page/style/style.dart';
import 'package:flutter/material.dart';
import 'package:example/generated/i18n.dart';

/// 主页面
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 页面控制
  PageController _pageController;
  // 当前页面
  int _pageIndex = 0;

  // 初始化
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // 底部栏切换
  void _onBottomNavigationBarTap(int index) {
    _pageController.animateToPage(index,
        duration: Duration(milliseconds: 200), curve: Curves.linear);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: <Widget>[SamplePage(), StylePage(), MorePage()],
        onPageChanged: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageIndex,
        type: BottomNavigationBarType.fixed,
        fixedColor: Colors.black,
        onTap: _onBottomNavigationBarTap,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), title: Text(S.of(context).sample)),
          BottomNavigationBarItem(
              icon: Icon(Icons.style), title: Text(S.of(context).style)),
          BottomNavigationBarItem(
              icon: Icon(Icons.more_vert), title: Text(S.of(context).more)),
        ],
      ),
    );
  }
}
