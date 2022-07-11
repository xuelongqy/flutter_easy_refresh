import 'package:easy_refresh/easy_refresh.dart';
import 'package:example/widget/skeleton_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoIndicatorPage extends StatefulWidget {
  const CupertinoIndicatorPage({Key? key}) : super(key: key);

  @override
  State<CupertinoIndicatorPage> createState() => _CupertinoIndicatorPageState();
}

class _CupertinoIndicatorPageState extends State<CupertinoIndicatorPage> {
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
    return Material(
      color: Colors.transparent,
      child: CupertinoPageScaffold(
        child: EasyRefresh(
          controller: _controller,
          header: const CupertinoHeader(
            position: IndicatorPosition.locator,
            safeArea: false,
          ),
          footer: const CupertinoFooter(
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
            _controller.finishLoad(_count >= 20
                ? IndicatorResult.noMore
                : IndicatorResult.success);
          },
          child: CustomScrollView(
            slivers: [
              const CupertinoSliverNavigationBar(
                largeTitle: Text('iOS Cupertino'),
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
      ),
    );
  }
}
