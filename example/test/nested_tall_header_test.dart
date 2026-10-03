import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:example/page/sample/test_page.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

enum _Recipe { nested, builder, extended, perList }

class _TallNestedFixture extends StatelessWidget {
  const _TallNestedFixture({
    required this.recipe,
    required this.height,
    required this.items,
    required this.header,
    required this.onRefresh,
  });

  final _Recipe recipe;
  final double height;
  final int items;
  final IndicatorStateListenable header;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final indicator = BuilderHeader(
      triggerOffset: 70,
      clamping: true,
      position: IndicatorPosition.locator,
      processedDuration: Duration.zero,
      listenable: header,
      builder: (context, state) => SizedBox(height: state.offset),
    );
    List<Widget> slivers(BuildContext context, bool scrolled) => [
      if (recipe != _Recipe.nested && recipe != _Recipe.perList)
        const HeaderLocator.sliver(),
      SliverAppBar(
        pinned: true,
        expandedHeight: height,
        flexibleSpace: const FlexibleSpaceBar(title: Text('Tall header')),
      ),
    ];
    Widget body([ScrollPhysics? physics]) => ListView.builder(
      physics: physics,
      itemExtent: 64,
      itemCount: items,
      itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
    );
    final perListBody = EasyRefresh.builder(
      isNested: true,
      header: indicator,
      onRefresh: onRefresh,
      childBuilder: (context, physics) => CustomScrollView(
        physics: physics,
        slivers: [
          const HeaderLocator.sliver(clearExtent: false),
          SliverFixedExtentList(
            itemExtent: 64,
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(title: Text('Item $index')),
              childCount: items,
            ),
          ),
        ],
      ),
    );
    final refresh = recipe == _Recipe.nested
        ? EasyRefresh.nested(
            header: indicator,
            onRefresh: onRefresh,
            headerSliverBuilder: slivers,
            body: body(),
          )
        : EasyRefresh.builder(
            isNested: true,
            header: recipe == _Recipe.perList ? null : indicator,
            onRefresh: recipe == _Recipe.perList ? null : onRefresh,
            childBuilder: (context, physics) =>
                recipe == _Recipe.extended || recipe == _Recipe.perList
                ? ExtendedNestedScrollView(
                    physics: physics,
                    headerSliverBuilder: slivers,
                    body: recipe == _Recipe.perList
                        ? perListBody
                        : body(physics),
                  )
                : NestedScrollView(
                    physics: physics,
                    headerSliverBuilder: slivers,
                    body: body(physics),
                  ),
          );
    return MaterialApp(home: Scaffold(body: refresh));
  }
}

Future<void> _drag(WidgetTester tester, Offset start, double distance) async {
  final gesture = await tester.startGesture(start);
  for (var i = 0; i < 12; i++) {
    await gesture.moveBy(Offset(0, distance / 12));
    await tester.pump(const Duration(milliseconds: 16));
  }
  await tester.pump(const Duration(milliseconds: 150));
  await gesture.up();
  for (var i = 0; i < 125; i++) {
    await tester.pump(const Duration(milliseconds: 20));
  }
}

IndicatorStateListenable _pageHeader(WidgetTester tester) => tester
    .widgetList<EasyRefresh>(find.byType(EasyRefresh, skipOffstage: false))
    .firstWhere((refresh) => refresh.onRefresh != null)
    .header!
    .listenable!;

Future<void> _checkPageHeaderBinding(WidgetTester tester) async {
  final header = _pageHeader(tester);
  final gesture = await tester.startGesture(const Offset(190, 350));
  for (var i = 0; i < 3; i++) {
    await gesture.moveBy(const Offset(0, 20));
    await tester.pump(const Duration(milliseconds: 16));
  }
  expect(header.value, isNotNull);
  expect(header.value!.mode, IndicatorMode.drag);
  expect(header.value!.offset, greaterThan(0));
  expect(
    find.textContaining('Header: drag ·'),
    findsOneWidget,
    reason: 'The panel must observe the active Header after reconfiguration',
  );
  await tester.pump(const Duration(milliseconds: 150));
  await gesture.up();
  await tester.pumpAndSettle();
}

