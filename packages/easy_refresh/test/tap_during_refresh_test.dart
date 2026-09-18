import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Harness for #913: tapping during pull-to-refresh leaves the Header stuck.
class _TapDuringRefreshHarness extends StatefulWidget {
  const _TapDuringRefreshHarness({
    super.key,
    this.manualCompletion = false,
    this.processedDuration = Duration.zero,
    this.clamping = false,
    this.nested = false,
    this.secondary = false,
    this.classic = false,
  });

  final bool manualCompletion;
  final Duration processedDuration;
  final bool clamping;
  final bool nested;
  final bool secondary;
  final bool classic;

  @override
  State<_TapDuringRefreshHarness> createState() =>
      _TapDuringRefreshHarnessState();
}

class _TapDuringRefreshHarnessState extends State<_TapDuringRefreshHarness> {
  late final EasyRefreshController controller;
  final scrollController = ScrollController();
  final headerListenable = IndicatorStateListenable();
  final footerListenable = IndicatorStateListenable();

  int refreshCalls = 0;
  int loadCalls = 0;
  Completer<void>? _refreshCompleter;
  Completer<void>? _loadCompleter;

  bool get refreshCalled => refreshCalls > 0;
  IndicatorState? get headerState => headerListenable.value;
  IndicatorState? get footerState => footerListenable.value;

  void finishRefresh() {
    if (widget.manualCompletion) {
      controller.finishRefresh();
    } else {
      _refreshCompleter!.complete();
    }
  }

  void finishLoad() {
    if (widget.manualCompletion) {
      controller.finishLoad();
    } else {
      _loadCompleter!.complete();
    }
  }

  Future<void> _onRefresh() async {
    refreshCalls++;
    if (widget.manualCompletion) {
      return;
    }
    _refreshCompleter = Completer<void>();
    await _refreshCompleter!.future;
  }

  Future<void> _onLoad() async {
    loadCalls++;
    if (widget.manualCompletion) {
      return;
    }
    _loadCompleter = Completer<void>();
    await _loadCompleter!.future;
  }

  @override
  void initState() {
    super.initState();
    controller = EasyRefreshController(
      controlFinishRefresh: widget.manualCompletion,
      controlFinishLoad: widget.manualCompletion,
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
    final Header header = widget.classic
        ? OverrideHeader(
            header: ClassicHeader(processedDuration: widget.processedDuration),
            listenable: headerListenable,
          )
        : BuilderHeader(
            listenable: headerListenable,
            triggerOffset: 70,
            clamping: widget.clamping || widget.nested,
            processedDuration: widget.processedDuration,
            position: widget.nested
                ? IndicatorPosition.locator
                : IndicatorPosition.above,
            secondaryTriggerOffset: widget.secondary ? 120 : null,
            secondaryDimension: widget.secondary ? 200 : null,
            builder: (context, state) => SizedBox(
              height: state.offset,
              width: double.infinity,
              child: Text(
                'header:${state.mode.name}',
                key: const Key('header-debug'),
              ),
            ),
          );
    final footer = BuilderFooter(
      listenable: footerListenable,
      triggerOffset: 70,
      clamping: widget.clamping || widget.nested,
      processedDuration: widget.processedDuration,
      infiniteOffset: null,
      position: widget.nested
          ? IndicatorPosition.locator
          : IndicatorPosition.above,
      secondaryTriggerOffset: widget.secondary ? 120 : null,
      secondaryDimension: widget.secondary ? 200 : null,
      builder: (context, state) => SizedBox(
        height: state.offset,
        width: double.infinity,
        child: Text('footer:${state.mode.name}'),
      ),
    );
    Widget itemBuilder(BuildContext context, int index) =>
        ListTile(key: Key('item-$index'), title: Text('Item $index'));

    return MaterialApp(
      home: Scaffold(
        body: widget.nested
            ? EasyRefresh.nested(
                controller: controller,
                header: header,
                footer: footer,
                onRefresh: _onRefresh,
                onLoad: _onLoad,
                headerSliverBuilder: (context, innerBoxIsScrolled) => const [
                  SliverAppBar(expandedHeight: 160, pinned: true),
                ],
                body: CustomScrollView(
                  key: const Key('refresh-list'),
                  slivers: [
                    SliverFixedExtentList(
                      itemExtent: 50,
                      delegate: SliverChildBuilderDelegate(
                        itemBuilder,
                        childCount: 30,
                      ),
                    ),
                    const FooterLocator.sliver(),
                  ],
                ),
              )
            : EasyRefresh(
                controller: controller,
                scrollController: scrollController,
                header: header,
                footer: footer,
                onRefresh: _onRefresh,
                onLoad: _onLoad,
                child: ListView.builder(
                  key: const Key('refresh-list'),
                  controller: scrollController,
                  itemExtent: 50,
                  itemCount: 30,
                  itemBuilder: itemBuilder,
                ),
              ),
      ),
    );
  }
}

Future<void> _pullToRefresh(WidgetTester tester) async {
  await tester.drag(find.byType(ListView), const Offset(0, 200));
  await tester.pump();
}

Future<void> _waitUntil(
  bool Function() condition,
  WidgetTester tester, {
  Duration step = const Duration(milliseconds: 50),
}) async {
  for (var i = 0; i < 40 && !condition(); i++) {
    await tester.pump(step);
  }
  expect(
    condition(),
    isTrue,
    reason: 'Condition did not become true in 40 frames',
  );
}

Future<void> _tapList(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('item-5')));
  await tester.pump();
}

