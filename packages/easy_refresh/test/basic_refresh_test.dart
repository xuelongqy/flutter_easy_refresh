import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test harness for basic refresh/load functionality
class _BasicRefreshHarness extends StatefulWidget {
  final bool controlFinishRefresh;
  final bool controlFinishLoad;
  final Duration processedDuration;
  final double triggerOffset = 70;

  const _BasicRefreshHarness({
    super.key,
    this.controlFinishRefresh = false,
    this.controlFinishLoad = false,
    this.processedDuration = Duration.zero,
  });

  @override
  State<_BasicRefreshHarness> createState() => _BasicRefreshHarnessState();
}

class _BasicRefreshHarnessState extends State<_BasicRefreshHarness> {
  late final EasyRefreshController controller;
  final scrollController = ScrollController();
  final headerListenable = IndicatorStateListenable();
  final footerListenable = IndicatorStateListenable();

  int itemCount = 20;
  bool refreshCalled = false;
  bool loadCalled = false;
  IndicatorResult? lastRefreshResult;
  IndicatorResult? lastLoadResult;

  final _refreshStarted = Completer<void>();
  final _loadStarted = Completer<void>();
  Completer<IndicatorResult>? _refreshCompleter;
  Completer<IndicatorResult>? _loadCompleter;

  Future<void> get refreshStarted => _refreshStarted.future;
  Future<void> get loadStarted => _loadStarted.future;
  IndicatorState? get headerState => headerListenable.value;
  IndicatorState? get footerState => footerListenable.value;

  void appendItems([int delta = 10]) {
    setState(() {
      itemCount += delta;
    });
  }

  void resetItems([int count = 10]) {
    setState(() {
      itemCount = count;
    });
  }

  void finishRefresh([IndicatorResult result = IndicatorResult.success]) {
    if (widget.controlFinishRefresh) {
      controller.finishRefresh(result);
      return;
    }
    _refreshCompleter?.complete(result);
  }

  void finishLoad([IndicatorResult result = IndicatorResult.success]) {
    if (widget.controlFinishLoad) {
      controller.finishLoad(result);
      return;
    }
    _loadCompleter?.complete(result);
  }

  Future<IndicatorResult?> _onRefresh() async {
    refreshCalled = true;
    if (!_refreshStarted.isCompleted) {
      _refreshStarted.complete();
    }
    if (widget.controlFinishRefresh) {
      return null;
    }
    _refreshCompleter ??= Completer<IndicatorResult>();
    final result = await _refreshCompleter!.future;
    lastRefreshResult = result;
    return result;
  }

  Future<IndicatorResult?> _onLoad() async {
    loadCalled = true;
    if (!_loadStarted.isCompleted) {
      _loadStarted.complete();
    }
    if (widget.controlFinishLoad) {
      return null;
    }
    _loadCompleter ??= Completer<IndicatorResult>();
    final result = await _loadCompleter!.future;
    lastLoadResult = result;
    return result;
  }

  @override
  void initState() {
    super.initState();
    controller = EasyRefreshController(
      controlFinishRefresh: widget.controlFinishRefresh,
      controlFinishLoad: widget.controlFinishLoad,
    );
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
            triggerOffset: widget.triggerOffset,
            clamping: false,
            processedDuration: widget.processedDuration,
            position: IndicatorPosition.above,
            builder: (context, state) => Container(
              height: state.offset,
              width: double.infinity,
              alignment: Alignment.center,
              child: Text(
                'header:${state.mode.name}',
                key: const Key('header-debug'),
              ),
            ),
          ),
          footer: BuilderFooter(
            listenable: footerListenable,
            triggerOffset: widget.triggerOffset,
            clamping: false,
            processedDuration: widget.processedDuration,
            infiniteOffset: null,
            builder: (context, state) => Container(
              height: state.offset,
              width: double.infinity,
              alignment: Alignment.center,
              child: Text(
                'footer:${state.mode.name}',
                key: const Key('footer-debug'),
              ),
            ),
          ),
          onRefresh: _onRefresh,
          onLoad: _onLoad,
          child: ListView.builder(
            controller: scrollController,
            itemExtent: 50,
            itemCount: itemCount,
            itemBuilder: (context, index) => ListTile(
              key: Key('item-$index'),
              title: Text('Item $index'),
            ),
          ),
        ),
      ),
    );
  }
}

/// Trigger refresh via pull-down gesture
Future<void> triggerRefresh(WidgetTester tester) async {
  await tester.drag(find.byType(ListView), const Offset(0, 200));
  await tester.pump();
}

/// Trigger load via scroll-to-bottom gesture
Future<void> triggerLoad(
  WidgetTester tester,
  ScrollController controller,
) async {
  controller.jumpTo(controller.position.maxScrollExtent);
  await tester.pump();
  await tester.drag(find.byType(ListView), const Offset(0, -200));
  await tester.pump();
}

/// Clean up widget and advance fake timers
Future<void> disposeAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

