import 'package:example/widget/skeleton_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';

class BezierCirclePage extends StatefulWidget {
  const BezierCirclePage({Key? key}) : super(key: key);

  @override
  State<BezierCirclePage> createState() => _BezierCirclePageState();
}

class _BezierCirclePageState extends State<BezierCirclePage> {
  int _count = 10;
  late EasyRefreshController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bezier circle'.tr),
      ),
      body: EasyRefresh(
        controller: _controller,
        header: BezierCircleHeader(),
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 2));
          setState(() {
            _count = 10;
          });
          _controller.finishRefresh();
          _controller.resetFooter();
        },
        onLoad: () async {
          await Future.delayed(const Duration(seconds: 2));
          setState(() {
            _count += 5;
          });
          _controller.finishLoad(_count >= 20
              ? IndicatorResult.noMore
              : IndicatorResult.succeeded);
        },
        child: ListView.builder(
          clipBehavior: Clip.none,
          padding: EdgeInsets.zero,
          itemCount: _count,
          itemBuilder: (ctx, index) {
            return const SkeletonItem();
          },
        ),
      ),
    );
  }
}
