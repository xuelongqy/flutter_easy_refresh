import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _LoadHarness extends StatefulWidget {
  final bool controlFinishLoad;
  final Duration processedDuration;
  final bool clamping;

  const _LoadHarness({
    super.key,
    required this.controlFinishLoad,
    required this.processedDuration,
    this.clamping = false,
  });

  @override
  State<_LoadHarness> createState() => _LoadHarnessState();
}

class _LoadHarnessState extends State<_LoadHarness> {
  late final EasyRefreshController? controller = widget.controlFinishLoad
      ? EasyRefreshController(controlFinishLoad: true)
      : null;

  final scrollController = ScrollController();
  final footerListenable = IndicatorStateListenable();

  int itemCount = 60;

  final _loadStarted = Completer<void>();
  Completer<void>? _loadCompleter;

  Future<void> get loadStarted => _loadStarted.future;
  IndicatorState? get footerState => footerListenable.value;

  void appendItems([int delta = 60]) {
    setState(() {
      itemCount += delta;
    });
  }

  void finishLoad() {
    if (widget.controlFinishLoad) {
      controller!.finishLoad();
      return;
    }
    _loadCompleter!.complete();
  }

  Future<void> _onLoad() async {
    if (!_loadStarted.isCompleted) {
      _loadStarted.complete();
    }
    if (widget.controlFinishLoad) {
      return;
    }
    _loadCompleter ??= Completer<void>();
    await _loadCompleter!.future;
  }

  @override
  void dispose() {
    controller?.dispose();
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
          footer: BuilderFooter(
            listenable: footerListenable,
            triggerOffset: 70,
            clamping: widget.clamping,
            processedDuration: widget.processedDuration,
            infiniteOffset: null,
            triggerWhenRelease: true,
            builder: (context, state) => Text(
              'footer:${state.mode.name}:${state.offset.toStringAsFixed(1)}',
              key: const Key('footer-debug'),
            ),
          ),
          onLoad: _onLoad,
          child: ListView.builder(
            controller: scrollController,
            itemExtent: 50,
            itemCount: itemCount,
            itemBuilder: (context, index) => Text('Item $index'),
          ),
        ),
      ),
    );
  }
}

Future<void> _triggerBottomOverscrollLoad(
  WidgetTester tester,
  _LoadHarnessState state,
) async {
  await tester.pumpAndSettle();
  state.scrollController
      .jumpTo(state.scrollController.position.maxScrollExtent);
  await tester.pump();

  await tester.drag(find.byType(ListView), const Offset(0, -200));
  await tester.pump();

  await state.loadStarted.timeout(const Duration(seconds: 2));
  await tester.pump();

  expect(state.footerState, isNotNull);
  expect(state.footerState!.mode, IndicatorMode.processing);
  expect(state.footerState!.offset, greaterThan(0));
}

Future<void> _disposeAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  // Advance fake time so `Future(() {})` (Timer(0)) callbacks run.
  await tester.pump(const Duration(milliseconds: 1));
}