void main() {
  for (final recipe in _Recipe.values) {
    testWidgets('manual test page ${recipe.name} tall collapsed refresh', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(393, 852));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const MaterialApp(home: TestPage()));
      await tester.pumpAndSettle();
      if (recipe != _Recipe.nested) {
        final label = switch (recipe) {
          _Recipe.builder => 'Builder + Nested',
          _Recipe.extended => 'Builder + Extended',
          _Recipe.perList => 'Extended + list Header',
          _Recipe.nested => 'EasyRefresh.nested',
        };
        await tester.tap(find.text('EasyRefresh.nested'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(label).last);
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byType(DropdownButton<double>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('1600 px').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      await _checkPageHeaderBinding(tester);
      await tester.tap(find.text('Collapse'));
      await tester.pumpAndSettle();
      await _drag(tester, const Offset(190, 350), 180);
      expect(find.textContaining('Refresh count: 0'), findsOneWidget);
      for (var i = 0; i < 8; i++) {
        if (find.textContaining('Refresh count: 1').evaluate().isNotEmpty) {
          break;
        }
        await _drag(tester, const Offset(190, 350), 320);
      }
      expect(find.textContaining('Refresh count: 1'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.textContaining('Header: inactive · 0.0 px'), findsOneWidget);
      expect(_pageHeader(tester).value!.mode, IndicatorMode.inactive);
      expect(_pageHeader(tester).value!.offset, 0);
      await tester.tap(find.byTooltip('Reset test'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Refresh count: 0 · Outer: 0 px'),
        findsOneWidget,
      );
      await _checkPageHeaderBinding(tester);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 1));
    });
  }
  for (final recipe in _Recipe.values) {
    for (final height in [200.0, 600.0, 1000.0, 1600.0]) {
      for (final items in [1, 30]) {
        for (final collapsed in [false, true]) {
          final label =
              '${recipe.name} h=$height items=$items '
              '${collapsed ? 'collapsed then repeated pulls' : 'expanded pull'}';
          testWidgets(label, (tester) async {
            await tester.binding.setSurfaceSize(const Size(393, 852));
            addTearDown(() => tester.binding.setSurfaceSize(null));
            final header = IndicatorStateListenable();
            final task = Completer<void>();
            var calls = 0;
            addTearDown(() async {
              if (!task.isCompleted) task.complete();
              for (var i = 0; i < 60; i++) {
                await tester.pump(const Duration(milliseconds: 20));
              }
              await tester.pumpWidget(const SizedBox.shrink());
              await tester.pump(const Duration(seconds: 1));
            });
            await tester.pumpWidget(
              _TallNestedFixture(
                recipe: recipe,
                height: height,
                items: items,
                header: header,
                onRefresh: () {
                  calls++;
                  return task.future;
                },
              ),
            );
            await tester.pumpAndSettle();

            final ScrollController outer;
            final ScrollController inner;
            if (recipe == _Recipe.extended || recipe == _Recipe.perList) {
              final state = tester.state<ExtendedNestedScrollViewState>(
                find.byType(ExtendedNestedScrollView),
              );
              outer = state.outerController;
              inner = state.innerController;
            } else {
              final state = tester.state<NestedScrollViewState>(
                find.byType(NestedScrollView),
              );
              outer = state.outerController;
              inner = state.innerController;
            }
            if (collapsed) {
              outer.jumpTo(outer.position.maxScrollExtent);
              inner.jumpTo(inner.position.minScrollExtent);
              await tester.pumpAndSettle();
              if (height >= 600) {
                await _drag(tester, const Offset(190, 250), 180);
                expect(
                  calls,
                  0,
                  reason: 'Re-expanding a tall AppBar is not overscroll',
                );
                expect(header.value?.offset ?? 0, 0);
              }
            }
            final attempts = collapsed ? 8 : 1;
            for (var i = 0; i < attempts && calls == 0; i++) {
              await _drag(tester, Offset(190, collapsed ? 250 : 130), 320);
            }
            expect(tester.takeException(), isNull);
            expect(calls, 1);
            expect(header.value?.mode, IndicatorMode.processing);
          });
        }
      }
    }
  }
}
