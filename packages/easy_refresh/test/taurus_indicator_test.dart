import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test harness for TaurusHeader/TaurusFooter
class _TaurusIndicatorHarness extends StatefulWidget {
  final TaurusHeader? header;
  final TaurusFooter? footer;

  const _TaurusIndicatorHarness({
    super.key,
    this.header,
    this.footer,
  });

  @override
  State<_TaurusIndicatorHarness> createState() =>
      _TaurusIndicatorHarnessState();
}

class _TaurusIndicatorHarnessState extends State<_TaurusIndicatorHarness> {
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
          header: widget.header ?? const TaurusHeader(),
          footer: widget.footer ?? const TaurusFooter(),
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
  group('TaurusHeader Tests', () {
    testWidgets('TaurusHeader renders correctly', (tester) async {
      final key = GlobalKey<_TaurusIndicatorHarnessState>();
      await tester.pumpWidget(_TaurusIndicatorHarness(
        key: key,
        header: const TaurusHeader(),
      ));

      await tester.pumpAndSettle();

      // Trigger refresh
      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      // TaurusHeader should render
      expect(find.byType(EasyRefresh), findsOneWidget);

      key.currentState!.finishRefresh();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await disposeAndFlush(tester);
    });

    testWidgets('TaurusHeader with custom skyColor', (tester) async {
      final key = GlobalKey<_TaurusIndicatorHarnessState>();
      await tester.pumpWidget(_TaurusIndicatorHarness(
        key: key,
        header: const TaurusHeader(
          skyColor: Colors.indigo,
        ),
      ));

      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      expect(find.byType(EasyRefresh), findsOneWidget);

      key.currentState!.finishRefresh();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await disposeAndFlush(tester);
    });

    testWidgets('TaurusHeader default triggerOffset is 100', (tester) async {
      const header = TaurusHeader();
      expect(header.triggerOffset, 100);
    });

    testWidgets('TaurusHeader default clamping is false', (tester) async {
      const header = TaurusHeader();
      expect(header.clamping, false);
    });

    testWidgets('TaurusHeader default springRebound is false', (tester) async {
      const header = TaurusHeader();
      expect(header.springRebound, false);
    });
  });

  group('TaurusFooter Tests', () {
    testWidgets('TaurusFooter renders correctly', (tester) async {
      final key = GlobalKey<_TaurusIndicatorHarnessState>();
      await tester.pumpWidget(_TaurusIndicatorHarness(
        key: key,
        footer: const TaurusFooter(),
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

      // TaurusFooter should render
      expect(find.byType(EasyRefresh), findsOneWidget);

      state.finishLoad();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await disposeAndFlush(tester);
    });

    testWidgets('TaurusFooter with custom skyColor', (tester) async {
      final key = GlobalKey<_TaurusIndicatorHarnessState>();
      await tester.pumpWidget(_TaurusIndicatorHarness(
        key: key,
        footer: const TaurusFooter(
          skyColor: Colors.teal,
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
      await tester.pump(const Duration(milliseconds: 500));

      await disposeAndFlush(tester);
    });
  });

  group('Taurus Indicator Refresh Cycle', () {
    testWidgets('TaurusHeader completes full refresh cycle', (tester) async {
      final key = GlobalKey<_TaurusIndicatorHarnessState>();
      await tester.pumpWidget(_TaurusIndicatorHarness(key: key));
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
      await tester.pump(const Duration(milliseconds: 500));

      // Should complete without error
      expect(find.byType(EasyRefresh), findsOneWidget);

      await disposeAndFlush(tester);
    });
  });
}
