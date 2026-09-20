import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

/// Official NestedScrollView recipe: EasyRefresh.nested.
class _NestedRecipeHarness extends StatefulWidget {
  const _NestedRecipeHarness({super.key, this.infiniteFooter = false});

  final bool infiniteFooter;

  @override
  State<_NestedRecipeHarness> createState() => _NestedRecipeHarnessState();
}

class _NestedRecipeHarnessState extends State<_NestedRecipeHarness> {
  late final EasyRefreshController controller;
  final headerListenable = IndicatorStateListenable();
  final footerListenable = IndicatorStateListenable();

  int itemCount = 40;
  bool refreshCalled = false;
  bool loadCalled = false;

  Completer<void>? _refreshCompleter;
  Completer<void>? _loadCompleter;

  IndicatorState? get headerState => headerListenable.value;
  IndicatorState? get footerState => footerListenable.value;

  void finishRefresh() {
    _refreshCompleter?.complete();
  }

  void finishLoad() {
    _loadCompleter?.complete();
  }

  Future<void> _onRefresh() async {
    refreshCalled = true;
    _refreshCompleter = Completer<void>();
    await _refreshCompleter!.future;
  }

  Future<void> _onLoad() async {
    loadCalled = true;
    _loadCompleter = Completer<void>();
    await _loadCompleter!.future;
    setState(() {
      itemCount += 10;
    });
  }