void main() {
  group('Basic Refresh Tests', () {
    testWidgets('basic refresh triggers via pull gesture', (tester) async {
      final key = GlobalKey<_BasicRefreshHarnessState>();
      await tester.pumpWidget(_BasicRefreshHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      // Trigger refresh via pull gesture
      await triggerRefresh(tester);

      // Pump until refresh starts
      for (int i = 0; i < 20 && !state.refreshCalled; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(state.refreshCalled, isTrue);
      expect(state.headerState, isNotNull);
      expect(state.headerState!.mode, IndicatorMode.processing);

      // Finish refresh
      state.finishRefresh();
      await tester.pump();
      await tester.pump();

      // Mode should be done or inactive after finishing
      final headerMode = state.headerState!.mode;
      expect(
          headerMode == IndicatorMode.inactive ||
              headerMode == IndicatorMode.done,
          isTrue);

      await disposeAndFlush(tester);
    });

    testWidgets('basic load triggers via scroll to bottom', (tester) async {
      final key = GlobalKey<_BasicRefreshHarnessState>();
      await tester.pumpWidget(_BasicRefreshHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      // Trigger load via scroll to bottom
      await triggerLoad(tester, state.scrollController);

      // Wait for load to start
      for (int i = 0; i < 50 && !state.loadCalled; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(state.loadCalled, isTrue);
      expect(state.footerState, isNotNull);
      expect(state.footerState!.mode, IndicatorMode.processing);

      // Finish load
      state.finishLoad();
      await tester.pump();
      await tester.pump();

      // Mode should be done or inactive after finishing
      final footerMode = state.footerState!.mode;
      expect(
          footerMode == IndicatorMode.inactive ||
              footerMode == IndicatorMode.done,
          isTrue);

      await disposeAndFlush(tester);
    });

    testWidgets('refresh callback execution updates item count',
        (tester) async {
      final key = GlobalKey<_BasicRefreshHarnessState>();
      await tester.pumpWidget(_BasicRefreshHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      expect(state.itemCount, 20);

      // Trigger refresh
      await triggerRefresh(tester);
      for (int i = 0; i < 50 && !state.refreshCalled; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Update items during refresh
      state.resetItems(5);
      await tester.pump();

      expect(state.itemCount, 5);

      // Finish refresh
      state.finishRefresh();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('load callback execution appends items', (tester) async {
      final key = GlobalKey<_BasicRefreshHarnessState>();
      await tester.pumpWidget(_BasicRefreshHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      expect(state.itemCount, 20);

      // Trigger load
      await triggerLoad(tester, state.scrollController);
      for (int i = 0; i < 50 && !state.loadCalled; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Append items during load
      state.appendItems(10);
      await tester.pump();

      expect(state.itemCount, 30);

      // Finish load
      state.finishLoad();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('IndicatorResult.success handling', (tester) async {
      final key = GlobalKey<_BasicRefreshHarnessState>();
      await tester.pumpWidget(_BasicRefreshHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      // Trigger refresh
      await triggerRefresh(tester);
      for (int i = 0; i < 50 && !state.refreshCalled; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Finish with success
      state.finishRefresh(IndicatorResult.success);
      await tester.pump();

      expect(state.headerState!.result, IndicatorResult.success);

      await tester.pump();
      // Mode should be done or inactive after success
      final headerMode = state.headerState!.mode;
      expect(
          headerMode == IndicatorMode.inactive ||
              headerMode == IndicatorMode.done,
          isTrue);

      await disposeAndFlush(tester);
    });

    testWidgets('IndicatorResult.noMore handling for footer', (tester) async {
      final key = GlobalKey<_BasicRefreshHarnessState>();
      await tester.pumpWidget(_BasicRefreshHarness(
        key: key,
        controlFinishLoad: true,
      ));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      // Trigger load
      await triggerLoad(tester, state.scrollController);
      for (int i = 0; i < 50 && !state.loadCalled; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Finish with noMore
      state.finishLoad(IndicatorResult.noMore);
      await tester.pump();

      expect(state.footerState!.result, IndicatorResult.noMore);

      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('IndicatorResult.fail handling', (tester) async {
      final key = GlobalKey<_BasicRefreshHarnessState>();
      await tester.pumpWidget(_BasicRefreshHarness(
        key: key,
        controlFinishRefresh: true,
      ));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      // Trigger refresh
      await triggerRefresh(tester);
      for (int i = 0; i < 50 && !state.refreshCalled; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Finish with fail
      state.finishRefresh(IndicatorResult.fail);
      await tester.pump();

      expect(state.headerState!.result, IndicatorResult.fail);

      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('processedDuration delays transition to inactive',
        (tester) async {
      final key = GlobalKey<_BasicRefreshHarnessState>();
      await tester.pumpWidget(_BasicRefreshHarness(
        key: key,
        processedDuration: const Duration(milliseconds: 200),
      ));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      // Trigger refresh
      await triggerRefresh(tester);
      for (int i = 0; i < 50 && !state.refreshCalled; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Finish refresh
      state.finishRefresh();
      await tester.pump();

      // Should be in processed state
      expect(state.headerState!.mode, IndicatorMode.processed);

      // Wait for processedDuration
      await tester.pump(const Duration(milliseconds: 250));

      // Should now be done or inactive
      final headerMode = state.headerState!.mode;
      expect(
          headerMode == IndicatorMode.inactive ||
              headerMode == IndicatorMode.done,
          isTrue);

      await disposeAndFlush(tester);
    });

    testWidgets('indicator offset changes during pull', (tester) async {
      final key = GlobalKey<_BasicRefreshHarnessState>();
      await tester.pumpWidget(_BasicRefreshHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      // Start drag without releasing
      final gesture =
          await tester.startGesture(tester.getCenter(find.byType(ListView)));
      await gesture.moveBy(const Offset(0, 50));
      await tester.pump();

      // Header offset should increase
      expect(state.headerState, isNotNull);
      expect(state.headerState!.offset, greaterThan(0));
      expect(state.headerState!.mode, IndicatorMode.drag);

      // Continue dragging past trigger
      await gesture.moveBy(const Offset(0, 100));
      await tester.pump();

      expect(state.headerState!.mode, IndicatorMode.armed);

      // Release to trigger refresh
      await gesture.up();
      await tester.pump();

      for (int i = 0; i < 50 && !state.refreshCalled; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(state.headerState!.mode, IndicatorMode.processing);

      state.finishRefresh();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });
  });
}
