import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test harness for DeliveryHeader/DeliveryFooter
class _DeliveryIndicatorHarness extends StatefulWidget {
  final DeliveryHeader? header;
  final DeliveryFooter? footer;

  const _DeliveryIndicatorHarness({
    super.key,
    this.header,
    this.footer,
  });

  @override
  State<_DeliveryIndicatorHarness> createState() =>
      _DeliveryIndicatorHarnessState();
}

class _DeliveryIndicatorHarnessState extends State<_DeliveryIndicatorHarness> {
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
          header: widget.header ?? const DeliveryHeader(),
          footer: widget.footer ?? const DeliveryFooter(),
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
  group('DeliveryHeader Tests', () {
    testWidgets('DeliveryHeader renders correctly', (tester) async {
      final key = GlobalKey<_DeliveryIndicatorHarnessState>();
      await tester.pumpWidget(_DeliveryIndicatorHarness(
        key: key,
        header: const DeliveryHeader(),
      ));

      await tester.pumpAndSettle();

      // Trigger refresh
      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      // DeliveryHeader should render
      expect(find.byType(EasyRefresh), findsOneWidget);

      key.currentState!.finishRefresh();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await disposeAndFlush(tester);
    });

    testWidgets('DeliveryHeader with custom skyColor', (tester) async {
      final key = GlobalKey<_DeliveryIndicatorHarnessState>();
      await tester.pumpWidget(_DeliveryIndicatorHarness(
        key: key,
        header: const DeliveryHeader(
          skyColor: Colors.lightBlue,
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

    testWidgets('DeliveryHeader default clamping is false', (tester) async {
      const header = DeliveryHeader();
      expect(header.clamping, false);
    });

    testWidgets('DeliveryHeader default springRebound is false',
        (tester) async {
      const header = DeliveryHeader();
      expect(header.springRebound, false);
    });

    testWidgets('DeliveryHeader safeArea is false', (tester) async {
      const header = DeliveryHeader();
      expect(header.safeArea, false);
    });
  });

  group('DeliveryFooter Tests', () {
    testWidgets('DeliveryFooter renders correctly', (tester) async {
      final key = GlobalKey<_DeliveryIndicatorHarnessState>();
      await tester.pumpWidget(_DeliveryIndicatorHarness(
        key: key,
        footer: const DeliveryFooter(),
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

      // DeliveryFooter should render
      expect(find.byType(EasyRefresh), findsOneWidget);

      state.finishLoad();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await disposeAndFlush(tester);
    });

    testWidgets('DeliveryFooter with custom skyColor', (tester) async {
      final key = GlobalKey<_DeliveryIndicatorHarnessState>();
      await tester.pumpWidget(_DeliveryIndicatorHarness(
        key: key,
        footer: const DeliveryFooter(
          skyColor: Colors.amber,
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

  group('Delivery Indicator Refresh Cycle', () {
    testWidgets('DeliveryHeader completes full refresh cycle', (tester) async {
      final key = GlobalKey<_DeliveryIndicatorHarnessState>();
      await tester.pumpWidget(_DeliveryIndicatorHarness(key: key));
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
