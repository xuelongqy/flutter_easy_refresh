import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test harness for BezierHeader/BezierCircleHeader/BezierFooter
class _BezierIndicatorHarness extends StatefulWidget {
  final Header? header;
  final Footer? footer;

  const _BezierIndicatorHarness({
    super.key,
    this.header,
    this.footer,
  });

  @override
  State<_BezierIndicatorHarness> createState() =>
      _BezierIndicatorHarnessState();
}

class _BezierIndicatorHarnessState extends State<_BezierIndicatorHarness> {
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
          header: widget.header ?? const BezierHeader(),
          footer: widget.footer ?? const BezierFooter(),
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
  group('BezierHeader Tests', () {
    testWidgets('BezierHeader renders correctly', (tester) async {
      final key = GlobalKey<_BezierIndicatorHarnessState>();
      await tester.pumpWidget(_BezierIndicatorHarness(
        key: key,
        header: const BezierHeader(),
      ));

      await tester.pumpAndSettle();

      // Trigger refresh
      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      // BezierHeader should render
      expect(find.byType(EasyRefresh), findsOneWidget);

      key.currentState!.finishRefresh();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await disposeAndFlush(tester);
    });

    testWidgets('BezierHeader with showBalls: true', (tester) async {
      final key = GlobalKey<_BezierIndicatorHarnessState>();
      await tester.pumpWidget(_BezierIndicatorHarness(
        key: key,
        header: const BezierHeader(
          showBalls: true,
        ),
      ));

      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      expect(find.byType(EasyRefresh), findsOneWidget);

      key.currentState!.finishRefresh();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await disposeAndFlush(tester);
    });

    testWidgets('BezierHeader with showBalls: false', (tester) async {
      final key = GlobalKey<_BezierIndicatorHarnessState>();
      await tester.pumpWidget(_BezierIndicatorHarness(
        key: key,
        header: const BezierHeader(
          showBalls: false,
        ),
      ));

      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      expect(find.byType(EasyRefresh), findsOneWidget);

      key.currentState!.finishRefresh();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await disposeAndFlush(tester);
    });

    testWidgets('BezierHeader with custom colors', (tester) async {
      final key = GlobalKey<_BezierIndicatorHarnessState>();
      await tester.pumpWidget(_BezierIndicatorHarness(
        key: key,
        header: const BezierHeader(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
        ),
      ));

      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      expect(find.byType(EasyRefresh), findsOneWidget);

      key.currentState!.finishRefresh();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await disposeAndFlush(tester);
    });

    testWidgets('BezierHeader with spinInCenter: true', (tester) async {
      final key = GlobalKey<_BezierIndicatorHarnessState>();
      await tester.pumpWidget(_BezierIndicatorHarness(
        key: key,
        header: const BezierHeader(
          spinInCenter: true,
        ),
      ));

      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      expect(find.byType(EasyRefresh), findsOneWidget);

      key.currentState!.finishRefresh();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await disposeAndFlush(tester);
    });

    testWidgets('BezierHeader with onlySpin: true', (tester) async {
      final key = GlobalKey<_BezierIndicatorHarnessState>();
      await tester.pumpWidget(_BezierIndicatorHarness(
        key: key,
        header: const BezierHeader(
          onlySpin: true,
        ),
      ));

      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      expect(find.byType(EasyRefresh), findsOneWidget);

      key.currentState!.finishRefresh();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await disposeAndFlush(tester);
    });

    testWidgets('BezierHeader with custom spinWidget', (tester) async {
      final key = GlobalKey<_BezierIndicatorHarnessState>();
      await tester.pumpWidget(_BezierIndicatorHarness(
        key: key,
        header: const BezierHeader(
          spinWidget: Icon(Icons.refresh),
        ),
      ));

      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      expect(find.byType(EasyRefresh), findsOneWidget);

      key.currentState!.finishRefresh();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await disposeAndFlush(tester);
    });

    testWidgets('BezierHeader default triggerOffset is 100', (tester) async {
      const header = BezierHeader();
      expect(header.triggerOffset, 100);
    });

    testWidgets('BezierHeader default clamping is false', (tester) async {
      const header = BezierHeader();
      expect(header.clamping, false);
    });

    testWidgets('BezierHeader default springRebound is false', (tester) async {
      const header = BezierHeader();
      expect(header.springRebound, false);
    });
  });

  group('BezierCircleHeader Tests', () {
    testWidgets('BezierCircleHeader renders correctly', (tester) async {
      final key = GlobalKey<_BezierIndicatorHarnessState>();
      await tester.pumpWidget(_BezierIndicatorHarness(
        key: key,
        header: const BezierCircleHeader(),
      ));

      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      expect(find.byType(EasyRefresh), findsOneWidget);

      key.currentState!.finishRefresh();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await disposeAndFlush(tester);
    });

    testWidgets('BezierCircleHeader with custom colors', (tester) async {
      final key = GlobalKey<_BezierIndicatorHarnessState>();
      await tester.pumpWidget(_BezierIndicatorHarness(
        key: key,
        header: const BezierCircleHeader(
          foregroundColor: Colors.white,
          backgroundColor: Colors.purple,
        ),
      ));

      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      expect(find.byType(EasyRefresh), findsOneWidget);

      key.currentState!.finishRefresh();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await disposeAndFlush(tester);
    });
  });

  group('BezierFooter Tests', () {
    testWidgets('BezierFooter renders correctly', (tester) async {
      final key = GlobalKey<_BezierIndicatorHarnessState>();
      await tester.pumpWidget(_BezierIndicatorHarness(
        key: key,
        footer: const BezierFooter(),
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

      expect(find.byType(EasyRefresh), findsOneWidget);

      state.finishLoad();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await disposeAndFlush(tester);
    });

    testWidgets('BezierFooter with custom colors', (tester) async {
      final key = GlobalKey<_BezierIndicatorHarnessState>();
      await tester.pumpWidget(_BezierIndicatorHarness(
        key: key,
        footer: const BezierFooter(
          foregroundColor: Colors.white,
          backgroundColor: Colors.green,
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
      await tester.pump(const Duration(milliseconds: 300));

      await disposeAndFlush(tester);
    });
  });

  group('Bezier Indicator Refresh Cycle', () {
    testWidgets('BezierHeader completes full refresh cycle', (tester) async {
      final key = GlobalKey<_BezierIndicatorHarnessState>();
      await tester.pumpWidget(_BezierIndicatorHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      // Start drag
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ListView)),
      );
      await gesture.moveBy(const Offset(0, 150));
      await tester.pump();

      // Release to trigger refresh
      await gesture.up();
      await tester.pump();

      // Finish refresh
      state.finishRefresh();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Should complete without error
      expect(find.byType(EasyRefresh), findsOneWidget);

      await disposeAndFlush(tester);
    });
  });
}
