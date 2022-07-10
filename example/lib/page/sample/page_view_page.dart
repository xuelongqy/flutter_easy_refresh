import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';

class PageViewPage extends StatefulWidget {
  const PageViewPage({Key? key}) : super(key: key);

  @override
  State<PageViewPage> createState() => _PageViewPageState();
}

class _PageViewPageState extends State<PageViewPage> {
  int _count = 5;
  late final PageController _pageController;
  late EasyRefreshController _controller;
  Axis _scrollDirection = Axis.horizontal;

  @override
  void initState() {
    _pageController = PageController();
    _controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PageView'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _scrollDirection = _scrollDirection == Axis.horizontal
                    ? Axis.vertical
                    : Axis.horizontal;
              });
            },
            icon: Icon(_scrollDirection == Axis.horizontal
                ? Icons.horizontal_distribute
                : Icons.vertical_distribute),
          ),
        ],
      ),
      body: EasyRefresh(
        header: ClassicHeader(
          dragText: 'Pull to refresh'.tr,
          armedText: 'Release ready'.tr,
          readyText: 'Refreshing...'.tr,
          processingText: 'Refreshing...'.tr,
          processedText: 'Succeeded'.tr,
          noMoreText: 'No more'.tr,
          failedText: 'Failed'.tr,
          messageText: 'Last updated at %T'.tr,
          mainAxisAlignment: MainAxisAlignment.end,
        ),
        footer: ClassicFooter(
          dragText: 'Pull to load'.tr,
          armedText: 'Release ready'.tr,
          readyText: 'Loading...'.tr,
          processingText: 'Loading...'.tr,
          processedText: 'Succeeded'.tr,
          noMoreText: 'No more'.tr,
          failedText: 'Failed'.tr,
          messageText: 'Last updated at %T'.tr,
          infiniteOffset: null,
        ),
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 2));
          if (!mounted) {
            return;
          }
          setState(() {
            _count = 5;
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
        child: PageView.builder(
          controller: _pageController,
          scrollDirection: _scrollDirection,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.all(16),
              child: Center(
                child: Text('${index + 1}'),
              ),
            );
          },
          itemCount: _count,
        ),
      ),
    );
  }
}
