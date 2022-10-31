import 'dart:async';

import 'package:example/widget/skeleton_item.dart';
import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:get/get.dart';

class NestedScrollViewPage extends StatefulWidget {
  const NestedScrollViewPage({Key? key}) : super(key: key);

  @override
  NestedScrollViewPageState createState() {
    return NestedScrollViewPageState();
  }
}

class NestedScrollViewPageState extends State<NestedScrollViewPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _tabIndex = 0;
  int _listCount = 20;
  int _gridCount = 20;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Scaffold(
      body: ExtendedNestedScrollView(
        onlyOneScrollInBody: true,
        pinnedHeaderSliverHeightBuilder: () {
          return MediaQuery.of(context).padding.top + kToolbarHeight;
        },
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 120,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'NestedScrollView',
                  style: TextStyle(
                      color: Theme.of(context).textTheme.titleLarge?.color),
                ),
                centerTitle: false,
              ),
            ),
          ];
        },
        body: Column(
          children: <Widget>[
            TabBar(
              controller: _tabController,
              labelColor: themeData.colorScheme.primary,
              indicatorColor: themeData.colorScheme.primary,
              onTap: (index) {
                setState(() {
                  _tabIndex = index;
                });
              },
              tabs: const <Widget>[
                Tab(
                  text: 'List',
                ),
                Tab(
                  text: 'Grid',
                ),
              ],
            ),
            Expanded(
              child: IndexedStack(
                index: _tabIndex,
                children: <Widget>[
                  ExtendedVisibilityDetector(
                    uniqueKey: const Key('Tab0'),
                    child: EasyRefresh(
                      header: ClassicHeader(
                        dragText: 'Pull to refresh'.tr,
                        armedText: 'Release ready'.tr,
                        readyText: 'Refreshing...'.tr,
                        processingText: 'Refreshing...'.tr,
                        processedText: 'Succeeded'.tr,
                        noMoreText: 'No more'.tr,
                        failedText: 'Failed'.tr,
                        messageText: 'Last updated at %T'.tr,
                        safeArea: false,
                      ),
                      footer: ClassicFooter(
                        position: IndicatorPosition.locator,
                        dragText: 'Pull to load'.tr,
                        armedText: 'Release ready'.tr,
                        readyText: 'Loading...'.tr,
                        processingText: 'Loading...'.tr,
                        processedText: 'Succeeded'.tr,
                        noMoreText: 'No more'.tr,
                        failedText: 'Failed'.tr,
                        messageText: 'Last updated at %T'.tr,
                      ),
                      child: CustomScrollView(
                        slivers: [
                          SliverList(
                              delegate:
                                  SliverChildBuilderDelegate((context, index) {
                            return const SkeletonItem();
                          }, childCount: _listCount)),
                          const FooterLocator.sliver(),
                        ],
                      ),
                      onRefresh: () async {
                        await Future.delayed(const Duration(seconds: 2), () {
                          if (mounted) {
                            setState(() {
                              _listCount = 20;
                            });
                          }
                        });
                      },
                      onLoad: () async {
                        await Future.delayed(const Duration(seconds: 2), () {
                          if (mounted) {
                            setState(() {
                              _listCount += 10;
                            });
                          }
                        });
                      },
                    ),
                  ),
                  ExtendedVisibilityDetector(
                    uniqueKey: const Key('Tab1'),
                    child: EasyRefresh(
                      header: ClassicHeader(
                        dragText: 'Pull to refresh'.tr,
                        armedText: 'Release ready'.tr,
                        readyText: 'Refreshing...'.tr,
                        processingText: 'Refreshing...'.tr,
                        processedText: 'Succeeded'.tr,
                        noMoreText: 'No more'.tr,
                        failedText: 'Failed'.tr,
                        messageText: 'Last updated at %T'.tr,
                        safeArea: false,
                      ),
                      footer: ClassicFooter(
                        position: IndicatorPosition.locator,
                        dragText: 'Pull to load'.tr,
                        armedText: 'Release ready'.tr,
                        readyText: 'Loading...'.tr,
                        processingText: 'Loading...'.tr,
                        processedText: 'Succeeded'.tr,
                        noMoreText: 'No more'.tr,
                        failedText: 'Failed'.tr,
                        messageText: 'Last updated at %T'.tr,
                      ),
                      child: CustomScrollView(
                        slivers: [
                          SliverGrid(
                              delegate:
                                  SliverChildBuilderDelegate((context, index) {
                                return const SkeletonItem(
                                  direction: Axis.horizontal,
                                );
                              }, childCount: _gridCount),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 6 / 7,
                              )),
                          const FooterLocator.sliver(),
                        ],
                      ),
                      onRefresh: () async {
                        await Future.delayed(const Duration(seconds: 2), () {
                          if (mounted) {
                            setState(() {
                              _gridCount = 30;
                            });
                          }
                        });
                      },
                      onLoad: () async {
                        await Future.delayed(const Duration(seconds: 2), () {
                          if (mounted) {
                            setState(() {
                              _gridCount += 10;
                            });
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
