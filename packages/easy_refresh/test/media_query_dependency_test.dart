import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('a keyboard inset change does not rebuild EasyRefresh', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    var builds = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: EasyRefresh.builder(
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

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();
    expect(builds, settled);

    tester.view.padding = const FakeViewPadding(top: 40);
    await tester.pumpAndSettle();
    expect(builds, greaterThan(settled));
  });
}
