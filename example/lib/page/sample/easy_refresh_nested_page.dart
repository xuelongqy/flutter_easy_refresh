import 'dart:async';

import 'package:example/widget/skeleton_item.dart';
import 'package:material_ui/material_ui.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';

/// Recipe A with Flutter's NestedScrollView via [EasyRefresh.nested].
///
/// HeaderLocator is inserted automatically. Body lists inherit nested physics
/// from this widget's ScrollConfiguration — do not pass [ScrollPhysics] on
/// them. Do not wrap ExtendedNestedScrollView with this constructor.
class EasyRefreshNestedPage extends StatefulWidget {
  const EasyRefreshNestedPage({super.key});

  @override
  State<EasyRefreshNestedPage> createState() => EasyRefreshNestedPageState();
}

class EasyRefreshNestedPageState extends State<EasyRefreshNestedPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _listCount = 20;
  int _gridCount = 20;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Scaffold(
      body: EasyRefresh.nested(
        header: ClassicHeader(
          clamping: true,
          position: IndicatorPosition.locator,
          mainAxisAlignment: MainAxisAlignment.end,
          dragText: 'Pull to refresh'.tr,
          armedText: 'Release ready'.tr,
          readyText: 'Refreshing...'.tr,
          processingText: 'Refreshing...'.tr,
          processedText: 'Succeeded'.tr,
          noMoreText: 'No more'.tr,
          failedText: 'Failed'.tr,
          messageText: 'Last updated at %T'.tr,
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
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 2));
          if (!mounted) {
            return;
          }
          if (_tabController.index == 0) {
            if (_listCount != 20) {
              setState(() {
                _listCount = 20;
              });
            }
          } else if (_gridCount != 20) {
            setState(() {
              _gridCount = 20;
            });
          }
        },
        onLoad: () async {
          await Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                if (_tabController.index == 0) {
                  _listCount += 10;
                } else {
                  _gridCount += 10;
                }
              });
            }
          });
        },
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          // Official NestedScrollView slides its body under a pinned AppBar.
          // TabBar must live on SliverAppBar.bottom (with overlap absorber /
          // injector), not in a body Column — otherwise it folds away.
          return [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                forceElevated: innerBoxIsScrolled,
                title: Text(
                  'EasyRefresh.nested',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  labelColor: themeData.colorScheme.primary,
                  indicatorColor: themeData.colorScheme.primary,
                  tabs: const [
                    Tab(text: 'List'),
                    Tab(text: 'Grid'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _KeepAliveTab(
              child: Builder(
                builder: (context) {
                  return CustomScrollView(
                    slivers: [
                      SliverOverlapInjector(
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                          context,
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return const SkeletonItem();
                        }, childCount: _listCount),
                      ),
                      const FooterLocator.sliver(clearExtent: false),
                    ],
                  );
                },
              ),
            ),
            _KeepAliveTab(
              child: Builder(
                builder: (context) {
                  return CustomScrollView(
                    slivers: [
                      SliverOverlapInjector(
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                          context,
                        ),
                      ),
                      SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return const SkeletonItem(direction: Axis.horizontal);
                        }, childCount: _gridCount),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 6 / 7,
                            ),
                      ),
                      const FooterLocator.sliver(clearExtent: false),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KeepAliveTab extends StatefulWidget {
  const _KeepAliveTab({required this.child});

  final Widget child;

  @override
  State<_KeepAliveTab> createState() => _KeepAliveTabState();
}

class _KeepAliveTabState extends State<_KeepAliveTab>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
