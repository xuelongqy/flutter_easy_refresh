import 'dart:async';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EasyRefresh'),
      ),
      body: EasyRefresh(
        onRefresh: () async {
          await Future.delayed(Duration(seconds: 5));
        },
        onLoad: () async {
          await Future.delayed(Duration(seconds: 5));
        },
        child: ListView(
          padding: EdgeInsets.zero,
          scrollDirection: scrollDirection,
          children: [
            Container(
              width: scrollDirection == Axis.vertical ? double.infinity : 400,
              height: scrollDirection == Axis.vertical ? 1000 : double.infinity,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
