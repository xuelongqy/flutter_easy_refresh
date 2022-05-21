import 'package:flutter/material.dart';
import 'package:flutter_easy_refresh/easy_refresh.dart';

import '../../widget/skeleton_item.dart';

class ClassicalPage extends StatefulWidget {
  const ClassicalPage({Key? key}) : super(key: key);

  @override
  State<ClassicalPage> createState() => _ClassicalPageState();
}

class _ClassicalPageState extends State<ClassicalPage> {
  int _count = 10;
  Axis _scrollDirection = Axis.vertical;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classical'),
      ),
      body: EasyRefresh(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 2));
          setState(() {
            _count = 10;
          });
        },
        onLoad: () async {
          await Future.delayed(const Duration(seconds: 2));
          setState(() {
            _count += 5;
          });
        },
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: _count,
          itemBuilder: (ctx, index) {
            return SkeletonItem(
              direction: _scrollDirection,
            );
          },
        ),
      ),
    );
  }
}
