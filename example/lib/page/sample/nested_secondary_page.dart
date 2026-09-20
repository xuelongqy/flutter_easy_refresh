import 'dart:math' as math;

import 'package:easy_refresh/easy_refresh.dart';
import 'package:example/widget/skeleton_item.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

/// A secondary Header owns vertical gestures until it has closed. Body lists
/// inherit the nested physics; HeaderLocator is inserted by EasyRefresh.nested.
class NestedSecondaryPage extends StatefulWidget {
  const NestedSecondaryPage({super.key});

  @override
  State<NestedSecondaryPage> createState() => _NestedSecondaryPageState();
}

class _NestedSecondaryPageState extends State<NestedSecondaryPage>
    with SingleTickerProviderStateMixin {
  final _controller = EasyRefreshController();
  final _headerState = IndicatorStateListenable();
  late final TabController _tabs = TabController(length: 2, vsync: this);
  int _refreshCount = 0;

  bool _secondaryVisible(IndicatorMode? mode) =>
      mode == IndicatorMode.secondaryReady ||
      mode == IndicatorMode.secondaryOpen ||
      mode == IndicatorMode.secondaryClosing;

  @override
  void dispose() {
    _tabs.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _refreshCount++);
  }

  Widget _secondary(
    BuildContext context,
    IndicatorState state,
    Indicator header,
    double height,
  ) {
    final colors = Theme.of(context).colorScheme;
    final progress =
        ((state.offset - state.actualTriggerOffset) /
                (state.actualSecondaryTriggerOffset! -
                    state.actualTriggerOffset))
            .clamp(0.0, 1.0);
    return PopScope(
      canPop: !_secondaryVisible(state.mode),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _controller.closeHeaderSecondary();
      },
      child: ClipRect(
        child: Stack(
          children: [
            SizedBox(height: state.offset, width: double.infinity),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: height,
                child: IgnorePointer(
                  ignoring: !_secondaryVisible(state.mode),
                  child: Opacity(
                    opacity: progress,
                    child: ColoredBox(
                      color: colors.primaryContainer,
                      child: SafeArea(
                        child: Stack(
                          children: [
                            Positioned(
                              top: 0,
                              left: 0,
                              child: BackButton(
                                onPressed: _controller.closeHeaderSecondary,
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.layers_rounded,
                                      size: 80,
                                      color: colors.onPrimaryContainer,
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      'Welcome upstairs'.tr,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            color: colors.onPrimaryContainer,
                                          ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Swipe up to close'.tr,
                                      style: TextStyle(
                                        color: colors.onPrimaryContainer,
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    FilledButton.tonalIcon(
                                      key: const Key('nested-secondary-close'),
                                      onPressed:
                                          _controller.closeHeaderSecondary,
                                      icon: const Icon(Icons.arrow_upward),
                                      label: Text('Close second floor'.tr),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Opacity(
              opacity: _secondaryVisible(state.mode) ? 0 : 1 - progress,
              child: header.build(context, state),
            ),
            if (state.mode == IndicatorMode.secondaryArmed)
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(child: Text('Release to open second floor'.tr)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _tab(bool grid) => Builder(
    builder: (context) {
      return CustomScrollView(
        dragStartBehavior: DragStartBehavior.down,
        key: PageStorageKey(
          grid ? 'nested-secondary-grid' : 'nested-secondary-list',
        ),
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          if (grid)
            SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (_, _) => const SkeletonItem(direction: Axis.horizontal),
                childCount: 30,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 6 / 7,
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, _) => const SkeletonItem(),
                childCount: 30,
              ),
            ),
          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.paddingOf(context).bottom),
          ),
        ],
      );
    },
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: LayoutBuilder(
      builder: (context, constraints) {
        final height = math.max(1.0, constraints.maxHeight);
        return EasyRefresh.nested(
          dragStartBehavior: DragStartBehavior.down,
          controller: _controller,
          header: SecondaryBuilderHeader(
            header: ClassicHeader(
              clamping: true,
              processedDuration: const Duration(milliseconds: 200),
              position: IndicatorPosition.locator,
              mainAxisAlignment: MainAxisAlignment.end,
              dragText: 'Pull to refresh'.tr,
              armedText: 'Release ready'.tr,
              readyText: 'Refreshing...'.tr,
              processingText: 'Refreshing...'.tr,
              processedText: 'Succeeded'.tr,
              failedText: 'Failed'.tr,
              noMoreText: 'No more'.tr,
              messageText: 'Last updated at %T'.tr,
            ),
            secondaryTriggerOffset: 120,
            secondaryDimension: height,
            listenable: _headerState,
            builder: (context, state, header) =>
                _secondary(context, state, header, height),
          ),
          onRefresh: _refresh,
          headerSliverBuilder: (context, innerScrolled) => [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                pinned: true,
                expandedHeight: 180,
                forceElevated: innerScrolled,
                title: Text('Nested second floor'.tr),
                flexibleSpace: FlexibleSpaceBar(
                  background: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 64, 24, 56),
                      child: Text('Pull farther to visit the second floor'.tr),
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(76),
                  child: Column(
                    children: [
                      Text(
                        'Refresh count: @count'.trParams({
                          'count': '$_refreshCount',
                        }),
                        key: const Key('nested-secondary-refresh-count'),
                      ),
                      TabBar(
                        controller: _tabs,
                        tabs: [
                          Tab(text: 'List'.tr),
                          Tab(text: 'Grid'.tr),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabs,
            children: [_tab(false), _tab(true)],
          ),
        );
      },
    ),
  );
}
