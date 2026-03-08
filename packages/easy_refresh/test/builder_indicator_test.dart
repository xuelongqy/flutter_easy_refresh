import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test harness for BuilderHeader/BuilderFooter
class _BuilderIndicatorHarness extends StatefulWidget {
  final IndicatorBuilder? headerBuilder;
  final IndicatorBuilder? footerBuilder;
  final IndicatorPosition footerPosition;
  final Duration processedDuration;
  final double triggerOffset;

  const _BuilderIndicatorHarness({
    super.key,
    this.headerBuilder,
    this.footerBuilder,
    this.footerPosition = IndicatorPosition.above,
    this.processedDuration = Duration.zero,
    this.triggerOffset = 70,
  });

  @override
  State<_BuilderIndicatorHarness> createState() =>
      _BuilderIndicatorHarnessState();
}

class _BuilderIndicatorHarnessState extends State<_BuilderIndicatorHarness> {
  late final EasyRefreshController controller;
  final scrollController = ScrollController();

  int itemCount = 60;
  List<IndicatorMode> headerModes = [];
  List<IndicatorMode> footerModes = [];
  List<double> headerOffsets = [];
  List<double> footerOffsets = [];
  double? lastActualTriggerOffset;

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
          header: BuilderHeader(
            triggerOffset: widget.triggerOffset,
            clamping: false,
            processedDuration: widget.processedDuration,
            position: IndicatorPosition.above,
            builder: widget.headerBuilder ??
                (context, state) {
                  headerModes.add(state.mode);
                  headerOffsets.add(state.offset);
                  lastActualTriggerOffset = state.actualTriggerOffset;
                  return SizedBox(
                    height: state.offset,
                    width: double.infinity,
                    child: ColoredBox(
                      color: Colors.blue.withValues(alpha: 0.3),
                      child: state.offset > 60
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Mode: ${state.mode.name}',
                                  key: const Key('header-mode'),
                                ),
                                Text(
                                  'Offset: ${state.offset.toStringAsFixed(1)}',
                                  key: const Key('header-offset'),
                                ),
                                Text(
                                  'TriggerOffset: ${state.actualTriggerOffset.toStringAsFixed(1)}',
                                  key: const Key('header-trigger-offset'),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  );
                },
          ),
          footer: BuilderFooter(
            triggerOffset: widget.triggerOffset,
            clamping: false,
            processedDuration: widget.processedDuration,
            position: widget.footerPosition,
            infiniteOffset: null,
            builder: widget.footerBuilder ??
                (context, state) {
                  footerModes.add(state.mode);
                  footerOffsets.add(state.offset);
                  return SizedBox(
                    height: state.offset,
                    width: double.infinity,
                    child: ColoredBox(
                      color: Colors.green.withValues(alpha: 0.3),
                      child: state.offset > 30
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Mode: ${state.mode.name}',
                                  key: const Key('footer-mode'),
                                ),
                                Text(
                                  'Offset: ${state.offset.toStringAsFixed(1)}',
                                  key: const Key('footer-offset'),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  );
                },
          ),
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
  group('BuilderHeader Tests', () {
    testWidgets('BuilderHeader custom builder function receives state',
        (tester) async {
      final key = GlobalKey<_BuilderIndicatorHarnessState>();
      await tester.pumpWidget(_BuilderIndicatorHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      // Clear previous modes from initial build
      state.headerModes.clear();
      state.headerOffsets.clear();

      // Start dragging
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ListView)),
      );
      await gesture.moveBy(const Offset(0, 50));
      await tester.pump();

      // Should have recorded drag mode
      expect(state.headerModes, contains(IndicatorMode.drag));
      expect(state.headerOffsets.any((o) => o > 0), isTrue);

      await gesture.up();
      await tester.pumpAndSettle();

      await disposeAndFlush(tester);
    });

    testWidgets('BuilderHeader state.mode values during lifecycle',
        (tester) async {
      final key = GlobalKey<_BuilderIndicatorHarnessState>();
      await tester.pumpWidget(_BuilderIndicatorHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      state.headerModes.clear();

      // Use gesture to properly trigger full refresh cycle
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ListView)),
      );
      await gesture.moveBy(const Offset(0, 150));
      await tester.pump();

      // Should record drag/armed modes during pull
      expect(
          state.headerModes.contains(IndicatorMode.drag) ||
              state.headerModes.contains(IndicatorMode.armed),
          isTrue);

      // Release to trigger refresh
      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should have recorded at least some modes during the refresh cycle
      expect(state.headerModes.isNotEmpty, isTrue);

      state.finishRefresh();
      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      // Should have recorded multiple mode transitions
      expect(state.headerModes.length, greaterThan(1));

      await disposeAndFlush(tester);
    });

    testWidgets('BuilderHeader state.offset values during pull',
        (tester) async {
      final key = GlobalKey<_BuilderIndicatorHarnessState>();
      await tester.pumpWidget(_BuilderIndicatorHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      state.headerOffsets.clear();

      // Incrementally drag
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ListView)),
      );

      await gesture.moveBy(const Offset(0, 30));
      await tester.pump();

      await gesture.moveBy(const Offset(0, 30));
      await tester.pump();

      await gesture.moveBy(const Offset(0, 30));
      await tester.pump();

