import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('media query changes reach the indicators, not EasyRefresh', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    var builds = 0;
    double? safeOffset;
    await tester.pumpWidget(
      MaterialApp(
        home: EasyRefresh.builder(
          header: BuilderHeader(
            triggerOffset: 70,
            clamping: false,
            position: IndicatorPosition.above,
            builder: (context, state) {
              safeOffset = state.safeOffset;
              return const SizedBox();
            },
          ),
          onRefresh: () async {},
          onLoad: () async {},
          childBuilder: (context, physics) {
            builds++;
            return ListView.builder(
              physics: physics,
              itemExtent: 50,
              itemCount: 40,
              itemBuilder: (context, index) => Text('Item $index'),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    final settled = builds;
    expect(safeOffset, 0);

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();
    expect(builds, settled);

    tester.view.padding = FakeViewPadding(
      top: 40 * tester.view.devicePixelRatio,
    );
    await tester.pumpAndSettle();
    expect(builds, settled);
    expect(safeOffset, 40);
  });
}
