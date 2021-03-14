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
  late EasyRefreshController _controller;

  // 通知器
  late LinkHeaderNotifier _headerNotifier;
  late LinkFooterNotifier _footerNotifier;

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
      //print(_footerNotifier.loadState);
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
          header: ClassicalHeader(
            enableInfiniteRefresh: true,
          ),
          notifier: _headerNotifier,
        ),
        footer: NotificationFooter(
          footer: ClassicalFooter(
            enableInfiniteLoad: true,
          ),
          notifier: _footerNotifier,
        ),
        controller: _controller,
        onRefresh: () async {
          print('refresh');
          await Future.delayed(Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _count = 20;
              });
            }
          });
        },
        onLoad: () async {
          print('load');
          await Future.delayed(Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _count += 1;
              });
            }
          });
        },
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return SampleListItem();
              },
              childCount: _count,
            ),
          ),
        ],
      ),
    );
  }
}