  @override
  void initState() {
    super.initState();
    controller = EasyRefreshController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: EasyRefresh.nested(
          controller: controller,
          header: BuilderHeader(
            listenable: headerListenable,
            triggerOffset: 70,
            clamping: true,
            position: IndicatorPosition.locator,
            processedDuration: Duration.zero,
            builder: (context, state) => Container(
              height: state.offset,
              width: double.infinity,
              color: Colors.blue.withAlpha(77),
              alignment: Alignment.center,
              child: Text(
                'Header: ${state.mode.name}',
                key: const Key('header-text'),
              ),
            ),
          ),
          footer: BuilderFooter(
            listenable: footerListenable,
            triggerOffset: 70,
            clamping: !widget.infiniteFooter,
            infiniteOffset: widget.infiniteFooter ? 70 : null,
            position: IndicatorPosition.locator,
            processedDuration: Duration.zero,
            builder: (context, state) => Container(
              height:
                  widget.infiniteFooter && state.mode != IndicatorMode.inactive
                  ? 70
                  : state.offset,
              width: double.infinity,
              alignment: Alignment.center,
              child: Text(
                'Footer: ${state.mode.name}',
                key: const Key('footer-text'),
              ),
            ),
          ),
          onRefresh: _onRefresh,
          onLoad: _onLoad,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              const SliverAppBar(
                title: Text('Nested Scroll'),
                expandedHeight: 200,
                pinned: true,
              ),
            ];
          },
          body: CustomScrollView(
            slivers: [
              SliverFixedExtentList(
                itemExtent: 50,
                delegate: SliverChildBuilderDelegate(
                  (context, index) => ListTile(
                    key: Key('item-$index'),
                    title: Text('Item $index'),
                  ),
                  childCount: itemCount,
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

/// Official NestedScrollView + TabBarView (EasyRefresh.nested sample layout).
class _NestedOfficialTabHarness extends StatefulWidget {
  const _NestedOfficialTabHarness({super.key});

  @override
  State<_NestedOfficialTabHarness> createState() =>
      _NestedOfficialTabHarnessState();
}

class _NestedOfficialTabHarnessState extends State<_NestedOfficialTabHarness>
    with SingleTickerProviderStateMixin {
  late final TabController tabController;
  late final EasyRefreshController controller;
  final headerListenable = IndicatorStateListenable();

  bool refreshCalled = false;
  Completer<void>? _refreshCompleter;

  IndicatorState? get headerState => headerListenable.value;

  void finishRefresh() => _refreshCompleter?.complete();

  Future<void> _onRefresh() async {
    refreshCalled = true;
    _refreshCompleter = Completer<void>();
    await _refreshCompleter!.future;
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    controller = EasyRefreshController();
  }

  @override
  void dispose() {
    tabController.dispose();
    controller.dispose();
    super.dispose();
  }

  Widget _tabList({required String prefix, required int itemCount}) {
    return Builder(
      builder: (context) {
        return CustomScrollView(
          slivers: [
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            SliverFixedExtentList(
              itemExtent: 50,
              delegate: SliverChildBuilderDelegate(
                (context, index) => ListTile(
                  key: Key('$prefix-item-$index'),
                  title: Text('$prefix $index'),
                ),
                childCount: itemCount,
              ),
            ),
            const FooterLocator.sliver(clearExtent: false),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: EasyRefresh.nested(
          controller: controller,
          header: BuilderHeader(
            listenable: headerListenable,
            triggerOffset: 70,
            clamping: true,
            position: IndicatorPosition.locator,
            processedDuration: Duration.zero,
            builder: (context, state) => SizedBox(height: state.offset),
          ),
          footer: ClassicFooter(
            position: IndicatorPosition.locator,
            processedDuration: Duration.zero,
          ),
          onRefresh: _onRefresh,
          onLoad: () async {},
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                  context,
                ),
                sliver: SliverAppBar(
                  title: const Text('Official nested'),
                  expandedHeight: 200,
                  pinned: true,
                  forceElevated: innerBoxIsScrolled,
                  bottom: TabBar(
                    controller: tabController,
                    tabs: const [
                      Tab(text: 'Tab 0'),
                      Tab(text: 'Tab 1'),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: tabController,
            children: [
              _tabList(prefix: 'official0', itemCount: 20),
              _tabList(prefix: 'official1', itemCount: 12),
            ],
          ),
        ),
      ),
    );
  }
}

/// Inner clamping Header locator (below AppBar) + infinite Footer.
class _NestedInnerHeaderHarness extends StatefulWidget {
  const _NestedInnerHeaderHarness({super.key});

  @override
  State<_NestedInnerHeaderHarness> createState() =>
      _NestedInnerHeaderHarnessState();
}

class _NestedInnerHeaderHarnessState extends State<_NestedInnerHeaderHarness> {
  final headerListenable = IndicatorStateListenable();
  final footerListenable = IndicatorStateListenable();

  int itemCount = 40;
  bool refreshCalled = false;
  bool loadCalled = false;
  Completer<void>? _refreshCompleter;
  Completer<void>? _loadCompleter;

  IndicatorState? get headerState => headerListenable.value;
  IndicatorState? get footerState => footerListenable.value;

  void finishRefresh() => _refreshCompleter?.complete();
  void finishLoad() => _loadCompleter?.complete();

  Future<void> _onRefresh() async {
    refreshCalled = true;
    _refreshCompleter = Completer<void>();
    await _refreshCompleter!.future;
  }

  Future<void> _onLoad() async {
    loadCalled = true;
    _loadCompleter = Completer<void>();
    await _loadCompleter!.future;
    setState(() {
      itemCount += 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: EasyRefresh.builder(
          isNested: true,
          childBuilder: (context, physics) {
            return NestedScrollView(
              physics: physics,
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return const [
                  SliverAppBar(
                    title: Text('Inner header'),
                    expandedHeight: 120,
                    pinned: true,
                  ),
                ];
              },
              body: EasyRefresh.builder(
                isNested: true,
                header: BuilderHeader(
                  listenable: headerListenable,
                  triggerOffset: 70,
                  clamping: true,
                  position: IndicatorPosition.locator,
                  processedDuration: Duration.zero,
                  builder: (context, state) => Container(
                    height: state.offset,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text(
                      'InnerHeader: ${state.mode.name}',
                      key: const Key('inner-header-text'),
                    ),
                  ),
                ),
                footer: BuilderFooter(
                  listenable: footerListenable,
                  triggerOffset: 70,
                  clamping: false,
                  infiniteOffset: 70,
                  position: IndicatorPosition.locator,
                  processedDuration: Duration.zero,
                  builder: (context, state) => Container(
                    height:
                        state.mode != IndicatorMode.inactive ||
                            state.result == IndicatorResult.noMore
                        ? 70
                        : state.offset,
                    alignment: Alignment.center,
                    child: Text(
                      'InnerFooter: ${state.mode.name}',
                      key: const Key('inner-footer-text'),
                    ),
                  ),
                ),
                onRefresh: _onRefresh,
                onLoad: _onLoad,
                childBuilder: (context, innerPhysics) {
                  return CustomScrollView(
                    physics: innerPhysics,
                    slivers: [
                      const HeaderLocator.sliver(clearExtent: false),
                      SliverFixedExtentList(
                        itemExtent: 50,
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => ListTile(
                            key: Key('inner-item-$index'),
                            title: Text('Item $index'),
                          ),
                          childCount: itemCount,
                        ),
                      ),
                      const FooterLocator.sliver(clearExtent: false),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Page-level nested Header + independent Footer EasyRefresh per tab.
class _NestedTabLoadHarness extends StatefulWidget {
  const _NestedTabLoadHarness({super.key});

  @override
  State<_NestedTabLoadHarness> createState() => _NestedTabLoadHarnessState();
}

class _NestedTabLoadHarnessState extends State<_NestedTabLoadHarness>
    with SingleTickerProviderStateMixin {
  late final TabController tabController;
  late final EasyRefreshController tab0Controller;
  late final EasyRefreshController tab1Controller;
  bool pageRefreshCalled = false;
  bool tab0LoadCalled = false;
  bool tab1LoadCalled = false;
  IndicatorResult? tab0LoadResult;
  IndicatorResult? tab1LoadResult;

  Completer<void>? _pageRefreshCompleter;
  Completer<IndicatorResult>? _tab0LoadCompleter;
  Completer<IndicatorResult>? _tab1LoadCompleter;

  void finishPageRefresh() {
    _pageRefreshCompleter?.complete();
  }

  void finishTab0Load([IndicatorResult result = IndicatorResult.success]) {
    _tab0LoadCompleter?.complete(result);
  }

  void finishTab1Load([IndicatorResult result = IndicatorResult.success]) {
    _tab1LoadCompleter?.complete(result);
  }

  Future<void> _onPageRefresh() async {
    pageRefreshCalled = true;
    _pageRefreshCompleter = Completer<void>();
    await _pageRefreshCompleter!.future;
  }

  Future<IndicatorResult> _onTab0Load() async {
    tab0LoadCalled = true;
    _tab0LoadCompleter = Completer<IndicatorResult>();
    final result = await _tab0LoadCompleter!.future;
    tab0LoadResult = result;
    return result;
  }

  Future<IndicatorResult> _onTab1Load() async {
    tab1LoadCalled = true;
    _tab1LoadCompleter = Completer<IndicatorResult>();
    final result = await _tab1LoadCompleter!.future;
    tab1LoadResult = result;
    return result;
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tab0Controller = EasyRefreshController();
    tab1Controller = EasyRefreshController();
  }

  @override
  void dispose() {
    tabController.dispose();
    tab0Controller.dispose();
    tab1Controller.dispose();
    super.dispose();
  }

  Widget _tabList({
    required String prefix,
    required EasyRefreshController controller,
    required Future<IndicatorResult> Function() onLoad,
  }) {
    return EasyRefresh.builder(
      controller: controller,
      header: const NotRefreshHeader(),
      footer: BuilderFooter(
        triggerOffset: 70,
        clamping: true,
        infiniteOffset: null,
        processedDuration: Duration.zero,
        builder: (context, state) => SizedBox(
          height: state.offset,
          child: Text('$prefix-footer:${state.mode.name}'),
        ),
      ),
      onLoad: onLoad,
      childBuilder: (context, physics) {
        return ListView.builder(
          physics: physics,
          itemExtent: 50,
          itemCount: 40,
          itemBuilder: (context, index) => ListTile(
            key: Key('$prefix-item-$index'),
            title: Text('$prefix $index'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: EasyRefresh.nested(
          header: BuilderHeader(
            triggerOffset: 70,
            clamping: true,
            position: IndicatorPosition.locator,
            processedDuration: Duration.zero,
            builder: (context, state) => SizedBox(
              height: state.offset,
              child: Text(
                'Header: ${state.mode.name}',
                key: const Key('page-header'),
              ),
            ),
          ),
          onRefresh: _onPageRefresh,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                title: const Text('Nested tabs'),
                expandedHeight: 120,
                pinned: true,
                bottom: TabBar(
                  controller: tabController,
                  tabs: const [
                    Tab(text: 'Tab 0'),
                    Tab(text: 'Tab 1'),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: tabController,
            children: [
              _tabList(
                prefix: 'tab0',
                controller: tab0Controller,
                onLoad: _onTab0Load,
              ),
              _tabList(
                prefix: 'tab1',
                controller: tab1Controller,
                onLoad: _onTab1Load,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Recipe A: one nested EasyRefresh, shared onLoad, TabBarView inners.
class _NestedSharedTabHarness extends StatefulWidget {
  const _NestedSharedTabHarness({super.key});

  @override
  State<_NestedSharedTabHarness> createState() =>
      _NestedSharedTabHarnessState();
}

class _NestedSharedTabHarnessState extends State<_NestedSharedTabHarness>
    with SingleTickerProviderStateMixin {
  late final TabController tabController;
  late final EasyRefreshController controller;
  final footerListenable = IndicatorStateListenable();

  bool loadCalled = false;
  Completer<void>? _loadCompleter;

  IndicatorState? get footerState => footerListenable.value;

  void finishLoad() => _loadCompleter?.complete();

  Future<void> _onLoad() async {
    loadCalled = true;
    _loadCompleter = Completer<void>();
    await _loadCompleter!.future;
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    controller = EasyRefreshController();
  }

  @override
  void dispose() {
    tabController.dispose();
    controller.dispose();
    super.dispose();
  }

  Widget _tabList({required String prefix, required int itemCount}) {
    return CustomScrollView(
      slivers: [
        SliverFixedExtentList(
          itemExtent: 50,
          delegate: SliverChildBuilderDelegate(
            (context, index) => ListTile(
              key: Key('$prefix-item-$index'),
              title: Text('$prefix $index'),
            ),
            childCount: itemCount,
          ),
        ),
        const FooterLocator.sliver(clearExtent: false),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: EasyRefresh.nested(
          controller: controller,
          header: BuilderHeader(
            triggerOffset: 70,
            clamping: true,
            position: IndicatorPosition.locator,
            processedDuration: Duration.zero,
            builder: (context, state) => SizedBox(height: state.offset),
          ),
          footer: BuilderFooter(
            listenable: footerListenable,
            triggerOffset: 70,
            clamping: true,
            infiniteOffset: null,
            position: IndicatorPosition.locator,
            processedDuration: Duration.zero,
            builder: (context, state) => SizedBox(
              height: state.offset,
              child: Text('Footer: ${state.mode.name}'),
            ),
          ),
          onRefresh: () async {},
          onLoad: _onLoad,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                title: const Text('Shared tabs'),
                expandedHeight: 80,
                pinned: true,
                bottom: TabBar(
                  controller: tabController,
                  tabs: const [
                    Tab(text: 'Tab 0'),
                    Tab(text: 'Tab 1'),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: tabController,
            children: [
              _tabList(prefix: 'shared0', itemCount: 12),
              _tabList(prefix: 'shared1', itemCount: 40),
            ],
          ),
        ),
      ),
    );
  }
}

/// Test harness for EasyRefresh.builder with childBuilder pattern
class _BuilderPatternHarness extends StatefulWidget {
  const _BuilderPatternHarness({super.key});

  @override
  State<_BuilderPatternHarness> createState() => _BuilderPatternHarnessState();
}

class _BuilderPatternHarnessState extends State<_BuilderPatternHarness> {
  late final EasyRefreshController controller;
  final headerListenable = IndicatorStateListenable();

  int itemCount = 20;
  bool refreshCalled = false;

  Completer<void>? _refreshCompleter;

  IndicatorState? get headerState => headerListenable.value;

  void finishRefresh() {
    _refreshCompleter?.complete();
  }

  Future<void> _onRefresh() async {
    refreshCalled = true;
    _refreshCompleter = Completer<void>();
    await _refreshCompleter!.future;
  }

  @override
  void initState() {
    super.initState();
    controller = EasyRefreshController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: EasyRefresh.builder(
          controller: controller,
          header: BuilderHeader(
            listenable: headerListenable,
            triggerOffset: 70,
            clamping: false,
            position: IndicatorPosition.above,
            processedDuration: Duration.zero,
            builder: (context, state) => Container(
              height: state.offset,
              width: double.infinity,
              color: Colors.blue.withAlpha(77),
              alignment: Alignment.center,
              child: Text(
                'Header: ${state.mode.name}',
                key: const Key('header-text'),
              ),
            ),
          ),
          onRefresh: _onRefresh,
          childBuilder: (context, physics) {
            return CustomScrollView(
              physics: physics,
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ListTile(
                      key: Key('item-$index'),
                      title: Text('Item $index'),
                    ),
                    childCount: itemCount,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Test harness for TabBarView integration
class _TabBarViewHarness extends StatefulWidget {
  const _TabBarViewHarness({super.key});

  @override
  State<_TabBarViewHarness> createState() => _TabBarViewHarnessState();
}

class _TabBarViewHarnessState extends State<_TabBarViewHarness>
    with SingleTickerProviderStateMixin {
  late final TabController tabController;
  late final EasyRefreshController refreshController;
  final scrollController = ScrollController();

  int itemCount = 20;
  bool refreshCalled = false;

  Completer<void>? _refreshCompleter;

  void finishRefresh() {
    _refreshCompleter?.complete();
  }

  Future<void> _onRefresh() async {
    refreshCalled = true;
    _refreshCompleter = Completer<void>();
    await _refreshCompleter!.future;
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    refreshController = EasyRefreshController();
  }

  @override
  void dispose() {
    tabController.dispose();
    refreshController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Tab Bar View'),
          bottom: TabBar(
            controller: tabController,
            tabs: const [
              Tab(text: 'Tab 1'),
              Tab(text: 'Tab 2'),
              Tab(text: 'Tab 3'),
            ],
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            EasyRefresh(
              controller: refreshController,
              scrollController: scrollController,
              header: const ClassicHeader(),
              onRefresh: _onRefresh,
              child: ListView.builder(
                controller: scrollController,
                itemCount: itemCount,
                itemBuilder: (context, index) => ListTile(
                  key: Key('tab1-item-$index'),
                  title: Text('Tab 1 - Item $index'),
                ),
              ),
            ),
            const Center(child: Text('Tab 2 Content')),
            const Center(child: Text('Tab 3 Content')),
          ],
        ),
      ),
    );
  }
}

/// Recipe B inner EasyRefresh (isNested: false) inside NestedScrollView.
class _AdoptedNestedFlagHarness extends StatefulWidget {
  const _AdoptedNestedFlagHarness({super.key});

  @override
  State<_AdoptedNestedFlagHarness> createState() =>
      _AdoptedNestedFlagHarnessState();
}

class _AdoptedNestedFlagHarnessState extends State<_AdoptedNestedFlagHarness> {
  int rebuilds = 0;
  bool? innerHeaderNested;
  bool? innerFooterNested;
  ScrollPhysics? innerPhysics;

  void bump() => setState(() => rebuilds++);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: EasyRefresh.nested(
          header: const ClassicHeader(
            clamping: true,
            position: IndicatorPosition.locator,
          ),
          onRefresh: () async {},
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return const [
              SliverAppBar(title: Text('Adopt flag'), pinned: true),
            ];
          },
          body: EasyRefresh.builder(
            header: const NotRefreshHeader(),
            onLoad: () async {},
            childBuilder: (context, physics) {
              innerPhysics = physics;
              return ListView(
                physics: physics,
                children: [
                  Builder(
                    builder: (context) {
                      final data = EasyRefresh.of(context);
                      innerHeaderNested = data.headerNotifier.isNested;
                      innerFooterNested = data.footerNotifier.isNested;
                      return ListTile(
                        key: const Key('adopt-item-0'),
                        title: Text('rebuilds $rebuilds'),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

Future<void> disposeAndFlush(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

Future<void> waitUntil(bool Function() condition, WidgetTester tester) async {
  for (var i = 0; i < 50 && !condition(); i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  group('NestedScrollView Integration Tests', () {
    testWidgets('EasyRefresh.nested renders NestedScrollView', (tester) async {
      await tester.pumpWidget(const _NestedRecipeHarness());
      await tester.pumpAndSettle();

      expect(find.byType(EasyRefresh), findsOneWidget);
      expect(find.byType(NestedScrollView), findsOneWidget);

      await disposeAndFlush(tester);
    });

    testWidgets('EasyRefresh.nested TabBarView sample layout refreshes', (
      tester,
    ) async {
      final key = GlobalKey<_NestedOfficialTabHarnessState>();
      await tester.pumpWidget(_NestedOfficialTabHarness(key: key));
      final state = key.currentState!;
      await tester.pumpAndSettle();

      expect(find.byType(NestedScrollView), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);
      expect(find.byKey(const Key('official0-item-0')), findsOneWidget);

      await tester.drag(
        find.byKey(const Key('official0-item-0')),
        const Offset(0, -400),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TabBar), findsOneWidget);
      expect(find.text('Tab 0'), findsOneWidget);

      final titleRect = tester.getRect(find.text('Official nested'));
      final tabBarRect = tester.getRect(find.byType(TabBar));
      expect(
        tabBarRect.overlaps(titleRect),
        isFalse,
        reason: 'TabBar must stay below the pinned AppBar, not slide under it',
      );
      expect(tabBarRect.top, greaterThanOrEqualTo(titleRect.bottom - 1));
      expect(tabBarRect.height, greaterThan(32));

      final nested = tester.state<NestedScrollViewState>(
        find.byType(NestedScrollView),
      );
      nested.outerController.jumpTo(0);
      for (final position in nested.innerController.positions) {
        position.jumpTo(0);
      }
      await tester.pump();

      await tester.drag(find.byType(NestedScrollView), const Offset(0, 280));
      await tester.pump();
      await waitUntil(() => state.refreshCalled, tester);

      expect(state.refreshCalled, isTrue);
      expect(state.headerState?.mode, IndicatorMode.processing);

      state.finishRefresh();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      state.tabController.animateTo(1);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('official1-item-0')), findsOneWidget);

      await disposeAndFlush(tester);
    });

    testWidgets('pull at expanded AppBar triggers refresh', (tester) async {
      final key = GlobalKey<_NestedRecipeHarnessState>();
      await tester.pumpWidget(_NestedRecipeHarness(key: key));
      final state = key.currentState!;
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('item-0'))),
      );
      await gesture.moveBy(const Offset(0, 280));
      await tester.pump();
      await gesture.up();
      await tester.pump();
      await waitUntil(() => state.refreshCalled, tester);

      expect(state.refreshCalled, isTrue);
      expect(state.headerState?.mode, IndicatorMode.processing);

      state.finishRefresh();
      await tester.pump();
      await waitUntil(() => (state.headerState?.offset ?? 0) < 1, tester);

      expect(state.headerState?.offset ?? 0, lessThan(1));
      expect(
        state.headerState?.mode,
        anyOf(IndicatorMode.inactive, IndicatorMode.done),
      );

      await disposeAndFlush(tester);
    });

    testWidgets(
      'refresh complete while AppBar collapsed does not jump AppBar',
      (tester) async {
        final key = GlobalKey<_NestedRecipeHarnessState>();
        await tester.pumpWidget(_NestedRecipeHarness(key: key));
        final state = key.currentState!;
        await tester.pumpAndSettle();

        final nested = tester.state<NestedScrollViewState>(
          find.byType(NestedScrollView),
        );
        final gesture = await tester.startGesture(
          tester.getCenter(find.byKey(const Key('item-0'))),
        );
        await gesture.moveBy(const Offset(0, 280));
        await tester.pump();
        await gesture.up();
        await tester.pump();
        await waitUntil(() => state.refreshCalled, tester);
        expect(state.headerState?.mode, IndicatorMode.processing);

        await tester.drag(find.byType(NestedScrollView), const Offset(0, -400));
        await tester.pump();

        final headerOffset = state.headerState!.offset;
        expect(headerOffset, greaterThan(50));
        expect(nested.outerController.position.pixels, greaterThan(50));

        final appBarTop = tester.getTopLeft(find.text('Nested Scroll')).dy;
        final outerBefore = nested.outerController.position.pixels;
        final appBarYs = <double>[appBarTop];

        state.finishRefresh();
        for (var i = 0; i < 24; i++) {
          await tester.pump(const Duration(milliseconds: 16));
          appBarYs.add(tester.getTopLeft(find.text('Nested Scroll')).dy);
          if ((state.headerState?.offset ?? 0) < 1 && i > 1) {
            break;
          }
        }

        expect(state.headerState?.offset ?? 0, lessThan(1));
        expect(
          nested.outerController.position.pixels,
          closeTo(outerBefore - headerOffset, 20),
        );
        final appBarMin = appBarYs.reduce((a, b) => a < b ? a : b);
        final appBarMax = appBarYs.reduce((a, b) => a > b ? a : b);
        expect(appBarMax - appBarMin, lessThan(2));
        expect(
          tester.getTopLeft(find.text('Nested Scroll')).dy,
          closeTo(appBarTop, 2),
        );

        await disposeAndFlush(tester);
      },
    );

    testWidgets('pulling while AppBar is collapsed does not refresh', (
      tester,
    ) async {
      final key = GlobalKey<_NestedRecipeHarnessState>();
      await tester.pumpWidget(_NestedRecipeHarness(key: key));
      final state = key.currentState!;
      await tester.pumpAndSettle();

      await tester.drag(find.byType(NestedScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(NestedScrollView), const Offset(0, 80));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(state.refreshCalled, isFalse);

      await disposeAndFlush(tester);
    });

    testWidgets('pushing up after page Header pull does not collapse first', (
      tester,
    ) async {
      final key = GlobalKey<_NestedRecipeHarnessState>();
      await tester.pumpWidget(_NestedRecipeHarness(key: key));
      final state = key.currentState!;
      await tester.pumpAndSettle();

      final nested = tester.state<NestedScrollViewState>(
        find.byType(NestedScrollView),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('item-0'))),
      );
      await gesture.moveBy(const Offset(0, 280));
      await tester.pump();

      expect(state.headerState?.offset ?? 0, greaterThan(70));
      final outerBefore = nested.outerController.position.pixels;

      await gesture.moveBy(const Offset(0, -160));
      await tester.pump();

      expect(nested.outerController.position.pixels, closeTo(outerBefore, 1));

      for (var i = 0; i < 12 && (state.headerState?.offset ?? 0) >= 70; i++) {
        await gesture.moveBy(const Offset(0, -80));
        await tester.pump();
      }
      expect(state.headerState?.offset ?? 0, lessThan(70));

      await gesture.up();
      await tester.pumpAndSettle();

      expect(state.refreshCalled, isFalse);

      await disposeAndFlush(tester);
    });

    testWidgets('nested fling to top does not stick page Header', (
      tester,
    ) async {
      final key = GlobalKey<_NestedRecipeHarnessState>();
      await tester.pumpWidget(_NestedRecipeHarness(key: key));
      final state = key.currentState!;
      await tester.pumpAndSettle();

      await tester.drag(find.byType(NestedScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();

      await tester.fling(
        find.byType(NestedScrollView),
        const Offset(0, 80),
        4000,
      );
      await tester.pumpAndSettle();

      expect(state.refreshCalled, isFalse);
      expect(state.headerState?.offset ?? 0, lessThan(1));

      await disposeAndFlush(tester);
    });

    testWidgets('inner bottom pull triggers load and footer dismisses', (
      tester,
    ) async {
      final key = GlobalKey<_NestedRecipeHarnessState>();
      await tester.pumpWidget(_NestedRecipeHarness(key: key));
      final state = key.currentState!;
      await tester.pumpAndSettle();

      final nested = tester.state<NestedScrollViewState>(
        find.byType(NestedScrollView),
      );
      nested.innerController.jumpTo(
        nested.innerController.position.maxScrollExtent,
      );
      await tester.pump();

      final lastItem = find.byKey(Key('item-${state.itemCount - 1}'));
      final gesture = await tester.startGesture(tester.getCenter(lastItem));
      await gesture.moveBy(const Offset(0, -280));
      await tester.pump();
      await gesture.up();
      await tester.pump();
      await waitUntil(() => state.loadCalled, tester);

      expect(state.loadCalled, isTrue);

      state.finishLoad();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));

      expect(
        state.footerState?.mode,
        anyOf(IndicatorMode.inactive, IndicatorMode.done),
      );

      await disposeAndFlush(tester);
    });

    testWidgets('inner infinite footer triggers load at bottom', (
      tester,
    ) async {
      final key = GlobalKey<_NestedRecipeHarnessState>();
      await tester.pumpWidget(
        _NestedRecipeHarness(key: key, infiniteFooter: true),
      );
      final state = key.currentState!;
      await tester.pumpAndSettle();

      final nested = tester.state<NestedScrollViewState>(
        find.byType(NestedScrollView),
      );
      nested.innerController.jumpTo(
        nested.innerController.position.maxScrollExtent,
      );
      await tester.pump();

      final lastItem = find.byKey(Key('item-${state.itemCount - 1}'));
      await tester.drag(lastItem, const Offset(0, -40));
      await tester.pump();
      await waitUntil(() => state.loadCalled, tester);

      expect(state.loadCalled, isTrue);

      await disposeAndFlush(tester);
    });

    testWidgets('nested fling after refresh does not assert result', (
      tester,
    ) async {
      final key = GlobalKey<_NestedRecipeHarnessState>();
      await tester.pumpWidget(_NestedRecipeHarness(key: key));
      final state = key.currentState!;
      await tester.pumpAndSettle();

      Object? resultAssertion;
      final previous = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exception is AssertionError &&
            details.exception.toString().contains('result')) {
          resultAssertion = details.exception;
        }
        previous?.call(details);
      };
      addTearDown(() => FlutterError.onError = previous);

      state.controller.callRefresh();
      await waitUntil(() => state.refreshCalled, tester);
      state.finishRefresh();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      await tester.fling(
        find.byKey(const Key('item-0')),
        const Offset(0, -400),
        2500,
      );
      await tester.pumpAndSettle();

      expect(resultAssertion, isNull);

      await disposeAndFlush(tester);
    });

    testWidgets('callRefresh and callLoad use nested controllers', (
      tester,
    ) async {
      final key = GlobalKey<_NestedRecipeHarnessState>();
      await tester.pumpWidget(_NestedRecipeHarness(key: key));
      final state = key.currentState!;
      await tester.pumpAndSettle();

      state.controller.callRefresh(duration: null);
      await waitUntil(() => state.refreshCalled, tester);
      expect(state.refreshCalled, isTrue);
      state.finishRefresh();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      state.controller.callLoad(duration: null);
      await waitUntil(() => state.loadCalled, tester);
      expect(state.loadCalled, isTrue);
      state.finishLoad();
      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('per-tab Footer EasyRefresh keeps load state independent', (
      tester,
    ) async {
      final key = GlobalKey<_NestedTabLoadHarnessState>();
      await tester.pumpWidget(_NestedTabLoadHarness(key: key));
      final state = key.currentState!;
      await tester.pumpAndSettle();

      final nested = tester.state<NestedScrollViewState>(
        find.byType(NestedScrollView),
      );
      expect(nested.innerController.hasClients, isTrue);

      state.tab0Controller.callLoad(duration: null);
      await waitUntil(() => state.tab0LoadCalled, tester);

      expect(state.tab0LoadCalled, isTrue);
      expect(state.tab1LoadCalled, isFalse);

      state.finishTab0Load(IndicatorResult.noMore);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      state.tabController.animateTo(1);
      await tester.pumpAndSettle();

      state.tab1Controller.callLoad(duration: null);
      await waitUntil(() => state.tab1LoadCalled, tester);

      expect(state.tab1LoadCalled, isTrue);
      expect(state.tab0LoadResult, IndicatorResult.noMore);

      state.finishTab1Load();
      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('shared Footer follows the visible TabBarView inner', (
      tester,
    ) async {
      final key = GlobalKey<_NestedSharedTabHarnessState>();
      await tester.pumpWidget(_NestedSharedTabHarness(key: key));
      final state = key.currentState!;
      await tester.pumpAndSettle();

      ScrollPosition visibleInner(String prefix) {
        return Scrollable.of(tester.element(find.byKey(Key('$prefix-item-0'))))
            .position;
      }

      expect(find.byKey(const Key('shared0-item-0')), findsOneWidget);
      final tab0Max = visibleInner('shared0').maxScrollExtent;

      state.tabController.animateTo(1);
      await tester.pumpAndSettle();
      await tester.pump();

      expect(find.byKey(const Key('shared1-item-0')), findsOneWidget);
      expect(
        visibleInner('shared1').maxScrollExtent,
        isNot(closeTo(tab0Max, 1)),
      );

      state.controller.callLoad(duration: null);
      await tester.pump();
      await tester.pump();
      expect(state.footerState, isNotNull);
      expect(
        identical(
          state.footerState!.notifier.position,
          visibleInner('shared1'),
        ),
        isTrue,
      );

      state.finishLoad();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      state.tabController.animateTo(0);
      await tester.pumpAndSettle();
      await tester.pump();

      state.controller.callLoad(duration: null);
      await tester.pump();
      await tester.pump();

      expect(state.footerState, isNotNull);
      expect(
        identical(
          state.footerState!.notifier.position,
          visibleInner('shared0'),
        ),
        isTrue,
      );

      state.finishLoad();
      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('inner clamping Header shows below AppBar and refreshes', (
      tester,
    ) async {
      final key = GlobalKey<_NestedInnerHeaderHarnessState>();
      await tester.pumpWidget(_NestedInnerHeaderHarness(key: key));
      final state = key.currentState!;
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('inner-item-0'))),
      );
      await gesture.moveBy(const Offset(0, 280));
      await tester.pump();
      await gesture.up();
      await tester.pump();
      await waitUntil(() => state.refreshCalled, tester);

      expect(state.refreshCalled, isTrue);
      expect(state.headerState?.mode, IndicatorMode.processing);

      state.finishRefresh();
      await tester.pump();
      await waitUntil(() => (state.headerState?.offset ?? 0) < 1, tester);
      expect(state.headerState?.offset ?? 0, lessThan(1));

      await disposeAndFlush(tester);
    });

    testWidgets('pushing up after nested pull retracts Header before AppBar', (
      tester,
    ) async {
      final key = GlobalKey<_NestedInnerHeaderHarnessState>();
      await tester.pumpWidget(_NestedInnerHeaderHarness(key: key));
      final state = key.currentState!;
      await tester.pumpAndSettle();

      final nested = tester.state<NestedScrollViewState>(
        find.byType(NestedScrollView),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('inner-item-0'))),
      );
      await gesture.moveBy(const Offset(0, 280));
      await tester.pump();

      expect(state.headerState?.offset ?? 0, greaterThan(70));
      final outerBefore = nested.outerController.position.pixels;
      final headerBefore = state.headerState!.offset;

      await gesture.moveBy(const Offset(0, -160));
      await tester.pump();

      expect(nested.outerController.position.pixels, closeTo(outerBefore, 1));
      expect(state.headerState!.offset, lessThan(headerBefore));

      for (var i = 0; i < 12 && (state.headerState?.offset ?? 0) >= 70; i++) {
        await gesture.moveBy(const Offset(0, -80));
        await tester.pump();
      }
      expect(state.headerState?.offset ?? 0, lessThan(70));

      await gesture.up();
      await tester.pumpAndSettle();

      expect(state.refreshCalled, isFalse);
      expect(state.headerState?.offset ?? 0, lessThan(1));

      await disposeAndFlush(tester);
    });

    testWidgets('inner nested fling to top does not stick Header', (
      tester,
    ) async {
      final key = GlobalKey<_NestedInnerHeaderHarnessState>();
      await tester.pumpWidget(_NestedInnerHeaderHarness(key: key));
      final state = key.currentState!;
      await tester.pumpAndSettle();

      await tester.drag(find.byType(NestedScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();

      await tester.fling(
        find.byType(NestedScrollView),
        const Offset(0, 80),
        4000,
      );
      await tester.pumpAndSettle();

      expect(state.refreshCalled, isFalse);
      expect(state.headerState?.offset ?? 0, lessThan(1));
      expect(state.headerState?.mode, anyOf(IndicatorMode.inactive, isNull));

      await disposeAndFlush(tester);
    });

    testWidgets('inner infinite Footer loads independently of page Header', (
      tester,
    ) async {
      final key = GlobalKey<_NestedInnerHeaderHarnessState>();
      await tester.pumpWidget(_NestedInnerHeaderHarness(key: key));
      final state = key.currentState!;
      await tester.pumpAndSettle();

      final nested = tester.state<NestedScrollViewState>(
        find.byType(NestedScrollView),
      );
      nested.innerController.jumpTo(
        nested.innerController.position.maxScrollExtent,
      );
      await tester.pump();

      final lastItem = find.byKey(Key('inner-item-${state.itemCount - 1}'));
      await tester.drag(lastItem, const Offset(0, -40));
      await tester.pump();
      await waitUntil(() => state.loadCalled, tester);

      expect(state.loadCalled, isTrue);
      expect(state.refreshCalled, isFalse);

      await disposeAndFlush(tester);
    });
  });

  group('EasyRefresh.builder with childBuilder Tests', () {
    testWidgets('EasyRefresh.builder renders with childBuilder', (
      tester,
    ) async {
      final key = GlobalKey<_BuilderPatternHarnessState>();
      await tester.pumpWidget(_BuilderPatternHarness(key: key));

      await tester.pumpAndSettle();

      expect(find.byType(EasyRefresh), findsOneWidget);
      expect(find.byType(CustomScrollView), findsOneWidget);

      await disposeAndFlush(tester);
    });

    testWidgets('childBuilder receives physics parameter', (tester) async {
      final key = GlobalKey<_BuilderPatternHarnessState>();
      await tester.pumpWidget(_BuilderPatternHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      // Trigger refresh via programmatic call
      state.controller.callRefresh();
      await tester.pump();

      // Wait for refresh to trigger
      for (int i = 0; i < 50 && !state.refreshCalled; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(state.refreshCalled, isTrue);

      state.finishRefresh();
      await tester.pump();
      await tester.pumpAndSettle();

      await disposeAndFlush(tester);
    });
  });

  group('TabBarView Integration Tests', () {
    testWidgets('EasyRefresh works inside TabBarView', (tester) async {
      final key = GlobalKey<_TabBarViewHarnessState>();
      await tester.pumpWidget(_TabBarViewHarness(key: key));

      await tester.pumpAndSettle();

      expect(find.byType(EasyRefresh), findsOneWidget);
      expect(find.byType(TabBarView), findsOneWidget);

      await disposeAndFlush(tester);
    });

    testWidgets('Refresh works in TabBarView first tab', (tester) async {
      final key = GlobalKey<_TabBarViewHarnessState>();
      await tester.pumpWidget(_TabBarViewHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      expect(state.refreshCalled, isFalse);

      // Trigger refresh via controller (more reliable in TabBarView)
      state.refreshController.callRefresh();
      await tester.pump();

      // Wait for refresh to trigger
      for (int i = 0; i < 50 && !state.refreshCalled; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(state.refreshCalled, isTrue);

      state.finishRefresh();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('Tab switching preserves scroll state', (tester) async {
      final key = GlobalKey<_TabBarViewHarnessState>();
      await tester.pumpWidget(_TabBarViewHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      // Switch to tab 2
      state.tabController.animateTo(1);
      await tester.pumpAndSettle();

      expect(find.text('Tab 2 Content'), findsOneWidget);

      // Switch back to tab 1
      state.tabController.animateTo(0);
      await tester.pumpAndSettle();

      // Tab 1 items should still be visible
      expect(find.byKey(const Key('tab1-item-0')), findsOneWidget);

      await disposeAndFlush(tester);
    });
  });

  group('ERScrollBehavior Tests', () {
    testWidgets('ERScrollBehavior is used by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EasyRefresh(
              onRefresh: () async {},
              child: ListView.builder(
                itemCount: 20,
                itemBuilder: (context, index) =>
                    ListTile(title: Text('Item $index')),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // EasyRefresh should render with default scroll behavior
      expect(find.byType(EasyRefresh), findsOneWidget);

      await disposeAndFlush(tester);
    });

    testWidgets('Custom scrollBehaviorBuilder can be provided', (tester) async {
      bool customBuilderCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EasyRefresh(
              scrollBehaviorBuilder: (physics) {
                customBuilderCalled = true;
                return ERScrollBehavior(physics);
              },
              onRefresh: () async {},
              child: ListView.builder(
                itemCount: 20,
                itemBuilder: (context, index) =>
                    ListTile(title: Text('Item $index')),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(customBuilderCalled, isTrue);

      await disposeAndFlush(tester);
    });
  });

  group('Physics Passed to Child Scrollables', () {
    testWidgets('Physics from EasyRefresh.builder is passed to child', (
      tester,
    ) async {
      ScrollPhysics? receivedPhysics;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EasyRefresh.builder(
              onRefresh: () async {},
              childBuilder: (context, physics) {
                receivedPhysics = physics;
                return ListView.builder(
                  physics: physics,
                  itemCount: 20,
                  itemBuilder: (context, index) =>
                      ListTile(title: Text('Item $index')),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Physics should have been received
      expect(receivedPhysics, isNotNull);
      expect(receivedPhysics.runtimeType.toString(), isNot(contains('Nested')));

      await disposeAndFlush(tester);
    });

    testWidgets('non-nested ListView can bounce pixels past min extent', (
      tester,
    ) async {
      final scrollController = ScrollController();
      addTearDown(scrollController.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EasyRefresh(
              onRefresh: () async {},
              header: const ClassicHeader(processedDuration: Duration.zero),
              child: ListView.builder(
                controller: scrollController,
                itemCount: 20,
                itemBuilder: (context, index) =>
                    ListTile(title: Text('Item $index')),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ListView)),
      );
      await gesture.moveBy(const Offset(0, 120));
      await tester.pump();

      expect(scrollController.position.pixels, lessThan(0));

      await gesture.up();
      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('isNested builder physics is nested-safe', (tester) async {
      ScrollPhysics? receivedPhysics;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EasyRefresh.builder(
              isNested: true,
              header: const ClassicHeader(clamping: true),
              onRefresh: () async {},
              childBuilder: (context, physics) {
                receivedPhysics = physics;
                return NestedScrollView(
                  physics: physics,
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return const [
                      SliverAppBar(title: Text('Nested'), pinned: true),
                    ];
                  },
                  body: ListView(
                    physics: physics,
                    children: const [ListTile(title: Text('Item'))],
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(receivedPhysics, isNotNull);
      expect(
        receivedPhysics.runtimeType.toString(),
        contains('_ERNestedScrollPhysics'),
      );

      await disposeAndFlush(tester);
    });

    testWidgets(
      'isNested: false wrapping NestedScrollView keeps bouncing physics',
      (tester) async {
        ScrollPhysics? receivedPhysics;
        bool? headerIsNested;

        Widget buildApp({required String title}) {
          return MaterialApp(
            home: Scaffold(
              body: EasyRefresh.builder(
                isNested: false,
                onRefresh: () async {},
                childBuilder: (context, physics) {
                  receivedPhysics = physics;
                  return NestedScrollView(
                    physics: physics,
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [SliverAppBar(title: Text(title), pinned: true)];
                    },
                    body: ListView(
                      physics: physics,
                      children: [
                        Builder(
                          builder: (context) {
                            headerIsNested = EasyRefresh.of(context)
                                .headerNotifier
                                .isNested;
                            return const ListTile(title: Text('Item'));
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        }

        await tester.pumpWidget(buildApp(title: 'Nested'));
        await tester.pumpAndSettle();

        expect(
          receivedPhysics.runtimeType.toString(),
          isNot(contains('_ERNestedScrollPhysics')),
        );
        expect(headerIsNested, isFalse);

        await tester.pumpWidget(buildApp(title: 'Nested 2'));
        await tester.pump();

        expect(
          receivedPhysics.runtimeType.toString(),
          isNot(contains('_ERNestedScrollPhysics')),
        );
        expect(headerIsNested, isFalse);

        await disposeAndFlush(tester);
      },
    );

    testWidgets('auto-adopted inner EasyRefresh keeps isNested after rebuild', (
      tester,
    ) async {
      final key = GlobalKey<_AdoptedNestedFlagHarnessState>();
      await tester.pumpWidget(_AdoptedNestedFlagHarness(key: key));
      final state = key.currentState!;
      await tester.pumpAndSettle();

      expect(state.innerHeaderNested, isTrue);
      expect(state.innerFooterNested, isTrue);
      expect(
        state.innerPhysics.runtimeType.toString(),
        contains('_ERNestedScrollPhysics'),
      );

      state.bump();
      await tester.pump();

      expect(state.innerHeaderNested, isTrue);
      expect(state.innerFooterNested, isTrue);
      expect(
        state.innerPhysics.runtimeType.toString(),
        contains('_ERNestedScrollPhysics'),
      );

      await disposeAndFlush(tester);
    });
  });
}
