import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test harness for PhoenixHeader/PhoenixFooter
class _PhoenixIndicatorHarness extends StatefulWidget {
  final PhoenixHeader? header;
  final PhoenixFooter? footer;

  const _PhoenixIndicatorHarness({
    super.key,
    this.header,
    this.footer,
  });

  @override
  State<_PhoenixIndicatorHarness> createState() =>
      _PhoenixIndicatorHarnessState();
}

class _PhoenixIndicatorHarnessState extends State<_PhoenixIndicatorHarness> {
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
          header: widget.header ?? const PhoenixHeader(),
          footer: widget.footer ?? const PhoenixFooter(),
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
  group('PhoenixHeader Tests', () {
    testWidgets('PhoenixHeader renders correctly', (tester) async {
      final key = GlobalKey<_PhoenixIndicatorHarnessState>();
      await tester.pumpWidget(_PhoenixIndicatorHarness(
        key: key,
        header: const PhoenixHeader(),
      ));

      await tester.pumpAndSettle();

      // Trigger refresh
      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      // PhoenixHeader should render
      expect(find.byType(EasyRefresh), findsOneWidget);

      key.currentState!.finishRefresh();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await disposeAndFlush(tester);
    });

    testWidgets('PhoenixHeader with custom skyColor', (tester) async {
      final key = GlobalKey<_PhoenixIndicatorHarnessState>();
      await tester.pumpWidget(_PhoenixIndicatorHarness(
        key: key,
        header: const PhoenixHeader(
          skyColor: Colors.orange,
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

    testWidgets('PhoenixHeader default triggerOffset is 100', (tester) async {
      const header = PhoenixHeader();
      expect(header.triggerOffset, 100);
    });

    testWidgets('PhoenixHeader default clamping is false', (tester) async {
      const header = PhoenixHeader();
      expect(header.clamping, false);
    });

    testWidgets('PhoenixHeader default springRebound is false', (tester) async {
      const header = PhoenixHeader();
      expect(header.springRebound, false);
    });
  });

  group('PhoenixFooter Tests', () {
    testWidgets('PhoenixFooter renders correctly', (tester) async {
      final key = GlobalKey<_PhoenixIndicatorHarnessState>();
      await tester.pumpWidget(_PhoenixIndicatorHarness(
        key: key,
        footer: const PhoenixFooter(),
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

      // PhoenixFooter should render
      expect(find.byType(EasyRefresh), findsOneWidget);

      state.finishLoad();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await disposeAndFlush(tester);
    });

    testWidgets('PhoenixFooter with custom skyColor', (tester) async {
      final key = GlobalKey<_PhoenixIndicatorHarnessState>();
      await tester.pumpWidget(_PhoenixIndicatorHarness(
        key: key,
        footer: const PhoenixFooter(
          skyColor: Colors.purple,
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

  group('Phoenix Indicator Refresh Cycle', () {
    testWidgets('PhoenixHeader completes full refresh cycle', (tester) async {
      final key = GlobalKey<_PhoenixIndicatorHarnessState>();
      await tester.pumpWidget(_PhoenixIndicatorHarness(key: key));
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
