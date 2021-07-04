import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
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
          children: [
            Container(
              width: double.infinity,
              height: 1000,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
