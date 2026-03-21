import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test harness for controller functionality
class _ControllerHarness extends StatefulWidget {
  final bool controlFinishRefresh;
  final bool controlFinishLoad;
  final EasyRefreshController? externalController;

  const _ControllerHarness({
    super.key,
    this.controlFinishRefresh = false,
    this.controlFinishLoad = false,
    this.externalController,
  });

  @override
  State<_ControllerHarness> createState() => _ControllerHarnessState();
}

class _ControllerHarnessState extends State<_ControllerHarness> {
  late final EasyRefreshController controller;
  final scrollController = ScrollController();
  final headerListenable = IndicatorStateListenable();
  final footerListenable = IndicatorStateListenable();

  int itemCount = 60;
  bool refreshCalled = false;
  bool loadCalled = false;

  Completer<void>? _refreshCompleter;
  Completer<void>? _loadCompleter;

  IndicatorState? get headerState => headerListenable.value;
  IndicatorState? get footerState => footerListenable.value;

  void appendItems([int delta = 10]) {
    setState(() {
      itemCount += delta;
    });
  }

  void resetItems([int count = 10]) {
    setState(() {
      itemCount = count;
    });
  }

  Future<void> _onRefresh() async {
    refreshCalled = true;
    if (widget.controlFinishRefresh) {
      return;
    }
    _refreshCompleter ??= Completer<void>();
    await _refreshCompleter!.future;
  }

  Future<void> _onLoad() async {
    loadCalled = true;
    if (widget.controlFinishLoad) {
      return;
    }
    _loadCompleter ??= Completer<void>();
    await _loadCompleter!.future;
  }

  void completeRefresh() {
    _refreshCompleter?.complete();
  }

  void completeLoad() {
    _loadCompleter?.complete();
  }

  @override
  void initState() {
    super.initState();
    controller = widget.externalController ??
        EasyRefreshController(
          controlFinishRefresh: widget.controlFinishRefresh,
          controlFinishLoad: widget.controlFinishLoad,
        );
  }

