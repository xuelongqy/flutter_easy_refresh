import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test harness for ListenerHeader with IndicatorStateListenable
class _ListenerIndicatorHarness extends StatefulWidget {
  final double triggerOffset;
  final bool clamping;

  const _ListenerIndicatorHarness({
    super.key,
    this.triggerOffset = 70,
    this.clamping = true,
  });

  @override
  State<_ListenerIndicatorHarness> createState() =>
      _ListenerIndicatorHarnessState();
}

class _ListenerIndicatorHarnessState extends State<_ListenerIndicatorHarness> {
  late final EasyRefreshController controller;
  final scrollController = ScrollController();
  final headerListenable = IndicatorStateListenable();
  final footerListenable = IndicatorStateListenable();

  int itemCount = 60;
  List<IndicatorMode> headerModes = [];
  List<double> headerOffsets = [];
  int headerListenerCallCount = 0;
  int footerListenerCallCount = 0;

  Completer<void>? _refreshCompleter;
  Completer<void>? _loadCompleter;

  IndicatorState? get headerState => headerListenable.value;
  IndicatorState? get footerState => footerListenable.value;

  void _onHeaderStateChanged() {
    headerListenerCallCount++;
    if (headerListenable.value != null) {
      headerModes.add(headerListenable.value!.mode);
      headerOffsets.add(headerListenable.value!.offset);
    }
  }

  void _onFooterStateChanged() {
    footerListenerCallCount++;
  }

  void finishRefresh() {
    _refreshCompleter?.complete();
  }

  void finishLoad() {
    _loadCompleter?.complete();
  }

  Future<void> _onRefresh() async {
    _refreshCompleter = Completer<void>();
    await _refreshCompleter!.future;
  }

  Future<void> _onLoad() async {
    _loadCompleter = Completer<void>();
    await _loadCompleter!.future;
  }

  @override
  void initState() {
    super.initState();
    controller = EasyRefreshController();
    headerListenable.addListener(_onHeaderStateChanged);
    footerListenable.addListener(_onFooterStateChanged);
  }

