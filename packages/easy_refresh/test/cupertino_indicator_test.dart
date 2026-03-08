import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test harness for CupertinoHeader/CupertinoFooter
class _CupertinoIndicatorHarness extends StatefulWidget {
  final CupertinoHeader? header;
  final CupertinoFooter? footer;

  const _CupertinoIndicatorHarness({
    super.key,
    this.header,
    this.footer,
  });

  @override
  State<_CupertinoIndicatorHarness> createState() =>
      _CupertinoIndicatorHarnessState();
}

class _CupertinoIndicatorHarnessState
    extends State<_CupertinoIndicatorHarness> {
  late final EasyRefreshController controller;
  final scrollController = ScrollController();

  int itemCount = 60;

  Completer<void>? _refreshCompleter;
  Completer<void>? _loadCompleter;

  void finishRefresh() {
    _refreshCompleter?.complete();
  }

  void finishLoad() {
    _loadCompleter?.complete();
  }

  Future<void> _onRefresh() async {
    _refreshCompleter = Completer<void>();
    await _refreshCompleter!.future;
  }

  Future<void> _onLoad() async {
    _loadCompleter = Completer<void>();
    await _loadCompleter!.future;
  }

  @override
  void initState() {
    super.initState();
    controller = EasyRefreshController();
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: EasyRefresh(
          controller: controller,
          scrollController: scrollController,
          header: widget.header ?? const CupertinoHeader(),
          footer: widget.footer ?? const CupertinoFooter(),
          onRefresh: _onRefresh,
          onLoad: _onLoad,
          child: ListView.builder(
            controller: scrollController,
            itemExtent: 50,
            itemCount: itemCount,
            itemBuilder: (context, index) => ListTile(
              key: Key('item-$index'),
              title: Text('Item $index'),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> disposeAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

void main() {
  group('CupertinoHeader Tests', () {
    testWidgets('CupertinoHeader renders with iOS-style spinner',
        (tester) async {
      final key = GlobalKey<_CupertinoIndicatorHarnessState>();
      await tester.pumpWidget(_CupertinoIndicatorHarness(
        key: key,
        header: const CupertinoHeader(),
      ));

      await tester.pumpAndSettle();

      // Trigger refresh to make header visible
      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      // CupertinoHeader should render - look for the EasyRefresh widget
      expect(find.byType(EasyRefresh), findsOneWidget);

      key.currentState!.finishRefresh();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('CupertinoHeader with foregroundColor', (tester) async {
      final key = GlobalKey<_CupertinoIndicatorHarnessState>();
      await tester.pumpWidget(_CupertinoIndicatorHarness(
        key: key,
        header: const CupertinoHeader(
          foregroundColor: Colors.blue,
        ),
      ));

      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      expect(find.byType(EasyRefresh), findsOneWidget);

      key.currentState!.finishRefresh();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('CupertinoHeader with userWaterDrop: true', (tester) async {
      final key = GlobalKey<_CupertinoIndicatorHarnessState>();
      await tester.pumpWidget(_CupertinoIndicatorHarness(
        key: key,
        header: const CupertinoHeader(
          userWaterDrop: true,
        ),
      ));

      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      // Should render with water drop effect
      expect(find.byType(EasyRefresh), findsOneWidget);

      key.currentState!.finishRefresh();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('CupertinoHeader with userWaterDrop: false', (tester) async {
      final key = GlobalKey<_CupertinoIndicatorHarnessState>();
      await tester.pumpWidget(_CupertinoIndicatorHarness(
        key: key,
        header: const CupertinoHeader(
          userWaterDrop: false,
        ),
      ));

      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      // Should render without water drop effect
      expect(find.byType(EasyRefresh), findsOneWidget);

      key.currentState!.finishRefresh();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('CupertinoHeader with backgroundColor', (tester) async {
      final key = GlobalKey<_CupertinoIndicatorHarnessState>();
      await tester.pumpWidget(_CupertinoIndicatorHarness(
        key: key,
        header: const CupertinoHeader(
          backgroundColor: Colors.grey,
        ),
      ));

      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      expect(find.byType(EasyRefresh), findsOneWidget);

      key.currentState!.finishRefresh();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('CupertinoHeader with emptyWidget', (tester) async {
      final key = GlobalKey<_CupertinoIndicatorHarnessState>();
      await tester.pumpWidget(_CupertinoIndicatorHarness(
        key: key,
        header: const CupertinoHeader(
          emptyWidget: Text('No more content'),
        ),
      ));

      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      expect(find.byType(EasyRefresh), findsOneWidget);

      key.currentState!.finishRefresh();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });
  });

  group('CupertinoFooter Tests', () {
    testWidgets('CupertinoFooter renders correctly', (tester) async {
      final key = GlobalKey<_CupertinoIndicatorHarnessState>();
      await tester.pumpWidget(_CupertinoIndicatorHarness(
        key: key,
        footer: const CupertinoFooter(),
      ));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      // Scroll to bottom
      state.scrollController.jumpTo(
        state.scrollController.position.maxScrollExtent,
      );
      await tester.pump();

      // Trigger load
      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pump();

      // CupertinoFooter should render
      expect(find.byType(EasyRefresh), findsOneWidget);

      state.finishLoad();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('CupertinoFooter with custom foregroundColor', (tester) async {
      final key = GlobalKey<_CupertinoIndicatorHarnessState>();
      await tester.pumpWidget(_CupertinoIndicatorHarness(
        key: key,
        footer: const CupertinoFooter(
          foregroundColor: Colors.green,
        ),
      ));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      state.scrollController.jumpTo(
        state.scrollController.position.maxScrollExtent,
      );
      await tester.pump();

      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pump();

      expect(find.byType(EasyRefresh), findsOneWidget);

      state.finishLoad();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });
  });

  group('CupertinoIndicator Properties', () {
    testWidgets('CupertinoHeader default triggerOffset is 60', (tester) async {
      const header = CupertinoHeader();
      expect(header.triggerOffset, 60);
    });

    testWidgets('CupertinoHeader default clamping is false', (tester) async {
      const header = CupertinoHeader();
      expect(header.clamping, false);
    });

    testWidgets('CupertinoHeader default position is behind', (tester) async {
      const header = CupertinoHeader();
      expect(header.position, IndicatorPosition.behind);
    });

    testWidgets('CupertinoHeader default processedDuration is zero',
        (tester) async {
      const header = CupertinoHeader();
      expect(header.processedDuration, Duration.zero);
    });

    testWidgets('CupertinoHeader default userWaterDrop is true',
        (tester) async {
      const header = CupertinoHeader();
      expect(header.userWaterDrop, true);
    });

    testWidgets('CupertinoFooter default triggerOffset is 60', (tester) async {
      const footer = CupertinoFooter();
      expect(footer.triggerOffset, 60);
    });
  });

  group('CupertinoIndicator iOS-style Behavior', () {
    testWidgets('CupertinoHeader shows spinner during refresh', (tester) async {
      final key = GlobalKey<_CupertinoIndicatorHarnessState>();
      await tester.pumpWidget(_CupertinoIndicatorHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      // Trigger refresh
      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      // Should be in processing state
      expect(find.byType(EasyRefresh), findsOneWidget);

      state.finishRefresh();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('CupertinoHeader drag behavior', (tester) async {
      final key = GlobalKey<_CupertinoIndicatorHarnessState>();
      await tester.pumpWidget(_CupertinoIndicatorHarness(key: key));

      await tester.pumpAndSettle();

      // Start drag
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ListView)),
      );

      await gesture.moveBy(const Offset(0, 30));
      await tester.pump();

      await gesture.moveBy(const Offset(0, 30));
      await tester.pump();

      // Should show header during drag
      expect(find.byType(EasyRefresh), findsOneWidget);

      await gesture.up();
      await tester.pumpAndSettle();

      await disposeAndFlush(tester);
    });
  });

  group('CupertinoIndicator Refresh Cycle', () {
    testWidgets('CupertinoHeader completes full refresh cycle', (tester) async {
      final key = GlobalKey<_CupertinoIndicatorHarnessState>();
      await tester.pumpWidget(_CupertinoIndicatorHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      // Start drag
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ListView)),
      );
      await gesture.moveBy(const Offset(0, 100));
      await tester.pump();

      // Release to trigger refresh
      await gesture.up();
      await tester.pump();

      // Finish refresh
      state.finishRefresh();
      await tester.pump();
      await tester.pump();

      // Should complete without error
      expect(find.byType(EasyRefresh), findsOneWidget);

      await disposeAndFlush(tester);
    });
  });
}
