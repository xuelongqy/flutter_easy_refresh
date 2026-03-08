import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test harness for MaterialHeader/MaterialFooter
class _MaterialIndicatorHarness extends StatefulWidget {
  final MaterialHeader? header;
  final MaterialFooter? footer;

  const _MaterialIndicatorHarness({
    super.key,
    this.header,
    this.footer,
  });

  @override
  State<_MaterialIndicatorHarness> createState() =>
      _MaterialIndicatorHarnessState();
}

class _MaterialIndicatorHarnessState extends State<_MaterialIndicatorHarness> {
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
          header: widget.header ?? const MaterialHeader(),
          footer: widget.footer ?? const MaterialFooter(),
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
  group('MaterialHeader Tests', () {
    testWidgets('MaterialHeader renders correctly', (tester) async {
      final key = GlobalKey<_MaterialIndicatorHarnessState>();
      await tester.pumpWidget(_MaterialIndicatorHarness(
        key: key,
        header: const MaterialHeader(),
      ));

      await tester.pumpAndSettle();

      // Trigger refresh to make header visible
      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      // MaterialHeader should render - check that EasyRefresh is present
      expect(find.byType(EasyRefresh), findsOneWidget);

      key.currentState!.finishRefresh();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await disposeAndFlush(tester);
    });

    testWidgets('MaterialHeader with custom color', (tester) async {
      final key = GlobalKey<_MaterialIndicatorHarnessState>();
      await tester.pumpWidget(_MaterialIndicatorHarness(
        key: key,
        header: const MaterialHeader(
          color: Colors.red,
        ),
      ));

      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      // Should render without error with custom color
      expect(find.byType(EasyRefresh), findsOneWidget);

      key.currentState!.finishRefresh();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await disposeAndFlush(tester);
    });

    testWidgets('MaterialHeader with backgroundColor', (tester) async {
      final key = GlobalKey<_MaterialIndicatorHarnessState>();
      await tester.pumpWidget(_MaterialIndicatorHarness(
        key: key,
        header: const MaterialHeader(
          backgroundColor: Colors.white,
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

    testWidgets('MaterialHeader with showBezierBackground', (tester) async {
      final key = GlobalKey<_MaterialIndicatorHarnessState>();
      await tester.pumpWidget(_MaterialIndicatorHarness(
        key: key,
        header: const MaterialHeader(
          showBezierBackground: true,
          bezierBackgroundColor: Colors.blue,
        ),
      ));

      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      // Should render with bezier background
      expect(find.byType(EasyRefresh), findsOneWidget);

      key.currentState!.finishRefresh();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await disposeAndFlush(tester);
    });

    testWidgets('MaterialHeader with clamping: true', (tester) async {
      final key = GlobalKey<_MaterialIndicatorHarnessState>();
      await tester.pumpWidget(_MaterialIndicatorHarness(
        key: key,
        header: const MaterialHeader(
          clamping: true,
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

    testWidgets('MaterialHeader default triggerOffset is 100', (tester) async {
      const header = MaterialHeader();
      expect(header.triggerOffset, 100);
    });

    testWidgets('MaterialHeader default clamping is true', (tester) async {
      const header = MaterialHeader();
      expect(header.clamping, true);
    });
  });

  group('MaterialFooter Tests', () {
    testWidgets('MaterialFooter renders correctly', (tester) async {
      final key = GlobalKey<_MaterialIndicatorHarnessState>();
      await tester.pumpWidget(_MaterialIndicatorHarness(
        key: key,
        footer: const MaterialFooter(),
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

      // MaterialFooter should render - check that EasyRefresh is present
      expect(find.byType(EasyRefresh), findsOneWidget);

      state.finishLoad();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await disposeAndFlush(tester);
    });

    testWidgets('MaterialFooter with custom properties', (tester) async {
      final key = GlobalKey<_MaterialIndicatorHarnessState>();
      await tester.pumpWidget(_MaterialIndicatorHarness(
        key: key,
        footer: const MaterialFooter(
          color: Colors.green,
          backgroundColor: Colors.white,
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

  group('MaterialIndicator Properties', () {
    testWidgets('MaterialHeader has noMoreIcon property', (tester) async {
      const header = MaterialHeader(
        noMoreIcon: Icon(Icons.check),
      );
      expect(header.noMoreIcon, isNotNull);
    });

    testWidgets('MaterialHeader processedDuration default', (tester) async {
      const header = MaterialHeader();
      expect(header.processedDuration, const Duration(milliseconds: 200));
    });

    testWidgets('MaterialHeader springRebound default is false',
        (tester) async {
      const header = MaterialHeader();
      expect(header.springRebound, false);
    });
  });

  group('MaterialIndicator Bezier Animation', () {
    testWidgets('MaterialHeader with bezierBackgroundAnimation',
        (tester) async {
      final key = GlobalKey<_MaterialIndicatorHarnessState>();
      await tester.pumpWidget(_MaterialIndicatorHarness(
        key: key,
        header: const MaterialHeader(
          showBezierBackground: true,
          bezierBackgroundAnimation: true,
        ),
      ));

      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      // Should render with animation
      expect(find.byType(EasyRefresh), findsOneWidget);

      key.currentState!.finishRefresh();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await disposeAndFlush(tester);
    });

    testWidgets('MaterialHeader with bezierBackgroundBounce', (tester) async {
      final key = GlobalKey<_MaterialIndicatorHarnessState>();
      await tester.pumpWidget(_MaterialIndicatorHarness(
        key: key,
        header: const MaterialHeader(
          showBezierBackground: true,
          bezierBackgroundBounce: true,
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

  group('MaterialIndicator Refresh Cycle', () {
    testWidgets('MaterialHeader completes full refresh cycle', (tester) async {
      final key = GlobalKey<_MaterialIndicatorHarnessState>();
      await tester.pumpWidget(_MaterialIndicatorHarness(key: key));
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