  @override
  void dispose() {
    headerListenable.removeListener(_onHeaderStateChanged);
    footerListenable.removeListener(_onFooterStateChanged);
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            // External indicator display using ValueListenableBuilder
            ValueListenableBuilder<IndicatorState?>(
              valueListenable: headerListenable,
              builder: (context, state, child) {
                if (state == null) {
                  return const SizedBox(
                    height: 50,
                    child: Text('No state'),
                  );
                }
                return Container(
                  height: 50,
                  color: Colors.blue.withAlpha(51),
                  alignment: Alignment.center,
                  child: Text(
                    'External: ${state.mode.name} - ${state.offset.toStringAsFixed(1)}',
                    key: const Key('external-header-state'),
                  ),
                );
              },
            ),
            Expanded(
              child: EasyRefresh(
                controller: controller,
                scrollController: scrollController,
                header: ListenerHeader(
                  listenable: headerListenable,
                  triggerOffset: widget.triggerOffset,
                  clamping: widget.clamping,
                ),
                footer: ListenerFooter(
                  listenable: footerListenable,
                  triggerOffset: 70,
                  clamping: widget.clamping,
                  infiniteOffset: null,
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
          ],
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
  group('ListenerHeader Tests', () {
    testWidgets('ListenerHeader with IndicatorStateListenable', (tester) async {
      final key = GlobalKey<_ListenerIndicatorHarnessState>();
      await tester.pumpWidget(_ListenerIndicatorHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      state.headerModes.clear();
      state.headerOffsets.clear();
      state.headerListenerCallCount = 0;

      // Trigger refresh
      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      // Listener should have been called
      expect(state.headerListenerCallCount, greaterThan(0));
      expect(state.headerModes.isNotEmpty, isTrue);

      state.finishRefresh();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('ValueListenableBuilder updates on state changes',
        (tester) async {
      final key = GlobalKey<_ListenerIndicatorHarnessState>();
      await tester.pumpWidget(_ListenerIndicatorHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      // Trigger refresh to update state
      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      // External display should update - the ValueListenableBuilder should show the state
      expect(find.byKey(const Key('external-header-state')), findsOneWidget);

      // The text should contain mode and offset info
      final textFinder = find.byKey(const Key('external-header-state'));
      expect(textFinder, findsOneWidget);

      state.finishRefresh();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('IndicatorState properties are accessible', (tester) async {
      final key = GlobalKey<_ListenerIndicatorHarnessState>();
      await tester.pumpWidget(_ListenerIndicatorHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      // Trigger refresh
      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      // Check IndicatorState properties
      final headerState = state.headerState;
      expect(headerState, isNotNull);
      expect(headerState!.mode, isA<IndicatorMode>());
      expect(headerState.offset, isA<double>());
      expect(headerState.actualTriggerOffset, isA<double>());
      expect(headerState.axis, isA<Axis>());
      expect(headerState.axisDirection, isA<AxisDirection>());
      expect(headerState.viewportDimension, isA<double>());
      expect(headerState.result, isA<IndicatorResult>());

      state.finishRefresh();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('High triggerOffset scenario', (tester) async {
      final key = GlobalKey<_ListenerIndicatorHarnessState>();
      await tester.pumpWidget(_ListenerIndicatorHarness(
        key: key,
        triggerOffset: 200,
        clamping: false,
      ));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      state.headerModes.clear();

      // Drag less than triggerOffset
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ListView)),
      );
      await gesture.moveBy(const Offset(0, 100));
      await tester.pump();

      // Should be in drag mode
      expect(state.headerModes.contains(IndicatorMode.drag), isTrue);

      // Drag past triggerOffset
      await gesture.moveBy(const Offset(0, 150));
      await tester.pump();

      // Should record some modes during drag
      expect(state.headerModes.isNotEmpty, isTrue);

      await gesture.up();
      await tester.pump();

      // Wait for refresh to potentially start
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      state.finishRefresh();
      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      await disposeAndFlush(tester);
    });
  });

  group('ListenerFooter Tests', () {
    testWidgets('ListenerFooter updates through listenable', (tester) async {
      final key = GlobalKey<_ListenerIndicatorHarnessState>();
      await tester.pumpWidget(_ListenerIndicatorHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      state.footerListenerCallCount = 0;

      // Scroll to bottom
      state.scrollController.jumpTo(
        state.scrollController.position.maxScrollExtent,
      );
      await tester.pump();

      // Trigger load
      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pump();

      // Footer listener should have been called
      expect(state.footerListenerCallCount, greaterThan(0));
      expect(state.footerState, isNotNull);

      state.finishLoad();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });
  });

  group('IndicatorStateListenable Tests', () {
    testWidgets('IndicatorStateListenable can add and remove listeners',
        (tester) async {
      final listenable = IndicatorStateListenable();
      int callCount = 0;

      void listener() {
        callCount++;
      }

      listenable.addListener(listener);
      expect(callCount, 0); // No calls yet

      listenable.removeListener(listener);
      // Should not throw
    });

    testWidgets('IndicatorStateListenable value is null initially',
        (tester) async {
      final listenable = IndicatorStateListenable();
      expect(listenable.value, isNull);
    });

    testWidgets('Multiple listeners receive updates', (tester) async {
      final key = GlobalKey<_ListenerIndicatorHarnessState>();
      await tester.pumpWidget(_ListenerIndicatorHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      int additionalCallCount = 0;
      void additionalListener() {
        additionalCallCount++;
      }

      state.headerListenable.addListener(additionalListener);

      // Trigger refresh
      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      // Both listeners should be called
      expect(state.headerListenerCallCount, greaterThan(0));
      expect(additionalCallCount, greaterThan(0));

      state.headerListenable.removeListener(additionalListener);

      state.finishRefresh();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });
  });

  group('Listener Position Custom', () {
    testWidgets('ListenerHeader uses IndicatorPosition.custom', (tester) async {
      final header = ListenerHeader(
        listenable: IndicatorStateListenable(),
        triggerOffset: 70,
      );

      expect(header.position, IndicatorPosition.custom);
    });

    testWidgets('ListenerFooter uses IndicatorPosition.custom', (tester) async {
      final footer = ListenerFooter(
        listenable: IndicatorStateListenable(),
        triggerOffset: 70,
        infiniteOffset: null,
      );

      expect(footer.position, IndicatorPosition.custom);
    });
  });

  group('Listener with External Widget Updates', () {
    testWidgets('External widget updates in real-time during drag',
        (tester) async {
      final key = GlobalKey<_ListenerIndicatorHarnessState>();
      await tester.pumpWidget(_ListenerIndicatorHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      // Start drag
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ListView)),
      );

      await gesture.moveBy(const Offset(0, 50));
      await tester.pump();

      // External widget should show updated state
      expect(find.byKey(const Key('external-header-state')), findsOneWidget);

      await gesture.moveBy(const Offset(0, 50));
      await tester.pump();

      // Should still be updated
      expect(find.byKey(const Key('external-header-state')), findsOneWidget);

      await gesture.up();
      await tester.pump();

      // Wait for refresh to potentially start
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      state.finishRefresh();
      await tester.pump();
      await tester.pump();

      // Allow any pending timers to complete
      await tester.pump(const Duration(seconds: 2));

      await disposeAndFlush(tester);
    });
  });
}