Future<void> _disposeAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

IndicatorState _indicator(_TapDuringRefreshHarnessState state, bool footer) =>
    (footer ? state.footerState : state.headerState)!;

ScrollPosition _listPosition(
  WidgetTester tester,
  _TapDuringRefreshHarnessState state,
) => state.widget.nested
    ? tester
          .state<NestedScrollViewState>(find.byType(NestedScrollView))
          .innerController
          .position
    : state.scrollController.position;

Future<void> _startTask(
  WidgetTester tester,
  _TapDuringRefreshHarnessState state, {
  bool footer = false,
}) async {
  if (footer) {
    final position = _listPosition(tester, state);
    position.jumpTo(position.maxScrollExtent);
    await tester.pump();
  }
  await tester.drag(
    find.byKey(const Key('refresh-list')),
    Offset(0, footer ? -280 : 280),
  );
  await tester.pump();
  await _waitUntil(
    () => (footer ? state.loadCalls : state.refreshCalls) == 1,
    tester,
  );
  await _waitUntil(
    () => (_indicator(state, footer).offset - 70).abs() < 0.1,
    tester,
  );
  // Let any remaining scroll activity stop without waiting on an animated
  // processing indicator (such as ClassicHeader's progress spinner).
  await tester.pump(const Duration(milliseconds: 100));
  expect(_indicator(state, footer).mode, IndicatorMode.processing);
}

Future<void> _tapViewport(WidgetTester tester, {int count = 1}) async {
  for (var i = 0; i < count; i++) {
    await tester.tapAt(tester.getCenter(find.byKey(const Key('refresh-list'))));
    await tester.pump();
  }
}

Future<void> _expectRetracted(
  WidgetTester tester,
  _TapDuringRefreshHarnessState state, {
  bool footer = false,
  int taskCalls = 1,
}) async {
  await tester.pumpAndSettle(
    const Duration(milliseconds: 16),
    EnginePhase.sendSemanticsUpdate,
    const Duration(seconds: 5),
  );
  expect(_indicator(state, footer).offset, lessThan(1));
  expect(_indicator(state, footer).mode, IndicatorMode.inactive);
  expect(state.refreshCalls, footer ? 0 : taskCalls);
  expect(state.loadCalls, footer ? taskCalls : 0);
  expect(tester.takeException(), isNull);
  expect(tester.binding.hasScheduledFrame, isFalse);
  await tester.pump(const Duration(milliseconds: 500));
  expect(tester.binding.hasScheduledFrame, isFalse);
  expect(tester.binding.transientCallbackCount, 0);
}

