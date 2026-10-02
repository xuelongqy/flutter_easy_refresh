import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class _TriggerModeHarness extends StatefulWidget {
  const _TriggerModeHarness({
    super.key,
    this.triggerMode = IndicatorTriggerMode.anywhere,
    this.footerTriggerMode = IndicatorTriggerMode.anywhere,
    this.clamping = false,
    this.triggerWhenReach = false,
    this.triggerWhenRelease = false,
    this.secondary = false,
    this.axis = Axis.vertical,
    this.reverse = false,
  });

  final IndicatorTriggerMode triggerMode;
  final IndicatorTriggerMode footerTriggerMode;
  final bool clamping;
  final bool triggerWhenReach;
  final bool triggerWhenRelease;
  final bool secondary;
  final Axis axis;
  final bool reverse;

  @override
  State<_TriggerModeHarness> createState() => _TriggerModeHarnessState();
}

class _TriggerModeHarnessState extends State<_TriggerModeHarness> {
  final controller = EasyRefreshController();
  final scrollController = ScrollController();
  final headerListenable = IndicatorStateListenable();
  final footerListenable = IndicatorStateListenable();
  var refreshCalls = 0;
  var loadCalls = 0;

  IndicatorState? get headerState => headerListenable.value;
  IndicatorState? get footerState => footerListenable.value;

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Header header = BuilderHeader(
      listenable: headerListenable,
      triggerOffset: 70,
      clamping: widget.clamping,
      triggerMode: widget.triggerMode,
      triggerWhenReach: widget.triggerWhenReach,
      triggerWhenRelease: widget.triggerWhenRelease,
      processedDuration: Duration.zero,
      position: IndicatorPosition.above,
      builder: (context, state) => SizedBox(
        width: widget.axis == Axis.horizontal ? state.offset : null,
        height: widget.axis == Axis.vertical ? state.offset : null,
      ),
    );
    if (widget.secondary) {
      header = SecondaryBuilderHeader(
        header: header,
        secondaryTriggerOffset: 120,
        secondaryDimension: 200,
        builder: (context, state, indicator) => SizedBox(height: state.offset),
      );
    }
    return MaterialApp(
      home: Scaffold(
        body: EasyRefresh(
          controller: controller,
          scrollController: scrollController,
          header: header,
          footer: OverrideFooter(
            footer: ClassicFooter(
              triggerMode: widget.footerTriggerMode,
              clamping: widget.clamping,
              infiniteOffset: widget.clamping ? null : 70,
            ),
            listenable: footerListenable,
          ),
          onRefresh: () async {
            refreshCalls++;
          },
          onLoad: () async {
            loadCalls++;
          },
          child: ListView.builder(
            key: const Key('list'),
            controller: scrollController,
            scrollDirection: widget.axis,
            reverse: widget.reverse,
            itemExtent: 50,
            itemCount: 30,
            itemBuilder: (context, index) => Text('Item $index'),
          ),
        ),
      ),
    );
  }
}

class _NestedTriggerModeHarness extends StatefulWidget {
  const _NestedTriggerModeHarness({super.key});

  @override
  State<_NestedTriggerModeHarness> createState() =>
      _NestedTriggerModeHarnessState();
}

class _NestedTriggerModeHarnessState extends State<_NestedTriggerModeHarness> {
  final headerListenable = IndicatorStateListenable();
  var refreshCalls = 0;

