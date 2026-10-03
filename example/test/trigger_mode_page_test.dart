import 'package:easy_refresh/easy_refresh.dart';
import 'package:example/page/sample/trigger_mode_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('trigger mode sample exposes Header and Footer modes', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: TriggerModePage()));
    await tester.pumpAndSettle();

    var refresh = tester.widget<EasyRefresh>(find.byType(EasyRefresh));
    expect((refresh.header as ClassicHeader), isNotNull);
    expect(refresh.footer, isA<ClassicFooter>());
    expect(find.byType(Switch), findsNWidgets(2));
    expect(find.text('Refresh count: 0'), findsOneWidget);
    expect(find.textContaining('Load count: 0'), findsOneWidget);

    await tester.tap(find.byTooltip('Trigger mode help'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      find.textContaining('Trigger mode test instruction'),
      findsOneWidget,
    );
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch).at(0));
    await tester.tap(find.byType(Switch).at(1));
    await tester.pump();
    refresh = tester.widget<EasyRefresh>(find.byType(EasyRefresh));
    expect(refresh.header, isA<ClassicHeader>());

    await tester.drag(find.byType(ListView), const Offset(0, 180));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.text('Refresh count: 1'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
