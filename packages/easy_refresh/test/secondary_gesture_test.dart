import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'secondary_test_harness.dart';

Future<void> frames(WidgetTester t, [int count = 120]) async {
  for (var i = 0; i < count; i++) {
    await t.pump(const Duration(milliseconds: 16));
  }
}

Future<void> swipe(WidgetTester t, Offset start, Offset delta) async {
  final g = await t.startGesture(start);
  for (var i = 0; i < 16; i++) {
    await g.moveBy(delta / 16);
    await t.pump(const Duration(milliseconds: 20));
  }
  await t.pump(const Duration(milliseconds: 120));
  await g.up();
  await frames(t);
}

Future<SecondaryHarnessState> mount(
  WidgetTester t,
  LayoutKind layout, {
  bool clamping = true,
}) async {
  final key = GlobalKey<SecondaryHarnessState>();
  await t.pumpWidget(
    SecondaryHarness(key: key, layout: layout, clamping: clamping),
  );
  await frames(t, 10);
  await swipe(t, const Offset(300, 180), const Offset(0, 360));
  final s = key.currentState!;
  expect(s.indicator!.mode, IndicatorMode.secondaryOpen);
  expect(s.indicator!.offset, 600);
  expect(s.refreshes, 0);
  return s;
}

Future<void> disposeHarness(WidgetTester t) async {
  expect(t.takeException(), isNull);
  expect(t.binding.hasScheduledFrame, isFalse);
  await t.pumpWidget(const SizedBox.shrink());
  await frames(t, 30);
  expect(t.takeException(), isNull);
  expect(t.binding.hasScheduledFrame, isFalse);
}

// Activate the real recognizer, then move to an exact *indicator* distance.
// This removes touch-slop differences without replacing the scroll physics.
Future<TestGesture> dragTo(
  WidgetTester t,
  SecondaryHarnessState s,
  double offset,
) async {
  final g = await t.startGesture(const Offset(300, 450));
  await g.moveBy(const Offset(0, -24));
  await t.pump();
  await g.moveBy(Offset(0, offset - s.indicator!.offset));
  await t.pump();
  expect(s.indicator!.offset, closeTo(offset, .001));
  expect(s.scroll.offset, 0);
  return g;
}

