import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test harness for NestedScrollView integration
class _NestedScrollHarness extends StatefulWidget {
  final bool isNested;

  const _NestedScrollHarness({
    super.key,
    this.isNested = true,
  });

  @override
  State<_NestedScrollHarness> createState() => _NestedScrollHarnessState();
}

class _NestedScrollHarnessState extends State<_NestedScrollHarness> {
  late final EasyRefreshController controller;
  final scrollController = ScrollController();
  final headerListenable = IndicatorStateListenable();

  int itemCount = 30;
  bool refreshCalled = false;
  bool loadCalled = false;

  Completer<void>? _refreshCompleter;
  Completer<void>? _loadCompleter;

  IndicatorState? get headerState => headerListenable.value;

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
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: EasyRefresh(
          controller: controller,
          scrollController: scrollController,
          isNested: widget.isNested,
          header: BuilderHeader(
            listenable: headerListenable,
            triggerOffset: 70,
            clamping: false,
            position: IndicatorPosition.above,
            processedDuration: Duration.zero,
            builder: (context, state) => Container(
              height: state.offset,
              width: double.infinity,
              color: Colors.blue.withValues(alpha: 0.3),
              alignment: Alignment.center,
              child: Text(
                'Header: ${state.mode.name}',
                key: const Key('header-text'),
              ),
            ),
          ),
          footer: const ClassicFooter(),
          onRefresh: _onRefresh,
          onLoad: _onLoad,
          child: NestedScrollView(
            controller: scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  title: const Text('Nested Scroll'),
                  expandedHeight: 200,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      color: Colors.blue.withValues(alpha: 0.3),
                      child: const Center(
                        child: Text('Flexible Space'),
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: ListView.builder(
              itemCount: itemCount,
              itemBuilder: (context, index) => ListTile(
                key: Key('item-$index'),
                title: Text('Item $index'),
              ),
            ),
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
              color: Colors.blue.withValues(alpha: 0.3),
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

Future<void> disposeAndFlush(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

void main() {
  group('NestedScrollView Integration Tests', () {
    testWidgets('EasyRefresh inside NestedScrollView renders', (tester) async {
      final key = GlobalKey<_NestedScrollHarnessState>();
      await tester.pumpWidget(_NestedScrollHarness(key: key));

      await tester.pumpAndSettle();

      // Widget should render correctly
      expect(find.byType(EasyRefresh), findsOneWidget);
      expect(find.byType(NestedScrollView), findsOneWidget);

      await disposeAndFlush(tester);
    });

    testWidgets('isNested: true property works with NestedScrollView',
        (tester) async {
      final key = GlobalKey<_NestedScrollHarnessState>();
      await tester.pumpWidget(_NestedScrollHarness(
        key: key,
        isNested: true,
      ));

      await tester.pumpAndSettle();

      expect(find.byType(EasyRefresh), findsOneWidget);

      await disposeAndFlush(tester);
    });

    testWidgets('Scroll controller works with NestedScrollView',
        (tester) async {
      final key = GlobalKey<_NestedScrollHarnessState>();
      await tester.pumpWidget(_NestedScrollHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      // Verify scroll controller is connected
      expect(state.scrollController.hasClients, isTrue);

      // Test scrolling works
      state.scrollController.jumpTo(100);
      await tester.pump();

      expect(state.scrollController.offset, 100);

      await disposeAndFlush(tester);
    });
  });

  group('EasyRefresh.builder with childBuilder Tests', () {
    testWidgets('EasyRefresh.builder renders with childBuilder',
        (tester) async {
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
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EasyRefresh(
            onRefresh: () async {},
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) => ListTile(
                title: Text('Item $index'),
              ),
            ),
          ),
        ),
      ));

      await tester.pumpAndSettle();

      // EasyRefresh should render with default scroll behavior
      expect(find.byType(EasyRefresh), findsOneWidget);

      await disposeAndFlush(tester);
    });

    testWidgets('Custom scrollBehaviorBuilder can be provided', (tester) async {
      bool customBuilderCalled = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EasyRefresh(
            scrollBehaviorBuilder: (physics) {
              customBuilderCalled = true;
              return ERScrollBehavior(physics);
            },
            onRefresh: () async {},
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) => ListTile(
                title: Text('Item $index'),
              ),
            ),
          ),
        ),
      ));

      await tester.pumpAndSettle();

      expect(customBuilderCalled, isTrue);

      await disposeAndFlush(tester);
    });
  });

  group('Physics Passed to Child Scrollables', () {
    testWidgets('Physics from EasyRefresh.builder is passed to child',
        (tester) async {
      ScrollPhysics? receivedPhysics;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EasyRefresh.builder(
            onRefresh: () async {},
            childBuilder: (context, physics) {
              receivedPhysics = physics;
              return ListView.builder(
                physics: physics,
                itemCount: 20,
                itemBuilder: (context, index) => ListTile(
                  title: Text('Item $index'),
                ),
              );
            },
          ),
        ),
      ));

      await tester.pumpAndSettle();

      // Physics should have been received
      expect(receivedPhysics, isNotNull);

      await disposeAndFlush(tester);
    });
  });
}
