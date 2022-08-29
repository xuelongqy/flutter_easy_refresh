import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:example/widget/skeleton_item.dart';
import 'package:flutter/material.dart';

class TestMaxPullHeightPage extends StatefulWidget {
  const TestMaxPullHeightPage({Key? key}) : super(key: key);

  @override
  _TestMaxPullHeightPageState createState() => _TestMaxPullHeightPageState();
}

class _TestMaxPullHeightPageState extends State<TestMaxPullHeightPage> {
  int _listCount = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TestMaxPullHeight'),
      ),
      body: EasyRefresh(
        header: const ClassicHeader(maxPullHeight: 150),
        footer: const ClassicFooter(maxPullHeight: 150),
        child: CustomScrollView(
          slivers: [
            SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
              return const SkeletonItem();
            }, childCount: _listCount)),
          ],
        ),
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _listCount = 20;
              });
            }
          });
        },
        onLoad: () async {
          if (_listCount >= 20) {
            return;
          }
          await Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _listCount += 10;
              });
            }
          });
        },
      ),
    );
  }
}
