import 'dart:async';

import 'package:example/header/space_header.dart';
import 'package:example/widget/sample_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

/// 星空样式
class SpacePage extends StatefulWidget {
  @override
  SpacePageState createState() {
    return SpacePageState();
  }
}

class SpacePageState extends State<SpacePage> {
  // 总数
  int _count = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Space'),
        backgroundColor: Colors.white,
      ),
      body: EasyRefresh.custom(
        header: SpaceHeader(),
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
