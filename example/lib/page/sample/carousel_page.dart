import 'package:carousel_slider/carousel_slider.dart';
import 'package:example/widget/skeleton_item.dart';
import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';

class CarouselPage extends StatefulWidget {
  const CarouselPage({Key? key}) : super(key: key);

  @override
  State<CarouselPage> createState() => _CarouselPageState();
}

class _CarouselPageState extends State<CarouselPage> {
  int _count = 10;
  int _carouselCount = 5;
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
        title: Text('Carousel example'.tr),
      ),
      body: EasyRefresh(
        controller: _controller,
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
            SliverToBoxAdapter(
              child: EasyRefresh(
                header: MaterialHeader(),
                footer: MaterialFooter(),
                onRefresh: () async {
                  await Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      setState(() {
                        _carouselCount = 5;
                      });
                    }
                  });
                },
                onLoad: () async {
                  await Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      setState(() {
                        _carouselCount += 5;
                      });
                    }
                  });
                },
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 180.0,
                    viewportFraction: 1,
                    enableInfiniteScroll: false,
                    autoPlay: true,
                  ),
                  items: [
                    for (int i = 0; i < _carouselCount; i++)
                      Card(
                        elevation: 0,
                        color: themeData.colorScheme.surfaceVariant,
                        child: Center(
                          child: Text((i + 1).toString()),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return const SkeletonItem();
                },
                childCount: _count,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
