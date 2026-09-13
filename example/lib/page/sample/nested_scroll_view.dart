import 'dart:async';

import 'package:example/widget/skeleton_item.dart';
import 'package:material_ui/material_ui.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:get/get.dart';

/// Per-tab nested Header + Footer.
///
/// Header lives in each tab's inner slivers (below the TabBar). Use a
/// clamping locator Header — inner bouncing pull-to-refresh is not supported.
/// Footer keeps ClassicFooter's infinite load so NestedScrollView can load
/// without entering overscroll.
class NestedScrollViewPage extends StatefulWidget {
  const NestedScrollViewPage({super.key});

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

  ClassicHeader get _tabHeader => ClassicHeader(
    clamping: true,
    position: IndicatorPosition.locator,
    safeArea: false,
    dragText: 'Pull to refresh'.tr,
    armedText: 'Release ready'.tr,
    readyText: 'Refreshing...'.tr,
    processingText: 'Refreshing...'.tr,
    processedText: 'Succeeded'.tr,
    noMoreText: 'No more'.tr,
    failedText: 'Failed'.tr,
    messageText: 'Last updated at %T'.tr,
  );

  ClassicFooter get _tabFooter => ClassicFooter(
    position: IndicatorPosition.locator,
    dragText: 'Pull to load'.tr,
    armedText: 'Release ready'.tr,
    readyText: 'Loading...'.tr,
    processingText: 'Loading...'.tr,
    processedText: 'Succeeded'.tr,
    noMoreText: 'No more'.tr,
    failedText: 'Failed'.tr,
    messageText: 'Last updated at %T'.tr,
  );

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    // Outer EasyRefresh has no onRefresh/onLoad: it only gives
    // NestedScrollView nested-safe physics (Recipe C). Each tab below
    // owns Header/Footer. See README NestedScrollView.
    return Scaffold(
      body: EasyRefresh.builder(
        isNested: true,
        childBuilder: (context, physics) {
          return ScrollConfiguration(
            behavior: const ERScrollBehavior(),
            child: ExtendedNestedScrollView(
              physics: physics,
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
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
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
                      Tab(text: 'List'),
                      Tab(text: 'Grid'),
                    ],
                  ),
                  Expanded(
                    child: IndexedStack(
                      index: _tabIndex,
                      children: <Widget>[
                        ExtendedVisibilityDetector(
                          uniqueKey: const Key('Tab0'),
                          child: EasyRefresh.builder(
                            isNested: true,
                            header: _tabHeader,
                            footer: _tabFooter,
                            onRefresh: () async {
                              await Future.delayed(
                                const Duration(seconds: 2),
                                () {
                                  if (mounted) {
                                    setState(() {
                                      _listCount = 20;
                                    });
                                  }
                                },
                              );
                            },
                            onLoad: () async {
                              await Future.delayed(
                                const Duration(seconds: 2),
                                () {
                                  if (mounted) {
                                    setState(() {
                                      _listCount += 10;
                                    });
                                  }
                                },
                              );
                            },
                            childBuilder: (context, innerPhysics) {
                              return CustomScrollView(
                                physics: innerPhysics,
                                slivers: [
                                  const HeaderLocator.sliver(
                                    clearExtent: false,
                                  ),
                                  SliverList(
                                    delegate: SliverChildBuilderDelegate((
                                      context,
                                      index,
                                    ) {
                                      return const SkeletonItem();
                                    }, childCount: _listCount),
                                  ),
                                  const FooterLocator.sliver(
                                    clearExtent: false,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        ExtendedVisibilityDetector(
                          uniqueKey: const Key('Tab1'),
                          child: EasyRefresh.builder(
                            isNested: true,
                            header: _tabHeader,
                            footer: _tabFooter,
                            onRefresh: () async {
                              await Future.delayed(
                                const Duration(seconds: 2),
                                () {
                                  if (mounted) {
                                    setState(() {
                                      _gridCount = 30;
                                    });
                                  }
                                },
                              );
                            },
                            onLoad: () async {
                              await Future.delayed(
                                const Duration(seconds: 2),
                                () {
                                  if (mounted) {
                                    setState(() {
                                      _gridCount += 10;
                                    });
                                  }
                                },
                              );
                            },
                            childBuilder: (context, innerPhysics) {
                              return CustomScrollView(
                                physics: innerPhysics,
                                slivers: [
                                  const HeaderLocator.sliver(
                                    clearExtent: false,
                                  ),
                                  SliverGrid(
                                    delegate: SliverChildBuilderDelegate((
                                      context,
                                      index,
                                    ) {
                                      return const SkeletonItem(
                                        direction: Axis.horizontal,
                                      );
                                    }, childCount: _gridCount),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 6 / 7,
                                        ),
                                  ),
                                  const FooterLocator.sliver(
                                    clearExtent: false,
                                  ),
                                ],
                              );
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
        },
      ),
    );
  }
}
