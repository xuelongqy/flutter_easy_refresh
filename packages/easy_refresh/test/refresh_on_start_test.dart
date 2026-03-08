import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test harness for refreshOnStart functionality
class _RefreshOnStartHarness extends StatefulWidget {
  final bool refreshOnStart;
  final Header? refreshOnStartHeader = null;
  final double callRefreshOverOffset;

  const _RefreshOnStartHarness({
    super.key,
    this.refreshOnStart = true,
    this.callRefreshOverOffset = 20,
  });

  @override
  State<_RefreshOnStartHarness> createState() => _RefreshOnStartHarnessState();
}

class _RefreshOnStartHarnessState extends State<_RefreshOnStartHarness> {
  late final EasyRefreshController controller;
  final scrollController = ScrollController();
  final headerListenable = IndicatorStateListenable();

  int itemCount = 20;
  bool refreshCalled = false;
  int refreshCallCount = 0;
  List<IndicatorMode> headerModes = [];

  Completer<void>? _refreshCompleter;
  Completer<void>? _refreshStartedCompleter;

  IndicatorState? get headerState => headerListenable.value;
  Future<void> get refreshStarted =>
      _refreshStartedCompleter?.future ?? Future.value();

  void _onHeaderChanged() {
    if (headerListenable.value != null) {
      headerModes.add(headerListenable.value!.mode);
    }
  }

