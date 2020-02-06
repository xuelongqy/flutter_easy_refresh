import 'dart:async';

import 'package:example/widget/sample_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:example/generated/i18n.dart';

/// 空视图示例
class EmptyPage extends StatefulWidget {
  @override
  EmptyPageState createState() {
    return EmptyPageState();
  }
}

class EmptyPageState extends State<EmptyPage> {
  // 总数
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).emptyWidget),
        backgroundColor: Colors.white,
      ),
      body: EasyRefresh.custom(
        emptyWidget: _count == 0
            ? Container(
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: SizedBox(),
                      flex: 2,
                    ),
                    SizedBox(
                      width: 100.0,
                      height: 100.0,
                      child: Image.asset('assets/image/nodata.png'),
                    ),
                    Text(
                      S.of(context).noData,
                      style: TextStyle(fontSize: 16.0, color: Colors.grey[400]),
                    ),
                    Expanded(
                      child: SizedBox(),
                      flex: 3,
                    ),
                  ],
                ),
              )
            : null,
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
