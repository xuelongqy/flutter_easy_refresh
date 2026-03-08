import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'footer immediately rebuilds after processed->done/inactive when processedDuration is zero',
      (WidgetTester tester) async {
    final loadCompleter = Completer<void>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EasyRefresh(
            footer: BuilderFooter(
              triggerOffset: 70,
              clamping: false,
              processedDuration: Duration.zero,
              infiniteOffset: 70,
              builder: (context, state) => Text(
                'footer:${state.mode.name}',
                key: const Key('footer-mode'),
              ),
            ),
            onLoad: () => loadCompleter.future,
            child: ListView.builder(
              itemExtent: 50,
              itemCount: 200,
              itemBuilder: (context, index) => Text('Item $index'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Item 199'),
      500,
      scrollable: find.byType(Scrollable),
    );
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byKey(const Key('footer-mode')), findsOneWidget);
    expect(find.textContaining('footer:processing'), findsOneWidget);

    loadCompleter.complete();
    await tester.pump();

    expect(find.textContaining('footer:processed'), findsOneWidget);

    // Post-frame callback from `IndicatorNotifier._setMode(processed)` should
    // transition to done/inactive and rebuild without needing any extra scroll.
    await tester.pump();
    expect(find.textContaining('footer:inactive'), findsOneWidget);
  });
}
