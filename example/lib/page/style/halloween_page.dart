import 'package:easy_refresh_halloween/easy_refresh_halloween.dart';
import 'package:example/widget/skeleton_item.dart';
import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';

class HalloweenPage extends StatefulWidget {
  const HalloweenPage({Key? key}) : super(key: key);

  @override
  State<HalloweenPage> createState() => _HalloweenPageState();
}

class _HalloweenPageState extends State<HalloweenPage> {
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
      body: EasyRefresh(
        controller: _controller,
        header: const HalloweenHeader(
          position: IndicatorPosition.locator,
        ),
        footer: const HalloweenFooter(
          position: IndicatorPosition.locator,
        ),
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 4));
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
          await Future.delayed(const Duration(seconds: 4));
          if (!mounted) {
            return;
          }
          setState(() {
            _count += 5;
          });
          _controller.finishLoad(
              _count >= 20 ? IndicatorResult.noMore : IndicatorResult.success);
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text('Halloween horror'.tr),
              pinned: true,
            ),
            const HeaderLocator.sliver(),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return const SkeletonItem();
                },
                childCount: _count,
              ),
            ),
            const FooterLocator.sliver(),
          ],
        ),
      ),
    );
  }
}
