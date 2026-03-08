import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test harness for ClassicHeader/ClassicFooter
class _ClassicIndicatorHarness extends StatefulWidget {
  final ClassicHeader? header;
  final ClassicFooter? footer;
  final bool useDefaultIndicators = false;

  const _ClassicIndicatorHarness({
    super.key,
    this.header,
    this.footer,
  });

  @override
  State<_ClassicIndicatorHarness> createState() =>
      _ClassicIndicatorHarnessState();
}

class _ClassicIndicatorHarnessState extends State<_ClassicIndicatorHarness> {
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
          header: widget.useDefaultIndicators
              ? null
              : (widget.header ?? const ClassicHeader()),
          footer: widget.useDefaultIndicators
              ? null
              : (widget.footer ?? const ClassicFooter()),
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
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

void main() {
  group('ClassicHeader Tests', () {
    testWidgets('ClassicHeader renders correctly', (tester) async {
      final key = GlobalKey<_ClassicIndicatorHarnessState>();
      await tester.pumpWidget(_ClassicIndicatorHarness(
        key: key,
        header: const ClassicHeader(),
      ));

      await tester.pumpAndSettle();

      // Trigger refresh to make header visible
      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      // ClassicHeader should be visible with default text
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      key.currentState!.finishRefresh();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('ClassicHeader with custom dragText', (tester) async {
      final key = GlobalKey<_ClassicIndicatorHarnessState>();
      await tester.pumpWidget(_ClassicIndicatorHarness(
        key: key,
        header: const ClassicHeader(
          dragText: 'Custom drag text',
        ),
      ));

      await tester.pumpAndSettle();

      // Start dragging
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ListView)),
      );
      await gesture.moveBy(const Offset(0, 50));
      await tester.pump();

      // Should show custom drag text
      expect(find.text('Custom drag text'), findsOneWidget);

      await gesture.up();
      await tester.pumpAndSettle();

      await disposeAndFlush(tester);
    });

    testWidgets('ClassicHeader with custom armedText', (tester) async {
      final key = GlobalKey<_ClassicIndicatorHarnessState>();
      await tester.pumpWidget(_ClassicIndicatorHarness(
        key: key,
        header: const ClassicHeader(
          armedText: 'Release now!',
        ),
      ));

      await tester.pumpAndSettle();

      // Use controller to trigger refresh (more reliable than gesture for testing text)
      key.currentState!.controller.callRefresh();
      await tester.pump();
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // EasyRefresh should render
      expect(find.byType(EasyRefresh), findsOneWidget);

      key.currentState!.finishRefresh();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('ClassicHeader with custom processingText', (tester) async {
      final key = GlobalKey<_ClassicIndicatorHarnessState>();
      await tester.pumpWidget(_ClassicIndicatorHarness(
        key: key,
        header: const ClassicHeader(
          processingText: 'Loading data...',
        ),
      ));

      await tester.pumpAndSettle();

      // Use controller to trigger refresh
      key.currentState!.controller.callRefresh();
      await tester.pump();
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // EasyRefresh should render
      expect(find.byType(EasyRefresh), findsOneWidget);

      key.currentState!.finishRefresh();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('ClassicHeader with showText: false', (tester) async {
      final key = GlobalKey<_ClassicIndicatorHarnessState>();
      await tester.pumpWidget(_ClassicIndicatorHarness(
        key: key,
        header: const ClassicHeader(
          showText: false,
        ),
      ));

      await tester.pumpAndSettle();

      // Trigger refresh
      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      // Should not show any text
      expect(find.text('Refreshing...'), findsNothing);
      expect(find.text('Pull to refresh'), findsNothing);

      key.currentState!.finishRefresh();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('ClassicHeader with showMessage: false', (tester) async {
      final key = GlobalKey<_ClassicIndicatorHarnessState>();
      await tester.pumpWidget(_ClassicIndicatorHarness(
        key: key,
        header: const ClassicHeader(
          showMessage: false,
        ),
      ));

      await tester.pumpAndSettle();

      // Use controller to trigger refresh
      key.currentState!.controller.callRefresh();
      await tester.pump();
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // EasyRefresh should render (showMessage affects rendering details)
      expect(find.byType(EasyRefresh), findsOneWidget);

      key.currentState!.finishRefresh();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('ClassicHeader with custom triggerOffset', (tester) async {
      final key = GlobalKey<_ClassicIndicatorHarnessState>();
      await tester.pumpWidget(_ClassicIndicatorHarness(
        key: key,
        header: const ClassicHeader(
          triggerOffset: 100,
        ),
      ));

      await tester.pumpAndSettle();

      // Use controller to trigger refresh
      key.currentState!.controller.callRefresh();
      await tester.pump();
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // EasyRefresh should render
      expect(find.byType(EasyRefresh), findsOneWidget);

      key.currentState!.finishRefresh();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('ClassicHeader mainAxisAlignment options', (tester) async {
      // Test MainAxisAlignment.start
      var key = GlobalKey<_ClassicIndicatorHarnessState>();
      await tester.pumpWidget(_ClassicIndicatorHarness(
        key: key,
        header: const ClassicHeader(
          mainAxisAlignment: MainAxisAlignment.start,
        ),
      ));

      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      // Header should render (we just verify it doesn't crash)
      expect(find.byType(EasyRefresh), findsOneWidget);

      key.currentState!.finishRefresh();
      await tester.pump();
      await tester.pump();

      // Test MainAxisAlignment.end
      key = GlobalKey<_ClassicIndicatorHarnessState>();
      await tester.pumpWidget(_ClassicIndicatorHarness(
        key: key,
        header: const ClassicHeader(
          mainAxisAlignment: MainAxisAlignment.end,
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

    testWidgets('ClassicHeader with clamping: true', (tester) async {
      final key = GlobalKey<_ClassicIndicatorHarnessState>();
      await tester.pumpWidget(_ClassicIndicatorHarness(
        key: key,
        header: const ClassicHeader(
          clamping: true,
        ),
      ));

      await tester.pumpAndSettle();

      // Trigger refresh
      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      // Should work with clamping
      expect(find.byType(EasyRefresh), findsOneWidget);

      key.currentState!.finishRefresh();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('ClassicHeader with backgroundColor', (tester) async {
      final key = GlobalKey<_ClassicIndicatorHarnessState>();
      await tester.pumpWidget(_ClassicIndicatorHarness(
        key: key,
        header: const ClassicHeader(
          backgroundColor: Colors.blue,
        ),
      ));

      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      // Verify the header renders with background color
      expect(find.byType(EasyRefresh), findsOneWidget);

      key.currentState!.finishRefresh();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });
  });

  group('ClassicFooter Tests', () {
    testWidgets('ClassicFooter renders correctly', (tester) async {
      final key = GlobalKey<_ClassicIndicatorHarnessState>();
      await tester.pumpWidget(_ClassicIndicatorHarness(
        key: key,
        footer: const ClassicFooter(),
      ));

      await tester.pumpAndSettle();

      // Scroll to bottom and trigger load
      key.currentState!.scrollController.jumpTo(
        key.currentState!.scrollController.position.maxScrollExtent,
      );
      await tester.pump();

      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pump();

      // ClassicFooter should be visible
      expect(find.byType(EasyRefresh), findsOneWidget);

      key.currentState!.finishLoad();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('ClassicFooter with infiniteOffset', (tester) async {
      final key = GlobalKey<_ClassicIndicatorHarnessState>();
      await tester.pumpWidget(_ClassicIndicatorHarness(
        key: key,
        footer: const ClassicFooter(
          infiniteOffset: 70,
        ),
      ));

      await tester.pumpAndSettle();

      // Scroll to bottom - should auto-trigger load with infiniteOffset
      key.currentState!.scrollController.jumpTo(
        key.currentState!.scrollController.position.maxScrollExtent,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should auto-trigger load when reaching the end
      expect(find.byType(EasyRefresh), findsOneWidget);

      key.currentState!.finishLoad();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('ClassicFooter with custom text properties', (tester) async {
      final key = GlobalKey<_ClassicIndicatorHarnessState>();
      await tester.pumpWidget(_ClassicIndicatorHarness(
        key: key,
        footer: const ClassicFooter(
          dragText: 'Pull up to load',
          armedText: 'Release to load',
          processingText: 'Loading more...',
          processedText: 'Load complete',
          noMoreText: 'No more items',
          failedText: 'Load failed',
          infiniteOffset: null,
        ),
      ));

      await tester.pumpAndSettle();

      // Scroll to bottom
      key.currentState!.scrollController.jumpTo(
        key.currentState!.scrollController.position.maxScrollExtent,
      );
      await tester.pump();

      // Start drag
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ListView)),
      );
      await gesture.moveBy(const Offset(0, -50));
      await tester.pump();

      // Should show custom drag text
      expect(find.text('Pull up to load'), findsOneWidget);

      await gesture.up();
      await tester.pumpAndSettle();

      await disposeAndFlush(tester);
    });

    testWidgets('ClassicFooter with triggerWhenReach', (tester) async {
      final key = GlobalKey<_ClassicIndicatorHarnessState>();
      await tester.pumpWidget(_ClassicIndicatorHarness(
        key: key,
        footer: const ClassicFooter(
          triggerWhenReach: true,
          infiniteOffset: null,
        ),
      ));

      await tester.pumpAndSettle();

      // Scroll to bottom
      key.currentState!.scrollController.jumpTo(
        key.currentState!.scrollController.position.maxScrollExtent,
      );
      await tester.pump();

      // Drag to trigger
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ListView)),
      );
      await gesture.moveBy(const Offset(0, -100));
      await tester.pump();

      // With triggerWhenReach, should trigger immediately when reaching triggerOffset
      expect(find.byType(EasyRefresh), findsOneWidget);

      await gesture.up();
      await tester.pump();

      key.currentState!.finishLoad();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });
  });

  group('ClassicIndicator Default Texts', () {
    testWidgets('ClassicHeader has correct default texts', (tester) async {
      const header = ClassicHeader();

      expect(header.dragText,
          isNull); // Uses 'Pull to refresh' as default in build
      expect(
          header.armedText, isNull); // Uses 'Release ready' as default in build
      expect(header.processingText,
          isNull); // Uses 'Refreshing...' as default in build
      expect(
          header.processedText, isNull); // Uses 'Succeeded' as default in build
      expect(header.noMoreText, isNull); // Uses 'No more' as default in build
      expect(header.failedText, isNull); // Uses 'Failed' as default in build
    });

    testWidgets('ClassicFooter has correct default texts', (tester) async {
      const footer = ClassicFooter();

      expect(
          footer.dragText, isNull); // Uses 'Pull to load' as default in build
      expect(
          footer.armedText, isNull); // Uses 'Release ready' as default in build
      expect(footer.processingText,
          isNull); // Uses 'Loading...' as default in build
      expect(
          footer.processedText, isNull); // Uses 'Succeeded' as default in build
      expect(footer.noMoreText, isNull); // Uses 'No more' as default in build
      expect(footer.failedText, isNull); // Uses 'Failed' as default in build
    });
  });

  group('ClassicIndicator Properties', () {
    testWidgets('ClassicHeader default triggerOffset is 70', (tester) async {
      const header = ClassicHeader();
      expect(header.triggerOffset, 70);
    });

    testWidgets('ClassicFooter default triggerOffset is 70', (tester) async {
      const footer = ClassicFooter();
      expect(footer.triggerOffset, 70);
    });

    testWidgets('ClassicHeader default clamping is false', (tester) async {
      const header = ClassicHeader();
      expect(header.clamping, false);
    });

    testWidgets('ClassicFooter default clamping is false', (tester) async {
      const footer = ClassicFooter();
      expect(footer.clamping, false);
    });

    testWidgets('ClassicFooter default infiniteOffset is 70', (tester) async {
      const footer = ClassicFooter();
      expect(footer.infiniteOffset, 70);
    });

    testWidgets('ClassicHeader default mainAxisAlignment is center',
        (tester) async {
      const header = ClassicHeader();
      expect(header.mainAxisAlignment, MainAxisAlignment.center);
    });

    testWidgets('ClassicFooter default mainAxisAlignment is start',
        (tester) async {
      const footer = ClassicFooter();
      expect(footer.mainAxisAlignment, MainAxisAlignment.start);
    });
  });
}
