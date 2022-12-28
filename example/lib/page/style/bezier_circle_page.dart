import 'package:example/config/routes.dart';
import 'package:example/widget/skeleton_item.dart';
import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
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
    final themeData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeData.colorScheme.primary,
        foregroundColor: themeData.colorScheme.onPrimary,
        leading: BackButton(
          color: themeData.colorScheme.onPrimary,
        ),
        title: Text('Bezier circle'.tr),
      ),
      body: EasyRefresh(
        controller: _controller,
        header: BezierCircleHeader(
          foregroundColor: themeData.scaffoldBackgroundColor,
          backgroundColor: themeData.colorScheme.primary,
        ),
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 2));
          if (!mounted) {
            return;
          }
          setState(() {
            _count = 10;
          });
          _controller.finishRefresh();
          _controller.resetFooter();
        },
        onLoad: () async {
          await Future.delayed(const Duration(seconds: 2));
          if (!mounted) {
            return;
          }
          setState(() {
            _count += 5;
          });
          _controller.finishLoad(
              _count >= 20 ? IndicatorResult.noMore : IndicatorResult.success);
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
      floatingActionButton: FloatingActionButton.extended(
        label: Text('Theme'.tr),
        icon: const Icon(Icons.color_lens),
        onPressed: () => Get.toNamed(Routes.theme),
      ),
    );
  }
}
