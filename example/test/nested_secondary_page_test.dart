import 'package:easy_refresh/easy_refresh.dart';
import 'package:example/page/sample/nested_secondary_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<void> pumpFrames(WidgetTester tester, [int count = 150]) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  testWidgets(
    'nested secondary example opens, closes, refreshes and handles back',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(430, 932);
      tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const NestedSecondaryPage(),
                    ),
                  ),
                  child: const Text('Open sample'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open sample'));
      await pumpFrames(tester);
      final refresh = tester.widget<EasyRefresh>(find.byType(EasyRefresh));
      final listenable = refresh.header!.listenable!;
      Future<void> pull(double target) async {
        final gesture = await tester.startGesture(const Offset(200, 180));
        for (
          var i = 0;
          i < 65 && (listenable.value?.offset ?? 0) < target;
          i++
        ) {
          await gesture.moveBy(const Offset(0, 10));
          await tester.pump(const Duration(milliseconds: 16));
        }
        expect(listenable.value!.offset, greaterThanOrEqualTo(target));
        await gesture.up();
        await pumpFrames(tester);
      }

      await pull(200);
      expect(listenable.value!.mode, IndicatorMode.secondaryOpen);
      expect(find.text('Welcome upstairs'), findsOneWidget);
      // A gesture closes the second floor without collapsing the main AppBar.
      await tester.dragFrom(const Offset(200, 650), const Offset(0, -180));
      await pumpFrames(tester);
      expect(listenable.value!.mode, IndicatorMode.inactive);
      expect(listenable.value!.offset, 0);
      await pull(145);
      expect(find.text('Refresh count: 1'), findsOneWidget);
      expect(listenable.value!.mode, IndicatorMode.inactive);
      await tester.tap(find.text('Grid'));
      await pumpFrames(tester);
      await pull(200);
      await tester.tap(find.byKey(const Key('nested-secondary-close')));
      await pumpFrames(tester);
      expect(listenable.value!.offset, 0);
      await pull(200);
      await tester.binding.handlePopRoute();
      await pumpFrames(tester);
      expect(find.byType(NestedSecondaryPage), findsOneWidget);
      expect(listenable.value!.mode, IndicatorMode.inactive);
      await tester.binding.handlePopRoute();
      await pumpFrames(tester);
      expect(find.byType(NestedSecondaryPage), findsNothing);
      expect(tester.takeException(), isNull);
      expect(tester.binding.hasScheduledFrame, isFalse);
      await tester.pumpWidget(const SizedBox.shrink());
      await pumpFrames(tester, 30);
    },
  );
}