void main() {
  testWidgets('auto-detected nested animation survives a parent rebuild', (
    t,
  ) async {
    final s = await mount(t, LayoutKind.legacy, clamping: false);
    final g = await dragTo(t, s, 450);
    await g.up();
    await frames(t, 2);
    await t.pumpWidget(
      SecondaryHarness(
        key: s.widget.key,
        layout: LayoutKind.legacy,
        clamping: false,
      ),
    );
    await frames(t);
    expect(s.indicator!.offset, 0);
    expect(s.indicator!.mode, IndicatorMode.inactive);
    await disposeHarness(t);
  });
  for (final layout in LayoutKind.values) {
    for (final clamping in [true, false]) {
      testWidgets('$layout clamping=$clamping controller close animates', (
        t,
      ) async {
        final s = await mount(t, layout, clamping: clamping);
        final closing = s.controller.closeHeaderSecondary();
        expect(s.indicator!.offset, 600);
        await t.pump();
        await t.pump(const Duration(milliseconds: 100));
        final midway = s.indicator!.offset;
        expect(midway, greaterThan(0));
        expect(midway, lessThan(600));
        expect(s.indicator!.mode, IndicatorMode.secondaryClosing);
        await frames(t);
        await closing;
        expect(s.indicator!.offset, 0);
        expect(s.indicator!.mode, IndicatorMode.inactive);
        expect(s.refreshes, 0);
        await disposeHarness(t);
      });
    }
    testWidgets('$layout fast close does not fling the main list', (t) async {
      final s = await mount(t, layout);
      await t.flingFrom(const Offset(300, 550), const Offset(0, -900), 2400);
      await frames(t);
      expect(s.indicator!.offset, 0);
      expect(s.indicator!.mode, IndicatorMode.inactive);
      expect(s.scroll.offset, 0);
      expect(s.refreshes, 0);
      await disposeHarness(t);
    });
    for (final clamping in [true, false]) {
      testWidgets('$layout clamping=$clamping closes and refreshes once', (
        t,
      ) async {
        final s = await mount(t, layout, clamping: clamping);
        final oldBuilds = s.builds;
        await frames(t, 60);
        expect(s.builds, oldBuilds);
        await swipe(t, const Offset(300, 450), const Offset(0, -330));
        expect(s.indicator!.mode, IndicatorMode.inactive);
        expect(s.indicator!.offset, 0);
        expect(s.scroll.offset, closeTo(0, .001));
        expect(s.modes, contains(IndicatorMode.secondaryClosing.name));
        await swipe(t, const Offset(300, 200), const Offset(0, 210));
        expect(s.refreshes, 1);
        s.finish();
        await frames(t);
        expect(s.indicator!.mode, IndicatorMode.inactive);
        expect(s.indicator!.offset, 0);
        await disposeHarness(t);
      });
    }
    for (final distance in [0.0, 69.0, 70.0, 71.0]) {
      testWidgets('$layout secondary close distance $distance', (t) async {
        final s = await mount(t, layout);
        if (distance == 0) {
          await t.tapAt(const Offset(300, 350));
        } else {
          final g = await dragTo(t, s, 600 - distance);
          await g.up();
          await t.pump();
          await t.pump(const Duration(milliseconds: 16));
          expect(s.indicator!.offset, greaterThan(0));
          expect(s.indicator!.offset, lessThan(600));
        }
        await frames(t);
        expect(s.indicator!.offset, distance < 70 ? 600 : 0);
        expect(
          s.indicator!.mode,
          distance < 70 ? IndicatorMode.secondaryOpen : IndicatorMode.inactive,
        );
        expect(s.scroll.offset, 0);
        expect(s.refreshes, 0);
        await disposeHarness(t);
      });
    }
    testWidgets('$layout reverse a closing drag and keep ownership at zero', (
      t,
    ) async {
      final s = await mount(t, layout);
      final g = await dragTo(t, s, 500);
      expect(s.indicator!.mode, IndicatorMode.secondaryClosing);
      await g.moveBy(const Offset(0, 80));
      await t.pump();
      expect(s.indicator!.offset, 580);
      expect(s.indicator!.mode, IndicatorMode.secondaryOpen);
      await g.up();
      await frames(t);
      expect(s.indicator!.offset, 600);
      final close = await dragTo(t, s, 0);
      await close.moveBy(const Offset(0, -100));
      await t.pump();
      await close.moveBy(const Offset(0, 200));
      await t.pump();
      expect(s.indicator!.offset, 0);
      expect(s.indicator!.mode, IndicatorMode.inactive);
      expect(s.scroll.offset, 0);
      expect(s.refreshes, 0);
      await close.up();
      await frames(t);
      await disposeHarness(t);
    });
    for (final reopening in [true, false]) {
      testWidgets(
        '$layout interrupted ${reopening ? 'reopening' : 'closing'}',
        (t) async {
          final s = await mount(t, layout);
          final g = await dragTo(t, s, reopening ? 560 : 450);
          await g.up();
          await frames(t, 2);
          for (var i = 0; i < 4; i++) {
            await t.tapAt(const Offset(300, 350));
            await frames(t, 1);
          }
          // A fresh drag must interrupt and reverse the animation.
          final drag = await t.startGesture(const Offset(300, 350));
          await drag.moveBy(const Offset(0, 24));
          await t.pump();
          final target = reopening ? 450.0 : 590.0;
          await drag.moveBy(Offset(0, target - s.indicator!.offset));
          await t.pump();
          expect(s.indicator!.offset, closeTo(target, .001));
          await drag.up();
          await frames(t);
          expect(s.indicator!.offset, reopening ? 0 : 600);
          expect(s.scroll.offset, 0);
          expect(s.refreshes, 0);
          await disposeHarness(t);
        },
      );
    }
    testWidgets('$layout controller close and repeated cycles on both tabs', (
      t,
    ) async {
      final s = await mount(t, layout);
      for (var i = 0; i < 5; i++) {
        if (i > 0) {
          await swipe(t, const Offset(300, 180), const Offset(0, 360));
          expect(
            s.indicator!.mode,
            IndicatorMode.secondaryOpen,
            reason: 'cycle $i, offset ${s.indicator!.offset}, modes ${s.modes}',
          );
        }
        final close = s.controller.closeHeaderSecondary();
        await frames(t);
        await close;
        expect(s.indicator!.offset, 0);
        if (layout != LayoutKind.plain) {
          await t.tap(find.text(i.isEven ? '列表二' : '列表一'));
          await frames(t);
        }
      }
      expect(s.refreshes, 0);
      await disposeHarness(t);
    });
  }
  for (final layout in [LayoutKind.explicit, LayoutKind.recipe]) {
    testWidgets('$layout controller opens and closes on both tabs', (t) async {
      final s = await mount(t, layout);
      for (var i = 0; i < 2; i++) {
        final close = s.controller.closeHeaderSecondary();
        await frames(t);
        await close;
        expect(s.indicator!.offset, 0);
        await t.tap(find.text(i.isEven ? '列表二' : '列表一'));
        await frames(t);
        final open = s.controller.openHeaderSecondary();
        await frames(t);
        await open;
        expect(s.indicator!.mode, IndicatorMode.secondaryOpen);
        expect(s.indicator!.offset, 600);
      }
      expect(s.refreshes, 0);
      await disposeHarness(t);
    });
  }
  for (final layout in [
    LayoutKind.legacy,
    LayoutKind.explicit,
    LayoutKind.recipe,
  ]) {
    testWidgets('$layout updates one Header with two retained tabs', (t) async {
      final s = await mount(t, layout);
      final close = s.controller.closeHeaderSecondary();
      await frames(t);
      await close;
      await t.tap(find.text('列表二'));
      await frames(t);
      final nested = t.state<NestedScrollViewState>(
        find.byType(NestedScrollView),
      );
      expect(nested.innerController.positions.length, 2);
      await swipe(t, const Offset(300, 180), const Offset(0, 360));
      final g = await dragTo(t, s, 550);
      await g.moveBy(const Offset(0, -20));
      await t.pump();
      expect(
        s.indicator!.offset,
        530,
        reason: 'One delta must not update each retained tab',
      );
      for (final position in nested.innerController.positions) {
        expect(position.pixels, 0);
      }
      await g.up();
      await frames(t);
      expect(s.indicator!.mode, IndicatorMode.inactive);
      expect(s.scroll.offset, 0);
      await disposeHarness(t);
    });
  }
  for (final distance in [30.0, 70.0, 150.0]) {
    testWidgets('clamping Footer closes symmetrically at $distance', (t) async {
      final c = EasyRefreshController();
      final scroll = ScrollController();
      final state = IndicatorStateListenable();
      var loads = 0;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EasyRefresh(
              controller: c,
              scrollController: scroll,
              footer: BuilderFooter(
                triggerOffset: 70,
                clamping: true,
                infiniteOffset: null,
                safeArea: false,
                secondaryTriggerOffset: 120,
                secondaryDimension: 200,
                listenable: state,
                builder: (_, s) => SizedBox(height: s.offset),
              ),
              onLoad: () {
                loads++;
              },
              child: ListView.builder(
                controller: scroll,
                itemExtent: 50,
                itemCount: 60,
                itemBuilder: (_, i) => Text('Item $i'),
              ),
            ),
          ),
        ),
      );
      await frames(t, 10);
      scroll.jumpTo(scroll.position.maxScrollExtent);
      await frames(t);
      final opening = c.openFooterSecondary();
      await frames(t);
      await opening;
      expect(state.value!.mode, IndicatorMode.secondaryOpen);
      final g = await t.startGesture(const Offset(300, 200));
      await g.moveBy(const Offset(0, 24));
      await t.pump();
      await g.moveBy(Offset(0, state.value!.offset - (200 - distance)));
      await t.pump();
      expect(state.value!.offset, closeTo(200 - distance, .001));
      await g.up();
      await frames(t);
      expect(state.value!.offset, distance < 70 ? 200 : 0);
      expect(
        state.value!.mode,
        distance < 70 ? IndicatorMode.secondaryOpen : IndicatorMode.inactive,
      );
      expect(loads, 0);
      if (distance < 70) {
        final closing = c.closeFooterSecondary();
        expect(state.value!.offset, 200);
        await t.pump();
        await t.pump(const Duration(milliseconds: 100));
        expect(state.value!.offset, greaterThan(0));
        expect(state.value!.offset, lessThan(200));
        expect(state.value!.mode, IndicatorMode.secondaryClosing);
        await frames(t);
        await closing;
        expect(state.value!.offset, 0);
        expect(state.value!.mode, IndicatorMode.inactive);
        expect(loads, 0);
      }
      await disposeHarness(t);
      c.dispose();
      scroll.dispose();
    });
  }
}
