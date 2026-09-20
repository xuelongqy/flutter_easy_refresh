import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:example/page/sample/secondary_page.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<void> pumpSecondaryFrames(WidgetTester tester, [int count = 90]) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  testWidgets('secondary toolbar owns taps and restores the main toolbar', (
    tester,
  ) async {
    // Keep the decorative Rive background loading: hit testing should not
    // require a native renderer. The actual animation is checked on iOS.
    final asset = Completer<ByteData?>();
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMessageHandler('flutter/assets', (message) {
      if (const StringCodec().decodeMessage(message) ==
          'assets/rive/machine-game.riv') {
        return asset.future;
      }
      return messenger.delegate.send('flutter/assets', message);
    });
    addTearDown(() => messenger.setMockMessageHandler('flutter/assets', null));
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 932);
    tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SecondaryPage()),
              ),
              child: const Text('Open sample'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open sample'));
    await pumpSecondaryFrames(tester);
    final refresh = tester.widget<EasyRefresh>(find.byType(EasyRefresh));
    final header = refresh.header!.listenable!;
    final open = find.byKey(const Key('secondary-open'));

    for (final closeKey in ['secondary-close', 'secondary-back']) {
      expect(open.hitTestable(), findsOneWidget);
      await tester.tap(open);
      await pumpSecondaryFrames(tester);
      expect(header.value!.mode, IndicatorMode.secondaryOpen);
      expect(open.hitTestable(), findsNothing);
      final close = find.byKey(Key(closeKey));
      expect(close.hitTestable(), findsOneWidget);
      // A physical pointer tap must reach the foreground toolbar, rather than
      // invoking its callback directly or using an accessibility action.
      final before = header.value!.offset;
      await tester.tapAt(tester.getCenter(close));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(header.value!.offset, greaterThan(0));
      expect(header.value!.offset, lessThan(before));
      await pumpSecondaryFrames(tester);
      expect(header.value!.mode, IndicatorMode.inactive);
      expect(find.byType(SecondaryPage), findsOneWidget);
      expect(find.byKey(const Key('secondary-app-bar')), findsNothing);
    }

    // Only the toolbar is overlaid; body drags still reach EasyRefresh.
    await tester.tap(open);
    await pumpSecondaryFrames(tester);
    await tester.dragFrom(const Offset(200, 600), const Offset(0, -240));
    await pumpSecondaryFrames(tester);
    expect(header.value!.mode, IndicatorMode.inactive);
    expect(header.value!.offset, 0);

    // Once closed, the underlying main AppBar's back button pops the route.
    await tester.tap(find.byType(BackButton));
    await pumpSecondaryFrames(tester);
    expect(find.byType(SecondaryPage), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await pumpSecondaryFrames(tester, 10);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}
