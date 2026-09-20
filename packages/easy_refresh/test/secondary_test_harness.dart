import 'dart:async';
import 'dart:math' as math;

import 'package:easy_refresh/easy_refresh.dart';
import 'package:material_ui/material_ui.dart';

// Shared widget harness for the #853 secondary gesture regressions.

enum LayoutKind { legacy, explicit, recipe, plain }

class SecondaryHarness extends StatefulWidget {
  const SecondaryHarness({
    super.key,
    this.layout = LayoutKind.legacy,
    this.clamping = true,
  });
  final LayoutKind layout;
  final bool clamping;
  @override
  SecondaryHarnessState createState() => SecondaryHarnessState();
}

class SecondaryHarnessState extends State<SecondaryHarness> {
  final controller = EasyRefreshController();
  final scroll = ScrollController();
  final listenable = IndicatorStateListenable();
  final modes = <String>[];
  int builds = 0, refreshes = 0;
  Completer<void>? task;
  IndicatorState? get indicator => listenable.value;
  @override
  void initState() {
    super.initState();
    listenable.addListener(record);
  }

  void record() {
    final mode = indicator?.mode.name;
    if (mode != null && (modes.isEmpty || modes.last != mode)) modes.add(mode);
  }

  Future<void> refresh() async {
    refreshes++;
    task = Completer<void>();
    await task!.future;
  }

  void finish() {
    if (!(task?.isCompleted ?? true)) task!.complete();
  }

  @override
  void dispose() {
    listenable.removeListener(record);
    controller.dispose();
    scroll.dispose();
    super.dispose();
  }

  double scale(IndicatorState? state) {
    if (state == null || state.offset <= state.actualTriggerOffset) return 1;
    return math.max(
      0,
      (state.actualSecondaryTriggerOffset! - state.offset) /
          (state.actualSecondaryTriggerOffset! - state.actualTriggerOffset),
    );
  }

  Widget secondary(
    BuildContext context,
    IndicatorState state,
    Indicator header,
    double height,
  ) {
    builds++;
    final mode = state.mode;
    final s = scale(state);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(height: state.offset, width: double.infinity),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Builder(
              builder: (context) {
                final page = Opacity(
                  opacity: 1 - s,
                  child: const Stack(children: [Center(child: Text('测试二楼页面'))]),
                );
                if (mode == IndicatorMode.secondaryOpen ||
                    mode == IndicatorMode.secondaryClosing) {
                  return PopScope(
                    canPop: false,
                    onPopInvokedWithResult: (_, _) =>
                        controller.closeHeaderSecondary(),
                    child: page,
                  );
                }
                return page;
              },
            ),
          ),
        ),
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Center(
            child: AnimatedOpacity(
              opacity: mode == IndicatorMode.secondaryArmed ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Text('打开二楼'),
            ),
          ),
        ),
        Opacity(
          opacity:
              mode == IndicatorMode.secondaryReady ||
                  mode == IndicatorMode.secondaryOpen ||
                  mode == IndicatorMode.secondaryClosing
              ? 0
              : s,
          child: header.build(context, state),
        ),
      ],
    );
  }

  List<Widget> slivers(BuildContext context, bool scrolled) => [
    ValueListenableBuilder<IndicatorState?>(
      valueListenable: listenable,
      builder: (context, state, child) => SliverOpacity(
        opacity: scale(state),
        sliver: const SliverAppBar(pinned: true, title: Text('#853 demo')),
      ),
    ),
    const SliverToBoxAdapter(
      child: SizedBox(height: 160, child: Center(child: Text('主页面区域'))),
    ),
  ];
  Widget body([ScrollPhysics? physics]) => TabBarView(
    children: [
      _KeptTab(
        child: ListView.builder(
          key: const PageStorageKey('first'),
          physics: physics,
          itemCount: 60,
          itemExtent: 50,
          itemBuilder: (_, i) => Text('Item $i'),
        ),
      ),
      _KeptTab(
        child: ListView.builder(
          key: const PageStorageKey('second'),
          physics: physics,
          itemCount: 60,
          itemExtent: 50,
          itemBuilder: (_, i) => Text('Other $i'),
        ),
      ),
    ],
  );
  @override
  Widget build(BuildContext context) => MaterialApp(
    home: DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Builder(
          builder: (context) {
            final height = MediaQuery.sizeOf(context).height;
            final header = SecondaryBuilderHeader(
              header: ClassicHeader(
                mainAxisAlignment: MainAxisAlignment.end,
                position: IndicatorPosition.locator,
                clipBehavior: Clip.none,
                safeArea: true,
                clamping: widget.clamping,
                processedDuration: Duration.zero,
              ),
              secondaryTriggerOffset: 120,
              secondaryDimension: height,
              listenable: listenable,
              builder: (context, state, inner) =>
                  secondary(context, state, inner, height),
            );
            if (widget.layout == LayoutKind.recipe) {
              return EasyRefresh.nested(
                controller: controller,
                scrollController: scroll,
                header: header,
                onRefresh: refresh,
                headerSliverBuilder: slivers,
                body: body(),
              );
            }
            return EasyRefresh.builder(
              isNested: widget.layout == LayoutKind.explicit,
              controller: controller,
              scrollController: scroll,
              header: header,
              onRefresh: refresh,
              childBuilder: (context, physics) {
                if (widget.layout == LayoutKind.plain) {
                  return CustomScrollView(
                    controller: scroll,
                    physics: physics,
                    slivers: [
                      const HeaderLocator.sliver(clearExtent: false),
                      ...slivers(context, false),
                      SliverFixedExtentList(
                        itemExtent: 50,
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => Text('Item $i'),
                          childCount: 60,
                        ),
                      ),
                    ],
                  );
                }
                return NestedScrollView(
                  controller: scroll,
                  physics: physics,
                  headerSliverBuilder: (context, scrolled) => [
                    const HeaderLocator.sliver(clearExtent: false),
                    ...slivers(context, scrolled),
                  ],
                  body: body(physics),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => controller.closeHeaderSecondary(),
          child: const Icon(Icons.close),
        ),
        bottomNavigationBar: const TabBar(
          tabs: [
            Tab(text: '列表一'),
            Tab(text: '列表二'),
          ],
        ),
      ),
    ),
  );
}

class _KeptTab extends StatefulWidget {
  const _KeptTab({required this.child});
  final Widget child;
  @override
  State<_KeptTab> createState() => _KeptTabState();
}

class _KeptTabState extends State<_KeptTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
