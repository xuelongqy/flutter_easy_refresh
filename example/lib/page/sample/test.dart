import 'dart:async';

import 'package:example/widget/sample_list_item.dart';
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
  int _count = 20;
  // 控制器
  EasyRefreshController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController();
    Future.delayed(Duration(seconds: 1), () {
      _controller.callRefresh();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test'),
        backgroundColor: Colors.white,
      ),
      body: EasyRefresh(
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
              _count += 20;
            });
          });
        },
        child: Container(),
      ),
    );
  }
}