void _expectBoundaryPhysics(
  ScrollPosition position, {
  required bool footer,
  double overExtent = 0,
}) {
  final physics = position.physics;
  final tolerance = physics.toleranceFor(position).distance;
  final boundary = footer
      ? position.maxScrollExtent + overExtent
      : position.minScrollExtent - overExtent;

  try {
    for (final multiple in [0.0, 0.5, 1.0, 2.0]) {
      final distance = tolerance * multiple;
      final metrics = position.copyWith(
        pixels: boundary + (footer ? distance : -distance),
      );
      // Prime the snapshot before repeating the same metrics and zero velocity.
      physics.createBallisticSimulation(metrics, 0);
      for (var i = 0; i < 3; i++) {
        final simulation = physics.createBallisticSimulation(metrics, 0);
        if (multiple > 1) {
          expect(simulation, isNotNull);
          expect(simulation!.x(0), metrics.pixels);
          expect(simulation.x(10), closeTo(boundary, tolerance));
        } else {
          expect(simulation, isNull);
        }
      }
    }
  } finally {
    // Restore the real position so completion can still restart its activity.
    physics.createBallisticSimulation(position, 0);
  }
}

void main() {
  group('Issue 913 tapping during refresh', () {
    testWidgets('refresh without taps retracts Header', (tester) async {
      final key = GlobalKey<_TapDuringRefreshHarnessState>();
      await tester.pumpWidget(_TapDuringRefreshHarness(key: key));
      final state = key.currentState!;
      await tester.pumpAndSettle();

      await _pullToRefresh(tester);
      await _waitUntil(() => state.refreshCalled, tester);
      expect(state.headerState?.mode, IndicatorMode.processing);

      state.finishRefresh();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(state.headerState?.offset ?? 0, lessThan(1));

      await _expectRetracted(tester, state);
      await _disposeAndFlush(tester);
    });

    // Taps only while processing still retract after finish.
    // The freeze is a tap that interrupts the retract ballistic.

    testWidgets('#913 tap as Header starts retracting freezes offset', (
      tester,
    ) async {
      final key = GlobalKey<_TapDuringRefreshHarnessState>();
      await tester.pumpWidget(_TapDuringRefreshHarness(key: key));
      final state = key.currentState!;
      await tester.pumpAndSettle();

      await _pullToRefresh(tester);
      await _waitUntil(() => state.refreshCalled, tester);
      expect(state.headerState?.mode, IndicatorMode.processing);

      state.finishRefresh();
      await tester.pump();
      await _tapList(tester);
      await tester.pumpAndSettle();

      expect(
        state.headerState?.offset ?? 0,
        lessThan(1),
        reason:
            '#913: tapping when retract starts leaves Header at triggerOffset',
      );

      await _expectRetracted(tester, state);
      await _disposeAndFlush(tester);
    });

    testWidgets('#913 tapping through refresh and retract freezes Header', (
      tester,
    ) async {
      final key = GlobalKey<_TapDuringRefreshHarnessState>();
      await tester.pumpWidget(_TapDuringRefreshHarness(key: key));
      final state = key.currentState!;
      await tester.pumpAndSettle();

      await _pullToRefresh(tester);
      await _waitUntil(() => state.refreshCalled, tester);

      for (var i = 0; i < 6; i++) {
        await _tapList(tester);
      }

      state.finishRefresh();
      await tester.pump();
      for (var i = 0; i < 6; i++) {
        await _tapList(tester);
      }
      await tester.pumpAndSettle();

      expect(
        state.headerState?.offset ?? 0,
        lessThan(1),
        reason: '#913: keep tapping through refresh should still retract',
      );

      await _expectRetracted(tester, state);
      await _disposeAndFlush(tester);
    });
  });

  for (final footer in [false, true]) {
    final edge = footer ? 'Footer' : 'Header';

    group('$edge interrupted rebound', () {
      for (final afterMovement in [false, true]) {
        for (final tapCount in [1, 6]) {
          testWidgets(
            '${afterMovement ? 'mid-animation' : 'first-frame'} interruption '
            'with $tapCount tap(s) resumes',
            (tester) async {
              final key = GlobalKey<_TapDuringRefreshHarnessState>();
              await tester.pumpWidget(_TapDuringRefreshHarness(key: key));
              final state = key.currentState!;
              await _startTask(tester, state, footer: footer);

              (footer ? state.finishLoad : state.finishRefresh)();
              await tester.pump();
              // Future completion schedules the zero-duration processed phase
              // after a frame. Flush it without advancing the rebound clock.
              await _waitUntil(
                () => _indicator(state, footer).mode == IndicatorMode.done,
                tester,
                step: Duration.zero,
              );
              if (afterMovement) {
                await _waitUntil(
                  () => _indicator(state, footer).offset < 60,
                  tester,
                  step: const Duration(milliseconds: 16),
                );
              }
              final offset = _indicator(state, footer).offset;
              expect(offset, greaterThan(1));
              if (!afterMovement) {
                expect(offset, closeTo(70, 0.1));
              }

              if (tapCount == 1) {
                final gesture = await tester.startGesture(
                  tester.getCenter(find.byKey(const Key('refresh-list'))),
                );
                await tester.pump(const Duration(milliseconds: 40));
                expect(
                  _indicator(state, footer).offset,
                  closeTo(offset, 0.001),
                );
                await gesture.up();
                await tester.pump();
              } else {
                await _tapViewport(tester, count: tapCount);
              }

              await _expectRetracted(tester, state, footer: footer);
              await _disposeAndFlush(tester);
            },
          );
        }
      }
    });

    group('$edge completion timing', () {
      for (final manual in [false, true]) {
        for (final duration in [
          Duration.zero,
          const Duration(milliseconds: 200),
        ]) {
          testWidgets('${manual ? 'controller' : 'future'} completion, '
              '${duration.inMilliseconds}ms processed duration', (
            tester,
          ) async {
            final key = GlobalKey<_TapDuringRefreshHarnessState>();
            await tester.pumpWidget(
              _TapDuringRefreshHarness(
                key: key,
                manualCompletion: manual,
                processedDuration: duration,
              ),
            );
            final state = key.currentState!;
            await _startTask(tester, state, footer: footer);
            final position = _listPosition(tester, state);

            await _tapViewport(tester, count: 3);
            await tester.pump(const Duration(milliseconds: 50));
            expect(_indicator(state, footer).mode, IndicatorMode.processing);
            expect(_indicator(state, footer).offset, closeTo(70, 1));
            _expectBoundaryPhysics(position, footer: footer, overExtent: 70);
            expect(_indicator(state, footer).mode, IndicatorMode.processing);

            (footer ? state.finishLoad : state.finishRefresh)();
            await tester.pump();
            if (duration != Duration.zero) {
              expect(_indicator(state, footer).mode, IndicatorMode.processed);
              await _tapViewport(tester, count: 3);
              await tester.pump(const Duration(milliseconds: 100));
              expect(_indicator(state, footer).mode, IndicatorMode.processed);
              expect(_indicator(state, footer).offset, closeTo(70, 1));
              _expectBoundaryPhysics(position, footer: footer, overExtent: 70);
              expect(_indicator(state, footer).mode, IndicatorMode.processed);
              await tester.pump(const Duration(milliseconds: 100));
            }

            await _waitUntil(
              () => _indicator(state, footer).mode == IndicatorMode.done,
              tester,
              step: Duration.zero,
            );
            await _tapViewport(tester, count: 3);
            await _expectRetracted(tester, state, footer: footer);
            await _disposeAndFlush(tester);
          });
        }
      }
    });

    testWidgets(
      '$edge repeated zero-velocity requests respect distance tolerance',
      (tester) async {
        final key = GlobalKey<_TapDuringRefreshHarnessState>();
        await tester.pumpWidget(_TapDuringRefreshHarness(key: key));
        final state = key.currentState!;
        final position = state.scrollController.position;
        _expectBoundaryPhysics(position, footer: footer);
        expect(state.refreshCalls, 0);
        expect(state.loadCalls, 0);
        await _disposeAndFlush(tester);
      },
    );

    testWidgets('$edge secondary stays open on taps and closes explicitly', (
      tester,
    ) async {
      final key = GlobalKey<_TapDuringRefreshHarnessState>();
      await tester.pumpWidget(
        _TapDuringRefreshHarness(key: key, secondary: true),
      );
      final state = key.currentState!;
      if (footer) {
        // Attach the footer notifier to the real position before opening it.
        state.scrollController.jumpTo(
          state.scrollController.position.maxScrollExtent,
        );
        await tester.pump();
      }
      final opening = footer
          ? state.controller.openFooterSecondary()
          : state.controller.openHeaderSecondary();
      await tester.pumpAndSettle();
      await opening;
      expect(_indicator(state, footer).mode, IndicatorMode.secondaryOpen);
      expect(_indicator(state, footer).offset, closeTo(200, 1));

      _expectBoundaryPhysics(
        state.scrollController.position,
        footer: footer,
        overExtent: 200,
      );
      expect(_indicator(state, footer).mode, IndicatorMode.secondaryOpen);
      await _tapViewport(tester, count: 6);
      await tester.pumpAndSettle();
      expect(_indicator(state, footer).mode, IndicatorMode.secondaryOpen);
      expect(_indicator(state, footer).offset, closeTo(200, 1));
      expect(state.refreshCalls, 0);
      expect(state.loadCalls, 0);
      expect(tester.binding.hasScheduledFrame, isFalse);

      final closing = footer
          ? state.controller.closeFooterSecondary()
          : state.controller.closeHeaderSecondary();
      await _expectRetracted(tester, state, footer: footer, taskCalls: 0);
      await closing;
      await _disposeAndFlush(tester);
    });

    for (final nested in [false, true]) {
      testWidgets(
        '$edge ${nested ? 'nested' : 'clamping'} completion with taps',
        (tester) async {
          final key = GlobalKey<_TapDuringRefreshHarnessState>();
          await tester.pumpWidget(
            _TapDuringRefreshHarness(key: key, clamping: true, nested: nested),
          );
          final state = key.currentState!;
          await _startTask(tester, state, footer: footer);
          await _tapViewport(tester, count: 3);
          expect(_indicator(state, footer).mode, IndicatorMode.processing);
          (footer ? state.finishLoad : state.finishRefresh)();
          await tester.pump();
          await _tapViewport(tester, count: 3);
          await _expectRetracted(tester, state, footer: footer);
          await _disposeAndFlush(tester);
        },
      );
    }
  }

  testWidgets('ClassicHeader retracts after processed-duration taps', (
    tester,
  ) async {
    final key = GlobalKey<_TapDuringRefreshHarnessState>();
    await tester.pumpWidget(
      _TapDuringRefreshHarness(
        key: key,
        classic: true,
        processedDuration: const Duration(milliseconds: 200),
      ),
    );
    final state = key.currentState!;
    await _startTask(tester, state);
    await _tapViewport(tester, count: 3);
    state.finishRefresh();
    await tester.pump();
    expect(state.headerState!.mode, IndicatorMode.processed);
    await _tapViewport(tester, count: 3);
    await tester.pump(const Duration(milliseconds: 200));
    expect(state.headerState!.mode, IndicatorMode.done);
    await _tapViewport(tester, count: 3);
    await _expectRetracted(tester, state);
    await _disposeAndFlush(tester);
  });
}
