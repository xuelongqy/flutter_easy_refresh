import 'dart:async';

import 'package:example/widget/sample_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final scrollDirection = Axis.vertical;

  @override
  void initState() {
    super.initState();
    // Future.delayed(Duration(seconds: 1), () {
    //   PrimaryScrollController.of(context)!.position.jumpTo(-70);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EasyRefresh'),
      ),
      body: EasyRefresh(
        onRefresh: () async {
          print('Refreshing');
          await Future.delayed(Duration(seconds: 5));
          print('Refreshed');
        },
        onLoad: () async {
          print('Loading');
          await Future.delayed(Duration(seconds: 5));
          print('Loaded');
        },
        child: ListView.builder(
          padding: EdgeInsets.zero,
          scrollDirection: scrollDirection,
          itemCount: 5,
          itemBuilder: (context, index) {
            return SampleListItem(
              direction: scrollDirection,
              width: scrollDirection == Axis.vertical ? double.infinity : 200,
            );
          },
        ),
      ),
    );
  }
}
