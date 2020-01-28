import 'dart:async';

import 'package:example/header/bob_minion_header.dart';
import 'package:example/widget/sample_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:example/generated/i18n.dart';

/// 小黄人(Bob)样式
class BobMinionPage extends StatefulWidget {
  @override
  BobMinionPageState createState() {
    return BobMinionPageState();
  }
}

class BobMinionPageState extends State<BobMinionPage> {
  // 总数
  int _count = 20;
  // 动画类型
  BobMinionAnimation _animation = BobMinionAnimation.Stand;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).bobMinion),
        backgroundColor: Colors.white,
        actions: <Widget>[
          PopupMenuButton<BobMinionAnimation>(
            onSelected: (value) {
              setState(() {
                _animation = value;
              });
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuItem<BobMinionAnimation>>[
              const PopupMenuItem<BobMinionAnimation>(
                value: BobMinionAnimation.Stand,
                child: Text('Stand'),
              ),
              const PopupMenuItem<BobMinionAnimation>(
                value: BobMinionAnimation.Dance,
                child: Text('Dance'),
              ),
              const PopupMenuItem<BobMinionAnimation>(
                value: BobMinionAnimation.Jump,
                child: Text('Jump'),
              ),
              const PopupMenuItem<BobMinionAnimation>(
                value: BobMinionAnimation.Wave,
                child: Text('Wave'),
              ),
            ],
          ),
        ],
      ),
      body: EasyRefresh.custom(
        header: BobMinionHeader(animation: _animation),
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
