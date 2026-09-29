import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _flushTimers(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 1));
  await tester.pump(const Duration(milliseconds: 1));
}

Widget _buildRefresh() {
  return MaterialApp(
    home: EasyRefresh(
      onRefresh: () async {},
      child: ListView(
        key: const Key('list'),
        children: const [SizedBox(key: Key('content'), height: 2000)],
      ),
    ),
  );
}

void main() {
  LeakTesting.enable();

  testWidgets(
    '#916 dispose without scrolling does not leak ballistic state',
    experimentalLeakTesting: LeakTesting.settings,
    (tester) async {
      await tester.pumpWidget(_buildRefresh());
      await _flushTimers(tester);

      await tester.pumpWidget(const SizedBox.shrink());
      await _flushTimers(tester);

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    '#916 dispose after scrolling does not leak ballistic state',
    experimentalLeakTesting: LeakTesting.settings,
    (tester) async {
      await tester.pumpWidget(_buildRefresh());
      await _flushTimers(tester);

      final before = tester.getTopLeft(find.byKey(const Key('content'))).dy;
      await tester.drag(find.byKey(const Key('list')), const Offset(0, -200));
      await tester.pump(const Duration(milliseconds: 500));
      final after = tester.getTopLeft(find.byKey(const Key('content'))).dy;
      expect(after, lessThan(before));

      await tester.pumpWidget(const SizedBox.shrink());
      await _flushTimers(tester);

      expect(tester.takeException(), isNull);
    },
  );
}
