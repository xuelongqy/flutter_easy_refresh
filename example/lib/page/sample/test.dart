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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test'),
        backgroundColor: Colors.white,
      ),
      body: EasyRefresh(
        onRefresh: () async {
          await Future.delayed(Duration(seconds: 2), () {
            setState(() {
              _count = 20;
            });
          });
        },
        onLoad: () async {
          await Future.delayed(Duration(seconds: 2), () {
            setState(() {
              _count += 20;
            });
          });
        },
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Text('EasyRefresh'),
              Text('EasyRefresh'),
              Text('EasyRefresh'),
            ],
          ),
        ),
      ),
    );
  }
}