  IndicatorState? get headerState => headerListenable.value;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: EasyRefresh.nested(
          header: BuilderHeader(
            listenable: headerListenable,
            triggerOffset: 70,
            clamping: true,
            triggerMode: IndicatorTriggerMode.onEdge,
            processedDuration: Duration.zero,
            position: IndicatorPosition.locator,
            builder: (context, state) => SizedBox(height: state.offset),
          ),
          footer: const ClassicFooter(
            infiniteOffset: null,
            position: IndicatorPosition.locator,
          ),
          onRefresh: () async {
            refreshCalls++;
          },
          onLoad: () async {},
          headerSliverBuilder: (context, innerBoxIsScrolled) => const [
            SliverAppBar(expandedHeight: 160, pinned: true),
          ],
          body: CustomScrollView(
            key: const Key('nested-list'),
            slivers: [
              SliverFixedExtentList(
                itemExtent: 50,
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Text('Item $index'),
                  childCount: 30,
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

Future<TestGesture> _dragFromMiddleToOverscroll(
  WidgetTester tester,
  _TriggerModeHarnessState state,
) async {
  state.scrollController.jumpTo(250);
  await tester.pump();
  final gesture = await tester.startGesture(
    tester.getCenter(find.byKey(const Key('list'))),
  );
  await gesture.moveBy(_pullDelta(state, 260));
  await tester.pump();
  await gesture.moveBy(_pullDelta(state, 220));
  await tester.pump();
  return gesture;
}

Future<TestGesture> _dragFromMiddleToFooter(
  WidgetTester tester,
  _TriggerModeHarnessState state,
) async {
  state.scrollController.jumpTo(250);
  await tester.pump();
  final gesture = await tester.startGesture(
    tester.getCenter(find.byKey(const Key('list'))),
  );
  await gesture.moveBy(const Offset(0, -700));
  await tester.pump();
  await gesture.moveBy(const Offset(0, -220));
  await tester.pump();
  return gesture;
}

Offset _pullDelta(_TriggerModeHarnessState state, double distance) {
  final signedDistance = state.widget.reverse ? -distance : distance;
  return state.widget.axis == Axis.vertical
      ? Offset(0, signedDistance)
      : Offset(signedDistance, 0);
}

Future<void> _pullFromEdge(
  WidgetTester tester,
  _TriggerModeHarnessState state,
) async {
  final gesture = await tester.startGesture(
    tester.getCenter(find.byKey(const Key('list'))),
  );
  await gesture.moveBy(_pullDelta(state, 180));
  await tester.pump();
  await gesture.up();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('default anywhere keeps same-gesture refresh behavior', (
    tester,
  ) async {
    final key = GlobalKey<_TriggerModeHarnessState>();
    await tester.pumpWidget(_TriggerModeHarness(key: key));
    await tester.pumpAndSettle();

    final state = key.currentState!;
    final gesture = await _dragFromMiddleToOverscroll(tester, state);
    expect(state.headerState?.mode, IndicatorMode.armed);
    expect(state.headerState?.offset ?? 0, greaterThan(70));

    await gesture.up();
    await tester.pumpAndSettle();
    expect(state.refreshCalls, 1);
  });

  for (final clamping in [false, true]) {
    testWidgets('onEdge rejects a middle-start drag (clamping: $clamping)', (
      tester,
    ) async {
      final key = GlobalKey<_TriggerModeHarnessState>();
      await tester.pumpWidget(
        _TriggerModeHarness(
          key: key,
          triggerMode: IndicatorTriggerMode.onEdge,
          clamping: clamping,
        ),
      );
      await tester.pumpAndSettle();

      final state = key.currentState!;
      final gesture = await _dragFromMiddleToOverscroll(tester, state);
      expect(state.headerState?.mode, IndicatorMode.inactive);
      expect(state.headerState?.offset ?? 0, 0);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(state.refreshCalls, 0);

      expect(state.scrollController.offset, 0);
      await _pullFromEdge(tester, state);
      expect(state.refreshCalls, 1);
    });
  }

  for (final triggerWhenReach in [false, true]) {
    testWidgets('onEdge cannot be bypassed by trigger timing '
        '(triggerWhenReach: $triggerWhenReach)', (tester) async {
      final key = GlobalKey<_TriggerModeHarnessState>();
      await tester.pumpWidget(
        _TriggerModeHarness(
          key: key,
          triggerMode: IndicatorTriggerMode.onEdge,
          triggerWhenReach: triggerWhenReach,
          triggerWhenRelease: !triggerWhenReach,
        ),
      );
      await tester.pumpAndSettle();

      final state = key.currentState!;
      final gesture = await _dragFromMiddleToOverscroll(tester, state);
      expect(state.headerState?.mode, IndicatorMode.inactive);
      expect(state.refreshCalls, 0);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(state.refreshCalls, 0);
    });
  }

  testWidgets('onEdge blocks secondary for a middle-start drag', (
    tester,
  ) async {
    final key = GlobalKey<_TriggerModeHarnessState>();
    await tester.pumpWidget(
      _TriggerModeHarness(
        key: key,
        triggerMode: IndicatorTriggerMode.onEdge,
        secondary: true,
      ),
    );
    await tester.pumpAndSettle();

    final state = key.currentState!;
    final gesture = await _dragFromMiddleToOverscroll(tester, state);
    expect(state.headerState?.mode, IndicatorMode.inactive);
    expect(state.headerState?.offset ?? 0, 0);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(state.refreshCalls, 0);
  });

  testWidgets('onEdge still allows secondary when the drag starts at edge', (
    tester,
  ) async {
    final key = GlobalKey<_TriggerModeHarnessState>();
    await tester.pumpWidget(
      _TriggerModeHarness(
        key: key,
        triggerMode: IndicatorTriggerMode.onEdge,
        secondary: true,
      ),
    );
    await tester.pumpAndSettle();

    final state = key.currentState!;
    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('list'))),
    );
    await gesture.moveBy(_pullDelta(state, 240));
    await tester.pump();
    expect(
      state.headerState?.mode,
      anyOf(IndicatorMode.secondaryArmed, IndicatorMode.secondaryReady),
    );
    await gesture.up();
    await tester.pumpAndSettle();
    expect(state.headerState?.mode, IndicatorMode.secondaryOpen);
    expect(state.refreshCalls, 0);
  });

  testWidgets('onEdge does not block controller refresh', (tester) async {
    final key = GlobalKey<_TriggerModeHarnessState>();
    await tester.pumpWidget(
      _TriggerModeHarness(key: key, triggerMode: IndicatorTriggerMode.onEdge),
    );
    await tester.pumpAndSettle();

    final state = key.currentState!;
    final gesture = await _dragFromMiddleToOverscroll(tester, state);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(state.refreshCalls, 0);

    await state.controller.callRefresh(duration: null);
    await tester.pumpAndSettle();
    expect(state.refreshCalls, 1);
  });

  for (final configuration in [
    (axis: Axis.vertical, reverse: true, name: 'reverse'),
    (axis: Axis.horizontal, reverse: false, name: 'horizontal'),
  ]) {
    testWidgets('onEdge detects ${configuration.name} Header edge', (
      tester,
    ) async {
      final key = GlobalKey<_TriggerModeHarnessState>();
      await tester.pumpWidget(
        _TriggerModeHarness(
          key: key,
          triggerMode: IndicatorTriggerMode.onEdge,
          axis: configuration.axis,
          reverse: configuration.reverse,
        ),
      );
      await tester.pumpAndSettle();

      final state = key.currentState!;
      final gesture = await _dragFromMiddleToOverscroll(tester, state);
      expect(state.headerState?.mode, IndicatorMode.inactive);
      expect(state.headerState?.offset ?? 0, 0);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(state.refreshCalls, 0);

      await _pullFromEdge(tester, state);
      expect(state.refreshCalls, 1);
    });
  }

  testWidgets('onEdge uses one drag-start decision across nested positions', (
    tester,
  ) async {
    final key = GlobalKey<_NestedTriggerModeHarnessState>();
    await tester.pumpWidget(_NestedTriggerModeHarness(key: key));
    await tester.pumpAndSettle();

    final list = find.byKey(const Key('nested-list'));
    await tester.drag(list, const Offset(0, -350));
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(tester.getCenter(list));
    await gesture.moveBy(const Offset(0, 600));
    await tester.pump();
    expect(key.currentState!.headerState?.mode, IndicatorMode.inactive);
    expect(key.currentState!.headerState?.offset ?? 0, 0);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(key.currentState!.refreshCalls, 0);

    await tester.drag(list, const Offset(0, 180));
    await tester.pumpAndSettle();
    expect(key.currentState!.refreshCalls, 1);
  });

  testWidgets('Footer defaults to anywhere for same-gesture load', (
    tester,
  ) async {
    final key = GlobalKey<_TriggerModeHarnessState>();
    await tester.pumpWidget(_TriggerModeHarness(key: key));
    await tester.pumpAndSettle();

    final state = key.currentState!;
    final gesture = await _dragFromMiddleToFooter(tester, state);
    expect(state.loadCalls, 1);
    await gesture.up();
    await tester.pumpAndSettle();
  });

  for (final clamping in [false, true]) {
    testWidgets(
      'Footer onEdge rejects a middle-start drag (clamping: $clamping)',
      (tester) async {
        final key = GlobalKey<_TriggerModeHarnessState>();
        await tester.pumpWidget(
          _TriggerModeHarness(
            key: key,
            footerTriggerMode: IndicatorTriggerMode.onEdge,
            clamping: clamping,
          ),
        );
        await tester.pumpAndSettle();

        final state = key.currentState!;
        final gesture = await _dragFromMiddleToFooter(tester, state);
        expect(state.footerState?.mode, IndicatorMode.inactive);
        expect(state.footerState?.offset ?? 0, 0);
        expect(state.loadCalls, 0);
        await gesture.up();
        await tester.pumpAndSettle();

        state.scrollController.jumpTo(
          state.scrollController.position.maxScrollExtent,
        );
        await tester.pump();
        await tester.drag(find.byKey(const Key('list')), const Offset(0, -180));
        await tester.pumpAndSettle();
        expect(state.loadCalls, 1);
      },
    );
  }
}
