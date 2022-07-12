import 'package:example/config/routes.dart';
import 'package:example/widget/skeleton_item.dart';
import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';

class DeliveryPage extends StatefulWidget {
  const DeliveryPage({Key? key}) : super(key: key);

  @override
  State<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
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
      body: EasyRefresh(
        controller: _controller,
        header: const DeliveryHeader(
          position: IndicatorPosition.locator,
        ),
        footer: const DeliveryFooter(
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
              backgroundColor: themeData.scaffoldBackgroundColor,
              title: Text('Balloon delivery'.tr),
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
      floatingActionButton: FloatingActionButton.extended(
        label: Text('Theme'.tr),
        icon: const Icon(Icons.color_lens),
        onPressed: () => Get.toNamed(Routes.theme),
      ),
    );
  }
}
