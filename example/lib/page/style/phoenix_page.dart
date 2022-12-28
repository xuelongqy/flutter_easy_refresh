import 'package:example/config/routes.dart';
import 'package:example/widget/skeleton_item.dart';
import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';

class PhoenixPage extends StatefulWidget {
  const PhoenixPage({Key? key}) : super(key: key);

  @override
  State<PhoenixPage> createState() => _PhoenixPageState();
}

class _PhoenixPageState extends State<PhoenixPage> {
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
        header: PhoenixHeader(
          skyColor: themeData.colorScheme.primary,
          position: IndicatorPosition.locator,
          safeArea: false,
        ),
        footer: PhoenixFooter(
          skyColor: themeData.colorScheme.primary,
          position: IndicatorPosition.locator,
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
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: themeData.colorScheme.primary,
              foregroundColor: themeData.colorScheme.onPrimary,
              leading: BackButton(
                color: themeData.colorScheme.onPrimary,
              ),
              expandedHeight: 120,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text('Golden campus'.tr),
                centerTitle: false,
              ),
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
