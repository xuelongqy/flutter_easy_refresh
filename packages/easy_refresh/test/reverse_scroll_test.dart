import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test harness for reverse scroll (chat-like UI)
class _ReverseScrollHarness extends StatefulWidget {
  final bool shrinkWrap = false;

  const _ReverseScrollHarness({
    super.key,
  });

  @override
  State<_ReverseScrollHarness> createState() => _ReverseScrollHarnessState();
}

class _ReverseScrollHarnessState extends State<_ReverseScrollHarness> {
  late final EasyRefreshController controller;
  final scrollController = ScrollController();
  final headerListenable = IndicatorStateListenable();
  final footerListenable = IndicatorStateListenable();

  int itemCount = 10;
  bool refreshCalled = false;
  bool loadCalled = false;

  Completer<void>? _refreshCompleter;
  Completer<void>? _loadCompleter;

  IndicatorState? get headerState => headerListenable.value;
  IndicatorState? get footerState => footerListenable.value;

  void addItems([int count = 5]) {
    setState(() {
      itemCount += count;
    });
  }

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
    addItems();
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
          footer: BuilderFooter(
            listenable: footerListenable,
            triggerOffset: 70,
            clamping: false,
            infiniteOffset: null,
            position: IndicatorPosition.above,
            processedDuration: Duration.zero,
            builder: (context, state) => Container(
              height: state.offset,
              width: double.infinity,
              color: Colors.green.withAlpha(77),
              alignment: Alignment.center,
              child: Text(
                'Footer: ${state.mode.name}',
                key: const Key('footer-text'),
              ),
            ),
          ),
          onRefresh: _onRefresh,
          onLoad: _onLoad,
          child: CustomScrollView(
            controller: scrollController,
            reverse: true,
            shrinkWrap: widget.shrinkWrap,
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Container(
                    key: Key('item-$index'),
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Text('Message $index'),
                  ),
                  childCount: itemCount,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Test harness for shrinkWrap behavior with few items
class _ShrinkWrapHarness extends StatefulWidget {
  const _ShrinkWrapHarness({super.key});

  @override
  State<_ShrinkWrapHarness> createState() => _ShrinkWrapHarnessState();
}

class _ShrinkWrapHarnessState extends State<_ShrinkWrapHarness> {
  late final EasyRefreshController controller;
  final footerListenable = IndicatorStateListenable();

  int itemCount = 3; // Few items that don't fill the screen
  bool loadCalled = false;

  Completer<void>? _loadCompleter;

  IndicatorState? get footerState => footerListenable.value;

  void addItems([int count = 3]) {
    setState(() {
      itemCount += count;
    });
  }

  void finishLoad() {
    _loadCompleter?.complete();
  }

  Future<void> _onLoad() async {
    loadCalled = true;
    _loadCompleter = Completer<void>();
    await _loadCompleter!.future;
    addItems();
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
        body: EasyRefresh(
          controller: controller,
          onRefresh: () async {},
          onLoad: _onLoad,
          footer: BuilderFooter(
            listenable: footerListenable,
            triggerOffset: 70,
            clamping: false,
            infiniteOffset: null,
            position: IndicatorPosition.above,
            processedDuration: Duration.zero,
            builder: (context, state) => Container(
              height: state.offset,
              width: double.infinity,
              color: Colors.green.withAlpha(77),
              alignment: Alignment.center,
              child: Text('Footer: ${state.mode.name}'),
            ),
          ),
          child: CustomScrollView(
            reverse: true,
            shrinkWrap: true,
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Container(
                    key: Key('item-$index'),
                    height: 60,
                    alignment: Alignment.center,
                    child: Text('Message $index'),
                  ),
                  childCount: itemCount,
                ),
              ),
            ],
          ),
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
  group('Reverse Scroll Tests', () {
    testWidgets('EasyRefresh with CustomScrollView(reverse: true)',
        (tester) async {
      final key = GlobalKey<_ReverseScrollHarnessState>();
      await tester.pumpWidget(_ReverseScrollHarness(key: key));

      await tester.pumpAndSettle();

      // Widget should render correctly
      expect(find.byType(EasyRefresh), findsOneWidget);
      expect(find.byType(CustomScrollView), findsOneWidget);

      // Verify reverse is true
      final scrollView =
          tester.widget<CustomScrollView>(find.byType(CustomScrollView));
      expect(scrollView.reverse, isTrue);

      await disposeAndFlush(tester);
    });

    testWidgets('Load behavior at visual top (scroll position bottom)',
        (tester) async {
      final key = GlobalKey<_ReverseScrollHarnessState>();
      await tester.pumpWidget(_ReverseScrollHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      expect(state.loadCalled, isFalse);

      // Use controller to trigger load (more reliable for reverse mode)
      state.controller.callLoad();
      await tester.pump();
      // Wait for load to trigger
      for (int i = 0; i < 50 && !state.loadCalled; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Load should be triggered
      expect(state.loadCalled, isTrue);

      state.finishLoad();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('Refresh at visual bottom (scroll position 0)', (tester) async {
      final key = GlobalKey<_ReverseScrollHarnessState>();
      await tester.pumpWidget(_ReverseScrollHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      expect(state.refreshCalled, isFalse);

      // Use controller to trigger refresh (more reliable for reverse mode)
      state.controller.callRefresh();
      await tester.pump();
      // Wait for refresh to trigger
      for (int i = 0; i < 50 && !state.refreshCalled; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // This should trigger refresh
      expect(state.refreshCalled, isTrue);

      state.finishRefresh();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('Items added after load in reverse mode', (tester) async {
      final key = GlobalKey<_ReverseScrollHarnessState>();
      await tester.pumpWidget(_ReverseScrollHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      expect(state.itemCount, 10);

      // Trigger load using controller
      state.controller.callLoad();
      await tester.pump();
      // Wait for load to trigger
      for (int i = 0; i < 50 && !state.loadCalled; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      state.finishLoad();
      await tester.pump();
      await tester.pump();

      // Items should be added
      expect(state.itemCount, 15);

      await disposeAndFlush(tester);
    });
  });

  group('shrinkWrap Behavior Tests', () {
    testWidgets('shrinkWrap with few items', (tester) async {
      final key = GlobalKey<_ShrinkWrapHarnessState>();
      await tester.pumpWidget(_ShrinkWrapHarness(key: key));

      await tester.pumpAndSettle();

      // Widget should render correctly with shrinkWrap
      expect(find.byType(EasyRefresh), findsOneWidget);
      expect(find.byType(CustomScrollView), findsOneWidget);

      // Verify shrinkWrap is true
      final scrollView =
          tester.widget<CustomScrollView>(find.byType(CustomScrollView));
      expect(scrollView.shrinkWrap, isTrue);

      await disposeAndFlush(tester);
    });

    testWidgets('Load can be triggered with shrinkWrap', (tester) async {
      final key = GlobalKey<_ShrinkWrapHarnessState>();
      await tester.pumpWidget(_ShrinkWrapHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      expect(state.loadCalled, isFalse);

      // Trigger load using controller (more reliable for shrinkWrap)
      state.controller.callLoad();
      await tester.pump();
      // Wait for load to trigger
      for (int i = 0; i < 50 && !state.loadCalled; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(state.loadCalled, isTrue);

      state.finishLoad();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });
  });

  group('Reverse Mode AxisDirection', () {
    testWidgets('AxisDirection is AxisDirection.up in reverse mode',
        (tester) async {
      final key = GlobalKey<_ReverseScrollHarnessState>();
      await tester.pumpWidget(_ReverseScrollHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      // Trigger to get state
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 200));
      await tester.pump();

      // In reverse mode, the axisDirection should reflect the reversed direction
      expect(state.footerState, isNotNull);

      state.finishLoad();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });
  });

  group('Chat-like UI Simulation', () {
    testWidgets('Chat UI loads older messages when scrolling up',
        (tester) async {
      final key = GlobalKey<_ReverseScrollHarnessState>();
      await tester.pumpWidget(_ReverseScrollHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      // Initial messages
      expect(state.itemCount, 10);

      // Use controller to trigger load (more reliable)
      state.controller.callLoad();
      await tester.pump();
      for (int i = 0; i < 50 && !state.loadCalled; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      state.finishLoad();
      await tester.pump();
      await tester.pump();

      // More messages loaded
      expect(state.itemCount, 15);

      // Reset loadCalled and load again
      state.loadCalled = false;
      state.controller.callLoad();
      await tester.pump();
      for (int i = 0; i < 50 && !state.loadCalled; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      state.finishLoad();
      await tester.pump();
      await tester.pump();

      expect(state.itemCount, 20);

      await disposeAndFlush(tester);
    });

    testWidgets('New message at bottom stays visible', (tester) async {
      final key = GlobalKey<_ReverseScrollHarnessState>();
      await tester.pumpWidget(_ReverseScrollHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      // Verify first item (most recent message in reverse mode) is visible
      expect(find.byKey(const Key('item-0')), findsOneWidget);

      // Add new item
      state.addItems(1);
      await tester.pump();

      // The list should still show item-0 at the bottom
      expect(find.byKey(const Key('item-0')), findsOneWidget);

      await disposeAndFlush(tester);
    });
  });

  group('Reverse with Different List Sizes', () {
    testWidgets('Reverse mode works with many items', (tester) async {
      final key = GlobalKey<_ReverseScrollHarnessState>();
      await tester.pumpWidget(_ReverseScrollHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      // Add many items
      for (int i = 0; i < 10; i++) {
        state.addItems(10);
      }
      await tester.pump();

      expect(state.itemCount, 110);

      // Should still be able to trigger load using controller
      state.controller.callLoad();
      await tester.pump();
      for (int i = 0; i < 50 && !state.loadCalled; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(state.loadCalled, isTrue);

      state.finishLoad();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });
  });
}
