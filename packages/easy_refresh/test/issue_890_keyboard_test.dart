import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pumpFrames(WidgetTester tester, [int count = 40]) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  testWidgets('builder preserves infinite footer across keyboard route pop', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(tester.view.reset);
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    final navigator = GlobalKey<NavigatorState>();
    final controller = EasyRefreshController();
    final scrollController = ScrollController();
    addTearDown(controller.dispose);
    addTearDown(scrollController.dispose);
    var loadCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        home: Scaffold(
          body: EasyRefresh.builder(
            controller: controller,
            scrollController: scrollController,
            footer: const ClassicFooter(safeArea: false),
            onLoad: () async {
              loadCalls++;
              return IndicatorResult.noMore;
            },
            childBuilder: (context, physics) => ListView.builder(
              key: const Key('source-list'),
              controller: scrollController,
              physics: physics,
              itemExtent: 50,
              itemCount: 60,
              itemBuilder: (context, index) => Text('Item $index'),
            ),
          ),
        ),
      ),
    );
    await _pumpFrames(tester, 5);

    scrollController.jumpTo(scrollController.position.maxScrollExtent);
    await tester.pump();
    await tester.drag(
      find.byKey(const Key('source-list')),
      const Offset(0, -200),
    );
    await _pumpFrames(tester, 80);

    expect(loadCalls, 1);
    expect(controller.footerState!.offset, closeTo(70, 0.001));
    expect(
      scrollController.position.pixels,
      closeTo(scrollController.position.maxScrollExtent + 70, 0.001),
    );

    navigator.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) =>
            const Scaffold(body: TextField(key: Key('keyboard-field'))),
      ),
    );
    await _pumpFrames(tester);
    await tester.tap(find.byKey(const Key('keyboard-field')));
    await tester.pump();

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await _pumpFrames(tester);
    expect(controller.footerState!.offset, 0);

    navigator.currentState!.pop();
    await _pumpFrames(tester, 10);
    tester.view.viewInsets = FakeViewPadding.zero;
    await _pumpFrames(tester, 100);

    expect(loadCalls, 1);
    expect(controller.footerState!.offset, closeTo(70, 0.001));
    expect(
      scrollController.position.pixels,
      closeTo(scrollController.position.maxScrollExtent + 70, 0.001),
    );
    debugDefaultTargetPlatformOverride = null;
    expect(tester.takeException(), isNull);
  });
}