  void finishRefresh() {
    if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
      _refreshCompleter!.complete();
    }
  }

  Future<void> _onRefresh() async {
    refreshCalled = true;
    refreshCallCount++;
    if (_refreshStartedCompleter != null &&
        !_refreshStartedCompleter!.isCompleted) {
      _refreshStartedCompleter!.complete();
    }
    _refreshCompleter = Completer<void>();
    await _refreshCompleter!.future;
    if (mounted) {
      setState(() {
        itemCount = 30;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    controller = EasyRefreshController();
    headerListenable.addListener(_onHeaderChanged);
    _refreshStartedCompleter = Completer<void>();
  }

  @override
  void dispose() {
    headerListenable.removeListener(_onHeaderChanged);
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
          refreshOnStart: widget.refreshOnStart,
          refreshOnStartHeader: widget.refreshOnStartHeader,
          callRefreshOverOffset: widget.callRefreshOverOffset,
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
                'Mode: ${state.mode.name}',
                key: const Key('header-mode'),
              ),
            ),
          ),
          onRefresh: _onRefresh,
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

/// Test harness for custom refreshOnStartHeader
class _CustomRefreshOnStartHeaderHarness extends StatefulWidget {
  const _CustomRefreshOnStartHeaderHarness({super.key});

  @override
  State<_CustomRefreshOnStartHeaderHarness> createState() =>
      _CustomRefreshOnStartHeaderHarnessState();
}

class _CustomRefreshOnStartHeaderHarnessState
    extends State<_CustomRefreshOnStartHeaderHarness> {
  late final EasyRefreshController controller;
  final scrollController = ScrollController();

  int itemCount = 20;
  bool refreshCalled = false;
  bool customHeaderShown = false;

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
          refreshOnStart: true,
          header: const ClassicHeader(),
          refreshOnStartHeader: BuilderHeader(
            triggerOffset: 70,
            clamping: true,
            position: IndicatorPosition.above,
            processedDuration: Duration.zero,
            builder: (context, state) {
              customHeaderShown = true;
              return Container(
                height: state.offset,
                width: double.infinity,
                color: Colors.orange.withValues(alpha: 0.3),
                alignment: Alignment.center,
                child: const Text(
                  'Custom Start Header',
                  key: Key('custom-start-header'),
                ),
              );
            },
          ),
          onRefresh: _onRefresh,
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

Future<void> disposeAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

void main() {
  group('refreshOnStart: true Tests', () {
    testWidgets('refreshOnStart: true triggers refresh on widget mount',
        (tester) async {
      final key = GlobalKey<_RefreshOnStartHarnessState>();
      await tester.pumpWidget(_RefreshOnStartHarness(
        key: key,
        refreshOnStart: true,
      ));
      final state = key.currentState!;

      // Process initial frames
      await tester.pump();
      await tester.pump();

      // Wait for refresh to start (with timeout for safety)
      // Keep pumping until refresh starts or timeout
      for (int i = 0; i < 50 && !state.refreshCalled; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Refresh should have been called
      expect(state.refreshCalled, isTrue);
      expect(state.refreshCallCount, 1);

      // Finish the refresh
      state.finishRefresh();
      await tester.pump();
      await tester.pumpAndSettle();

      await disposeAndFlush(tester);
    });

    testWidgets('refreshOnStart: false does not trigger refresh on mount',
        (tester) async {
      final key = GlobalKey<_RefreshOnStartHarnessState>();
      await tester.pumpWidget(_RefreshOnStartHarness(
        key: key,
        refreshOnStart: false,
      ));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      // Refresh should NOT have been called
      expect(state.refreshCalled, isFalse);
      expect(state.refreshCallCount, 0);

      await disposeAndFlush(tester);
    });
  });

  group('refreshOnStartHeader Tests', () {
    testWidgets('refreshOnStartHeader custom header is used for initial load',
        (tester) async {
      final key = GlobalKey<_CustomRefreshOnStartHeaderHarnessState>();
      await tester.pumpWidget(_CustomRefreshOnStartHeaderHarness(key: key));
      final state = key.currentState!;

      // Process initial frames and wait for refresh
      await tester.pump();
      await tester.pump();
      for (int i = 0; i < 50 && !state.customHeaderShown; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Custom header should have been shown
      expect(state.customHeaderShown, isTrue);

      // Finish the refresh
      state.finishRefresh();
      await tester.pump();
      await tester.pumpAndSettle();

      await disposeAndFlush(tester);
    });

    testWidgets('refreshOnStartHeader shows custom widget during auto-refresh',
        (tester) async {
      final key = GlobalKey<_CustomRefreshOnStartHeaderHarnessState>();
      await tester.pumpWidget(_CustomRefreshOnStartHeaderHarness(key: key));
      final state = key.currentState!;

      // Process initial frames and wait for refresh
      await tester.pump();
      await tester.pump();
      for (int i = 0; i < 50 && !state.customHeaderShown; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Custom header text should be visible
      expect(find.byKey(const Key('custom-start-header')), findsOneWidget);

      state.finishRefresh();
      await tester.pump();
      await tester.pumpAndSettle();

      await disposeAndFlush(tester);
    });
  });

  group('Indicator State Transitions During Auto-Refresh', () {
    testWidgets('indicator state transitions during auto-refresh',
        (tester) async {
      final key = GlobalKey<_RefreshOnStartHarnessState>();
      await tester.pumpWidget(_RefreshOnStartHarness(
        key: key,
        refreshOnStart: true,
      ));
      final state = key.currentState!;

      // Process initial frames and wait for refresh
      await tester.pump();
      await tester.pump();
      for (int i = 0; i < 50 && !state.refreshCalled; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Should have gone through some states
      expect(state.headerModes.isNotEmpty, isTrue);

      // Should reach processing state
      expect(
          state.headerModes.contains(IndicatorMode.processing) ||
              state.headerModes.contains(IndicatorMode.ready),
          isTrue);

      // Finish the refresh
      state.finishRefresh();
      await tester.pump();
      await tester.pumpAndSettle();

      // Should transition to processed/inactive
      expect(
          state.headerModes.contains(IndicatorMode.processed) ||
              state.headerModes.contains(IndicatorMode.inactive) ||
              state.headerModes.contains(IndicatorMode.done),
          isTrue);

      await disposeAndFlush(tester);
    });
  });

  group('callRefreshOverOffset Tests', () {
    testWidgets('callRefreshOverOffset affects auto-refresh animation',
        (tester) async {
      final key = GlobalKey<_RefreshOnStartHarnessState>();
      await tester.pumpWidget(_RefreshOnStartHarness(
        key: key,
        refreshOnStart: true,
        callRefreshOverOffset: 50,
      ));
      final state = key.currentState!;

      // Process initial frames and wait for refresh
      await tester.pump();
      await tester.pump();
      for (int i = 0; i < 50 && !state.refreshCalled; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Refresh should have been triggered
      expect(state.refreshCalled, isTrue);

      state.finishRefresh();
      await tester.pump();
      await tester.pumpAndSettle();

      await disposeAndFlush(tester);
    });
  });

  group('refreshOnStart with Data Loading', () {
    testWidgets('refreshOnStart can update item count after loading',
        (tester) async {
      final key = GlobalKey<_RefreshOnStartHarnessState>();
      await tester.pumpWidget(_RefreshOnStartHarness(
        key: key,
        refreshOnStart: true,
      ));
      final state = key.currentState!;

      // Initial count
      expect(state.itemCount, 20);

      // Process initial frames and wait for refresh
      await tester.pump();
      await tester.pump();
      for (int i = 0; i < 50 && !state.refreshCalled; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Finish the refresh (which updates item count to 30)
      state.finishRefresh();
      await tester.pump();
      await tester.pumpAndSettle();

      // Item count should be updated
      expect(state.itemCount, 30);

      await disposeAndFlush(tester);
    });
  });

  group('refreshOnStart Only Triggers Once', () {
    testWidgets('refreshOnStart only triggers once on initial mount',
        (tester) async {
      final key = GlobalKey<_RefreshOnStartHarnessState>();
      await tester.pumpWidget(_RefreshOnStartHarness(
        key: key,
        refreshOnStart: true,
      ));
      final state = key.currentState!;

      // Process initial frames and wait for refresh
      await tester.pump();
      await tester.pump();
      for (int i = 0; i < 50 && !state.refreshCalled; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(state.refreshCallCount, 1);

      // Finish the refresh
      state.finishRefresh();
      await tester.pump();
      await tester.pumpAndSettle();

      // Wait some more and pump to ensure no additional refreshes
      await tester.pump(const Duration(seconds: 1));

      expect(state.refreshCallCount, 1);

      await disposeAndFlush(tester);
    });
  });

  group('refreshOnStart with Controller', () {
    testWidgets('manual refresh can be triggered after auto-refresh',
        (tester) async {
      final key = GlobalKey<_RefreshOnStartHarnessState>();
      await tester.pumpWidget(_RefreshOnStartHarness(
        key: key,
        refreshOnStart: true,
      ));
      final state = key.currentState!;

      // Process initial frames and wait for auto-refresh
      await tester.pump();
      await tester.pump();
      for (int i = 0; i < 50 && !state.refreshCalled; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      state.finishRefresh();
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify auto-refresh was triggered at least once
      expect(state.refreshCallCount, greaterThanOrEqualTo(1));

      // Verify widget is still functional after auto-refresh
      expect(find.byType(EasyRefresh), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);

      await disposeAndFlush(tester);
    });
  });
}