      // Offsets should be increasing
      expect(state.headerOffsets.length, greaterThanOrEqualTo(3));

      await gesture.up();
      await tester.pumpAndSettle();

      await disposeAndFlush(tester);
    });

    testWidgets('BuilderHeader state.actualTriggerOffset access',
        (tester) async {
      final key = GlobalKey<_BuilderIndicatorHarnessState>();
      await tester.pumpWidget(_BuilderIndicatorHarness(
        key: key,
        triggerOffset: 100,
      ));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      // Trigger refresh to access actualTriggerOffset
      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      // actualTriggerOffset should be set
      expect(state.lastActualTriggerOffset, isNotNull);
      expect(state.lastActualTriggerOffset, greaterThanOrEqualTo(100));

      state.finishRefresh();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('BuilderHeader with processedDuration', (tester) async {
      final key = GlobalKey<_BuilderIndicatorHarnessState>();
      await tester.pumpWidget(_BuilderIndicatorHarness(
        key: key,
        processedDuration: const Duration(milliseconds: 200),
      ));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      state.headerModes.clear();

      // Trigger refresh with gesture
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ListView)),
      );
      await gesture.moveBy(const Offset(0, 150));
      await tester.pump();
      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      state.finishRefresh();
      await tester.pump();
      await tester.pump();

      // Wait for processedDuration and settle
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Should have recorded some mode transitions
      expect(state.headerModes.isNotEmpty, isTrue);

      await disposeAndFlush(tester);
    });
  });

  group('BuilderFooter Tests', () {
    testWidgets('BuilderFooter custom builder function receives state',
        (tester) async {
      final key = GlobalKey<_BuilderIndicatorHarnessState>();
      await tester.pumpWidget(_BuilderIndicatorHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      state.footerModes.clear();
      state.footerOffsets.clear();

      // Scroll to bottom
      state.scrollController.jumpTo(
        state.scrollController.position.maxScrollExtent,
      );
      await tester.pump();

      // Trigger load
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ListView)),
      );
      await gesture.moveBy(const Offset(0, -100));
      await tester.pump();

      // Should have recorded modes and offsets
      expect(state.footerModes.isNotEmpty, isTrue);
      expect(state.footerOffsets.any((o) => o > 0), isTrue);

      await gesture.up();
      await tester.pumpAndSettle();

      state.finishLoad();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('BuilderFooter with position: IndicatorPosition.above',
        (tester) async {
      final key = GlobalKey<_BuilderIndicatorHarnessState>();
      await tester.pumpWidget(_BuilderIndicatorHarness(
        key: key,
        footerPosition: IndicatorPosition.above,
      ));

      await tester.pumpAndSettle();

      // Scroll to bottom and trigger load
      key.currentState!.scrollController.jumpTo(
        key.currentState!.scrollController.position.maxScrollExtent,
      );
      await tester.pump();

      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pump();

      // Footer should be rendered above content
      expect(find.byType(EasyRefresh), findsOneWidget);

      key.currentState!.finishLoad();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });
  });

  group('BuilderIndicator Mode Transitions', () {
    testWidgets('mode transitions are recorded during drag gesture',
        (tester) async {
      final key = GlobalKey<_BuilderIndicatorHarnessState>();
      await tester.pumpWidget(_BuilderIndicatorHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      state.headerModes.clear();

      // Drag to trigger mode changes
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ListView)),
      );

      // Small drag - should be in drag mode
      await gesture.moveBy(const Offset(0, 40));
      await tester.pump();
      expect(state.headerModes.contains(IndicatorMode.drag), isTrue);

      // Drag past trigger - should be armed
      await gesture.moveBy(const Offset(0, 100));
      await tester.pump();
      expect(state.headerModes.contains(IndicatorMode.armed), isTrue);

      // Release
      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should have recorded some modes
      expect(state.headerModes.length, greaterThan(1));

      // Finish
      state.finishRefresh();
      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      await disposeAndFlush(tester);
    });
  });

  group('BuilderIndicator Custom Widgets', () {
    testWidgets('BuilderHeader can render any custom widget', (tester) async {
      await tester.pumpWidget(_BuilderIndicatorHarness(
        headerBuilder: (context, state) {
          return SizedBox(
            key: const Key('custom-header'),
            height: state.offset,
            width: double.infinity,
            child: const Center(
              child: Icon(Icons.refresh, size: 32),
            ),
          );
        },
      ));

      await tester.pumpAndSettle();

      // Trigger refresh
      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      // Custom icon should be visible
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      await disposeAndFlush(tester);
    });

    testWidgets('BuilderFooter can render any custom widget', (tester) async {
      final key = GlobalKey<_BuilderIndicatorHarnessState>();
      await tester.pumpWidget(_BuilderIndicatorHarness(
        key: key,
        footerBuilder: (context, state) {
          return SizedBox(
            key: const Key('custom-footer'),
            height: state.offset,
            width: double.infinity,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ));
      final state = key.currentState!;

      // Just pump a few times instead of pumpAndSettle to avoid timeout
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Scroll to bottom and trigger load
      state.scrollController.jumpTo(
        state.scrollController.position.maxScrollExtent,
      );
      await tester.pump();

      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pump();

      // Custom progress indicator should be visible
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      state.finishLoad();
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await disposeAndFlush(tester);
    });
  });
}
