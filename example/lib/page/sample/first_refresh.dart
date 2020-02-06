import 'dart:async';

import 'package:example/widget/sample_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:example/generated/i18n.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

/// 首次刷新示例
class FirstRefreshPage extends StatefulWidget {
  @override
  FirstRefreshPageState createState() {
    return FirstRefreshPageState();
  }
}

class FirstRefreshPageState extends State<FirstRefreshPage> {
  // 总数
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).firstRefresh),
        backgroundColor: Colors.white,
      ),
      body: EasyRefresh.custom(
        firstRefresh: true,
        firstRefreshWidget: Container(
          width: double.infinity,
          height: double.infinity,
          child: Center(
              child: SizedBox(
            height: 200.0,
            width: 300.0,
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 50.0,
                    height: 50.0,
                    child: SpinKitFadingCube(
                      color: Theme.of(context).primaryColor,
                      size: 25.0,
                    ),
                  ),
                  Container(
                    child: Text(S.of(context).loading),
                  )
                ],
              ),
            ),
          )),
        ),
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
      ),
    );
  }
}