  @override
  void dispose() {
    if (widget.externalController == null) {
      controller.dispose();
    }
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
            listenable: headerListenable,
            triggerOffset: 70,
            clamping: false,
            processedDuration: Duration.zero,
            position: IndicatorPosition.above,
            builder: (context, state) => Container(
              height: state.offset,
              width: double.infinity,
              alignment: Alignment.center,
              child: Text(
                'header:${state.mode.name}:${state.result.name}',
                key: const Key('header-debug'),
              ),
            ),
          ),
          footer: BuilderFooter(
            listenable: footerListenable,
            triggerOffset: 70,
            clamping: false,
            processedDuration: Duration.zero,
            infiniteOffset: null,
            builder: (context, state) => Container(
              height: state.offset,
              width: double.infinity,
              alignment: Alignment.center,
              child: Text(
                'footer:${state.mode.name}:${state.result.name}',
                key: const Key('footer-debug'),
              ),
            ),
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
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

void main() {
  group('Controller Creation Tests', () {
    testWidgets(
        'EasyRefreshController creation with controlFinishRefresh: false',
        (tester) async {
      final controller = EasyRefreshController(controlFinishRefresh: false);
      expect(controller.controlFinishRefresh, isFalse);
      controller.dispose();
    });

    testWidgets(
        'EasyRefreshController creation with controlFinishRefresh: true',
        (tester) async {
      final controller = EasyRefreshController(controlFinishRefresh: true);
      expect(controller.controlFinishRefresh, isTrue);
      controller.dispose();
    });

    testWidgets('EasyRefreshController creation with controlFinishLoad: false',
        (tester) async {
      final controller = EasyRefreshController(controlFinishLoad: false);
      expect(controller.controlFinishLoad, isFalse);
      controller.dispose();
    });

    testWidgets('EasyRefreshController creation with controlFinishLoad: true',
        (tester) async {
      final controller = EasyRefreshController(controlFinishLoad: true);
      expect(controller.controlFinishLoad, isTrue);
      controller.dispose();
    });
  });

  group('Controller callRefresh Tests', () {
    testWidgets('controller.callRefresh() triggers programmatic refresh',
        (tester) async {
      final key = GlobalKey<_ControllerHarnessState>();
      await tester.pumpWidget(_ControllerHarness(
        key: key,
        controlFinishRefresh: true,
      ));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      expect(state.refreshCalled, isFalse);

      // Call refresh programmatically
      state.controller.callRefresh();
      await tester.pumpAndSettle();

      expect(state.refreshCalled, isTrue);
      expect(state.headerState, isNotNull);
      expect(state.headerState!.mode, IndicatorMode.processing);

      // Finish refresh
      state.controller.finishRefresh();
      await tester.pump();
      await tester.pump();

      // Mode should be done or inactive after finishing
      final headerMode = state.headerState!.mode;
      expect(
          headerMode == IndicatorMode.inactive ||
              headerMode == IndicatorMode.done,
          isTrue);

      await disposeAndFlush(tester);
    });

    testWidgets(
        'controller.callRefresh(scrollController: ...) is ignored before notifier caches position',
        (tester) async {
      final key = GlobalKey<_ControllerHarnessState>();
      await tester.pumpWidget(_ControllerHarness(
        key: key,
        controlFinishRefresh: true,
      ));
      final state = key.currentState!;

      await tester.pump();

      state.controller.callRefresh(scrollController: state.scrollController);
      await tester.pump();

      expect(state.refreshCalled, isFalse);
      expect(state.headerState?.mode, isNot(IndicatorMode.processing));

      await disposeAndFlush(tester);
    });

    testWidgets(
        'controller.callRefresh(scrollController: ...) works when controller matches cached position',
        (tester) async {
      final key = GlobalKey<_ControllerHarnessState>();
      await tester.pumpWidget(_ControllerHarness(
        key: key,
        controlFinishRefresh: true,
      ));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      state.controller.callRefresh(scrollController: state.scrollController);
      await tester.pumpAndSettle();

      expect(state.refreshCalled, isTrue);
      expect(state.headerState, isNotNull);
      expect(state.headerState!.mode, IndicatorMode.processing);

      state.controller.finishRefresh();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('controller.callRefresh() with custom overOffset',
        (tester) async {
      final key = GlobalKey<_ControllerHarnessState>();
      await tester.pumpWidget(_ControllerHarness(
        key: key,
        controlFinishRefresh: true,
      ));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      // Call refresh with custom overOffset
      state.controller.callRefresh(overOffset: 50);
      await tester.pumpAndSettle();

      expect(state.refreshCalled, isTrue);

      state.controller.finishRefresh();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });
  });

  group('Controller callLoad Tests', () {
    testWidgets('controller.callLoad() triggers programmatic load',
        (tester) async {
      final key = GlobalKey<_ControllerHarnessState>();
      await tester.pumpWidget(_ControllerHarness(
        key: key,
        controlFinishLoad: true,
      ));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      expect(state.loadCalled, isFalse);

      // Call load programmatically
      state.controller.callLoad();
      await tester.pumpAndSettle();

      expect(state.loadCalled, isTrue);
      expect(state.footerState, isNotNull);
      expect(state.footerState!.mode, IndicatorMode.processing);

      // Finish load
      state.controller.finishLoad();
      await tester.pump();
      await tester.pump();

      // Mode should be done or inactive after finishing
      final footerMode = state.footerState!.mode;
      expect(
          footerMode == IndicatorMode.inactive ||
              footerMode == IndicatorMode.done,
          isTrue);

      await disposeAndFlush(tester);
    });

    testWidgets(
        'controller.callLoad(scrollController: ...) is ignored before notifier caches position',
        (tester) async {
      final key = GlobalKey<_ControllerHarnessState>();
      await tester.pumpWidget(_ControllerHarness(
        key: key,
        controlFinishLoad: true,
      ));
      final state = key.currentState!;

      await tester.pump();

      state.controller.callLoad(scrollController: state.scrollController);
      await tester.pump();

      expect(state.loadCalled, isFalse);
      expect(state.footerState?.mode, isNot(IndicatorMode.processing));

      await disposeAndFlush(tester);
    });

    testWidgets(
        'controller.callLoad(scrollController: ...) works when controller matches cached position',
        (tester) async {
      final key = GlobalKey<_ControllerHarnessState>();
      await tester.pumpWidget(_ControllerHarness(
        key: key,
        controlFinishLoad: true,
      ));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      state.controller.callLoad(scrollController: state.scrollController);
      await tester.pumpAndSettle();

      expect(state.loadCalled, isTrue);
      expect(state.footerState, isNotNull);
      expect(state.footerState!.mode, IndicatorMode.processing);

      state.controller.finishLoad();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets(
        'controller.callRefresh() and callLoad() ignore unattached external scrollController',
        (tester) async {
      final key = GlobalKey<_ControllerHarnessState>();
      await tester.pumpWidget(_ControllerHarness(
        key: key,
        controlFinishRefresh: true,
        controlFinishLoad: true,
      ));
      final state = key.currentState!;
      final detachedController = ScrollController();

      await tester.pump();

      state.controller.callRefresh(scrollController: detachedController);
      await tester.pump();
      expect(state.refreshCalled, isFalse);
      expect(state.headerState?.mode, isNot(IndicatorMode.processing));

      state.controller.callLoad(scrollController: detachedController);
      await tester.pump();
      expect(state.loadCalled, isFalse);
      expect(state.footerState?.mode, isNot(IndicatorMode.processing));

      detachedController.dispose();
      await disposeAndFlush(tester);
    });
  });

  group('Controller finishRefresh Tests', () {
    testWidgets('controller.finishRefresh() completes refresh task',
        (tester) async {
      final key = GlobalKey<_ControllerHarnessState>();
      await tester.pumpWidget(_ControllerHarness(
        key: key,
        controlFinishRefresh: true,
      ));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      state.controller.callRefresh();
      await tester.pumpAndSettle();

      expect(state.headerState!.mode, IndicatorMode.processing);

      // Finish with default success
      state.controller.finishRefresh();
      await tester.pump();

      expect(state.headerState!.result, IndicatorResult.success);

      await tester.pump();
      // Mode should be done or inactive after finishing
      final headerMode = state.headerState!.mode;
      expect(
          headerMode == IndicatorMode.inactive ||
              headerMode == IndicatorMode.done,
          isTrue);

      await disposeAndFlush(tester);
    });

    testWidgets('controller.finishRefresh() with IndicatorResult.fail',
        (tester) async {
      final key = GlobalKey<_ControllerHarnessState>();
      await tester.pumpWidget(_ControllerHarness(
        key: key,
        controlFinishRefresh: true,
      ));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      state.controller.callRefresh();
      await tester.pumpAndSettle();

      // Finish with fail
      state.controller.finishRefresh(IndicatorResult.fail);
      await tester.pump();

      expect(state.headerState!.result, IndicatorResult.fail);

      await disposeAndFlush(tester);
    });
  });

  group('Controller finishLoad Tests', () {
    testWidgets('controller.finishLoad() with different IndicatorResults',
        (tester) async {
      final key = GlobalKey<_ControllerHarnessState>();
      await tester.pumpWidget(_ControllerHarness(
        key: key,
        controlFinishLoad: true,
      ));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      // Test success
      state.controller.callLoad();
      await tester.pumpAndSettle();
      state.controller.finishLoad(IndicatorResult.success);
      await tester.pump();
      expect(state.footerState!.result, IndicatorResult.success);
      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('controller.finishLoad() with IndicatorResult.noMore',
        (tester) async {
      final key = GlobalKey<_ControllerHarnessState>();
      await tester.pumpWidget(_ControllerHarness(
        key: key,
        controlFinishLoad: true,
      ));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      state.controller.callLoad();
      await tester.pumpAndSettle();
      state.controller.finishLoad(IndicatorResult.noMore);
      await tester.pump();

      expect(state.footerState!.result, IndicatorResult.noMore);

      await disposeAndFlush(tester);
    });
  });

  group('Controller resetFooter Tests', () {
    testWidgets('controller.resetFooter() resets noMore state', (tester) async {
      final key = GlobalKey<_ControllerHarnessState>();
      await tester.pumpWidget(_ControllerHarness(
        key: key,
        controlFinishLoad: true,
      ));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      // Set footer to noMore state
      state.controller.callLoad();
      await tester.pumpAndSettle();
      state.controller.finishLoad(IndicatorResult.noMore);
      await tester.pump();

      expect(state.footerState!.result, IndicatorResult.noMore);

      // Reset footer
      state.controller.resetFooter();
      await tester.pump();

      expect(state.footerState!.result, IndicatorResult.none);

      await disposeAndFlush(tester);
    });
  });

  group('Controller headerState and footerState Tests', () {
    testWidgets('controller provides access to header and footer state',
        (tester) async {
      final controller = EasyRefreshController(
        controlFinishRefresh: true,
        controlFinishLoad: true,
      );

      final key = GlobalKey<_ControllerHarnessState>();
      await tester.pumpWidget(_ControllerHarness(
        key: key,
        controlFinishRefresh: true,
        controlFinishLoad: true,
        externalController: controller,
      ));

      await tester.pumpAndSettle();

      // Initially states may be null or inactive
      // final headerState = controller.headerState;
      // final footerState = controller.footerState;

      // Trigger refresh to verify state access
      controller.callRefresh();
      await tester.pumpAndSettle();

      expect(controller.headerState, isNotNull);
      expect(controller.headerState!.mode, IndicatorMode.processing);

      controller.finishRefresh();
      await tester.pump();
      await tester.pump();

      controller.dispose();
      await disposeAndFlush(tester);
    });
  });

  group('Controller with async callbacks', () {
    testWidgets('waiting for task result when controlFinishRefresh is false',
        (tester) async {
      final key = GlobalKey<_ControllerHarnessState>();
      await tester.pumpWidget(_ControllerHarness(
        key: key,
        controlFinishRefresh: false,
      ));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      // Trigger refresh via drag and wait for it to process
      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();
      // Wait for refresh to actually trigger
      for (int i = 0; i < 50 && !state.refreshCalled; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Should be processing or ready
      expect(state.refreshCalled, isTrue);

      // Complete the refresh task
      state.completeRefresh();
      await tester.pump();
      await tester.pump();

      // Mode should be done or inactive after finishing
      final headerMode = state.headerState!.mode;
      expect(
          headerMode == IndicatorMode.inactive ||
              headerMode == IndicatorMode.done,
          isTrue);

      await disposeAndFlush(tester);
    });
  });
}