void main() {
  testWidgets(
    'completion sync clears footer offset when maxScrollExtent increases (controlFinishLoad, processedDuration=0)',
    (tester) async {
      final key = GlobalKey<_LoadHarnessState>();
      await tester.pumpWidget(
        _LoadHarness(
          key: key,
          controlFinishLoad: true,
          processedDuration: Duration.zero,
        ),
      );
      final state = key.currentState!;

      await _triggerBottomOverscrollLoad(tester, state);

      state.appendItems(200);
      await tester.pump();

      state.finishLoad();
      await tester.pump(); // processed
      await tester.pump(); // post-frame done/inactive

      expect(state.footerState, isNotNull);
      expect(state.footerState!.mode, IndicatorMode.inactive);
      expect(state.footerState!.offset, 0);

      await _disposeAndFlush(tester);
    },
  );

  testWidgets(
    'completion sync clears footer offset when maxScrollExtent increases (waitTaskResult, processedDuration=0)',
    (tester) async {
      final key = GlobalKey<_LoadHarnessState>();
      await tester.pumpWidget(
        _LoadHarness(
          key: key,
          controlFinishLoad: false,
          processedDuration: Duration.zero,
        ),
      );
      final state = key.currentState!;

      await _triggerBottomOverscrollLoad(tester, state);

      state.appendItems(200);
      await tester.pump();

      state.finishLoad(); // completes onLoad future
      await tester.pump(); // processed
      await tester.pump(); // post-frame done/inactive

      expect(state.footerState, isNotNull);
      expect(state.footerState!.mode, IndicatorMode.inactive);
      expect(state.footerState!.offset, 0);

      await _disposeAndFlush(tester);
    },
  );

  testWidgets(
    'completion sync is applied on delayed completion (controlFinishLoad, processedDuration>0)',
    (tester) async {
      final key = GlobalKey<_LoadHarnessState>();
      await tester.pumpWidget(
        _LoadHarness(
          key: key,
          controlFinishLoad: true,
          processedDuration: const Duration(milliseconds: 80),
        ),
      );
      final state = key.currentState!;

      await _triggerBottomOverscrollLoad(tester, state);

      state.appendItems(200);
      await tester.pump();

      state.finishLoad();
      await tester.pump(); // processed

      expect(state.footerState, isNotNull);
      expect(state.footerState!.mode, IndicatorMode.processed);

      await tester.pump(const Duration(milliseconds: 120));

      expect(state.footerState, isNotNull);
      expect(state.footerState!.mode, IndicatorMode.inactive);
      expect(state.footerState!.offset, 0);

      await _disposeAndFlush(tester);
    },
  );

  testWidgets(
    'completion sync is applied on delayed completion (waitTaskResult, processedDuration>0)',
    (tester) async {
      final key = GlobalKey<_LoadHarnessState>();
      await tester.pumpWidget(
        _LoadHarness(
          key: key,
          controlFinishLoad: false,
          processedDuration: const Duration(milliseconds: 80),
        ),
      );
      final state = key.currentState!;

      await _triggerBottomOverscrollLoad(tester, state);

      state.appendItems(200);
      await tester.pump();

      state.finishLoad(); // completes onLoad future
      await tester.pump(); // processed

      expect(state.footerState, isNotNull);
      expect(state.footerState!.mode, IndicatorMode.processed);

      await tester.pump(const Duration(milliseconds: 120));

      expect(state.footerState, isNotNull);
      expect(state.footerState!.mode, IndicatorMode.inactive);
      expect(state.footerState!.offset, 0);

      await _disposeAndFlush(tester);
    },
  );

  testWidgets(
    'completion sync clears footer offset in clamping mode',
    (tester) async {
      final key = GlobalKey<_LoadHarnessState>();
      await tester.pumpWidget(
        _LoadHarness(
          key: key,
          controlFinishLoad: true,
          processedDuration: Duration.zero,
          clamping: true,
        ),
      );
      final state = key.currentState!;

      await _triggerBottomOverscrollLoad(tester, state);

      state.appendItems(200);
      await tester.pump();

      state.finishLoad();
      await tester.pump();
      await tester.pump();

      expect(state.footerState, isNotNull);
      expect(state.footerState!.mode, IndicatorMode.inactive);
      expect(state.footerState!.offset, 0);

      await _disposeAndFlush(tester);
    },
  );

  testWidgets(
    'dispose during delayed processed completion does not throw',
    (tester) async {
      final key = GlobalKey<_LoadHarnessState>();
      await tester.pumpWidget(
        _LoadHarness(
          key: key,
          controlFinishLoad: true,
          processedDuration: const Duration(milliseconds: 80),
        ),
      );
      final state = key.currentState!;

      await _triggerBottomOverscrollLoad(tester, state);

      state.appendItems(200);
      await tester.pump();

      state.finishLoad();
      await tester.pump(); // processed

      expect(state.footerState, isNotNull);
      expect(state.footerState!.mode, IndicatorMode.processed);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pump(const Duration(milliseconds: 1));
    },
  );

  testWidgets(
    'dispose before post-frame processed completion does not throw',
    (tester) async {
      final key = GlobalKey<_LoadHarnessState>();
      await tester.pumpWidget(
        _LoadHarness(
          key: key,
          controlFinishLoad: true,
          processedDuration: Duration.zero,
        ),
      );
      final state = key.currentState!;

      await _triggerBottomOverscrollLoad(tester, state);

      state.appendItems(200);
      await tester.pump();

      state.finishLoad();
      await tester.pump(); // processed

      expect(state.footerState, isNotNull);

      await _disposeAndFlush(tester);
    },
  );
}
