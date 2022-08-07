import 'package:example/page/more/more_page.dart';
import 'package:example/page/sample/sample_page.dart';
import 'package:example/page/style/style_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 主页面
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Page Controller.
  late PageController _pageController;
  // Current page.
  int _pageIndex = 0;

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

  // Change page.
  void _onBottomNavigationBarTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.linear,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: const <Widget>[SamplePage(), StylePage(), MorePage()],
        onPageChanged: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageIndex,
        type: BottomNavigationBarType.fixed,
        onTap: _onBottomNavigationBarTap,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: 'Sample'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.style),
            label: 'Style'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.more_vert),
            label: 'More'.tr,
          ),
        ],
      ),
    );
  }
}
