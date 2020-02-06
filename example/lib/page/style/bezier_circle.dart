import 'dart:async';

import 'package:example/widget/sample_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/bezier_circle_header.dart';
import 'package:flutter_easyrefresh/bezier_bounce_footer.dart';

/// 弹出圆圈样式
class BezierCirclePage extends StatefulWidget {
  @override
  BezierCirclePageState createState() {
    return BezierCirclePageState();
  }
}

class BezierCirclePageState extends State<BezierCirclePage> {
  // 总数
  int _count = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BezierCircle'),
        backgroundColor: Colors.white,
      ),
      body: EasyRefresh.custom(
        header: BezierCircleHeader(),
        footer: BezierBounceFooter(),
        onRefresh: () async {
          await Future.delayed(Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _count = 20;
              });
            }
          });
        },
        onLoad: () async {
          await Future.delayed(Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _count += 20;
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
