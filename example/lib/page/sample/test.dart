import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

/// 测试界面
class TestPage extends StatefulWidget {
  @override
  TestPageState createState() {
    return TestPageState();
  }
}

class TestPageState extends State<TestPage> {
  // 总数
  int _count = 2;
  // 控制器
  EasyRefreshController _controller;

  // 通知器
  LinkHeaderNotifier _headerNotifier;
  LinkFooterNotifier _footerNotifier;

  @override
  void initState() {
    super.initState();
    _headerNotifier = LinkHeaderNotifier();
    _footerNotifier = LinkFooterNotifier();
    _controller = EasyRefreshController();
    _headerNotifier.addListener(() {
      //print(_headerNotifier.refreshState);
    });
    _footerNotifier.addListener(() {
      print(_footerNotifier.loadState);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _headerNotifier.dispose();
    _footerNotifier.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test'),
        backgroundColor: Colors.white,
      ),
      body: EasyRefresh.custom(
        header: NotificationHeader(
          header: ClassicalHeader(),
          notifier: _headerNotifier,
        ),
        footer: NotificationFooter(
          footer: ClassicalFooter(),
          notifier: _footerNotifier,
        ),
        controller: _controller,
        onRefresh: () async {
          print('refresh');
          await Future.delayed(Duration(seconds: 2), () {
            setState(() {
              _count = 20;
            });
          });
        },
        onLoad: () async {
          print('load');
          await Future.delayed(Duration(seconds: 2), () {
            setState(() {
              _count += 1;
            });
          });
        },
        slivers: <Widget>[
          if (_count > 0)
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 0.6),
              delegate: SliverChildBuilderDelegate((context, index) {
                return Card();
              }, childCount: _count),
            ),
        ],
      ),
    );
  }
}
