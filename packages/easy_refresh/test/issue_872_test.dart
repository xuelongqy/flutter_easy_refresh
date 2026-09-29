import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class _Issue872Harness extends StatefulWidget {
  const _Issue872Harness({
    super.key,
    required this.clamping,
    this.simultaneously = false,
  });

  final bool clamping;
  final bool simultaneously;

  @override
  State<_Issue872Harness> createState() => _Issue872HarnessState();
}

class _Issue872HarnessState extends State<_Issue872Harness> {
  final scrollController = ScrollController();
  final headerListenable = IndicatorStateListenable();
  final footerListenable = IndicatorStateListenable();

  Completer<void>? _refreshCompleter;
  Completer<void>? _loadCompleter;
  int refreshCalls = 0;
  int loadCalls = 0;

  IndicatorState? get headerState => headerListenable.value;
  IndicatorState? get footerState => footerListenable.value;

  Future<void> _onRefresh() async {
    refreshCalls++;
    _refreshCompleter = Completer<void>();
    await _refreshCompleter!.future;
  }

  Future<void> _onLoad() async {
    loadCalls++;
    _loadCompleter = Completer<void>();
    await _loadCompleter!.future;
  }

  void finishRefresh() {
    if (!(_refreshCompleter?.isCompleted ?? true)) {
      _refreshCompleter!.complete();
    }
  }

  void finishLoad() {
    if (!(_loadCompleter?.isCompleted ?? true)) {
      _loadCompleter!.complete();
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: EasyRefresh(
          scrollController: scrollController,
          simultaneously: widget.simultaneously,
          header: BuilderHeader(
            listenable: headerListenable,
            triggerOffset: 70,
            clamping: widget.clamping,
            position: IndicatorPosition.above,
            processedDuration: Duration.zero,
            builder: (context, state) =>
                SizedBox(height: state.offset, child: const Text('header')),
          ),
          footer: BuilderFooter(
            listenable: footerListenable,
            triggerOffset: 70,
            clamping: widget.clamping,
            infiniteOffset: null,
            processedDuration: Duration.zero,
            builder: (context, state) =>
                SizedBox(height: state.offset, child: const Text('footer')),
          ),
          onRefresh: _onRefresh,
          onLoad: _onLoad,
          child: ListView.builder(
            key: const Key('list'),
            controller: scrollController,
            itemExtent: 50,
            itemCount: 30,
            itemBuilder: (context, index) => Text('item $index'),
          ),
        ),
      ),
    );
  }
}

Future<void> _pumpUntil(WidgetTester tester, bool Function() condition) async {
  for (var i = 0; i < 40 && !condition(); i++) {
    await tester.pump(const Duration(milliseconds: 25));
  }
  expect(condition(), isTrue);
}

Future<void> _startRefresh(
  WidgetTester tester,
  _Issue872HarnessState state,
) async {
  await tester.drag(find.byKey(const Key('list')), const Offset(0, 200));
  await _pumpUntil(tester, () => state.refreshCalls == 1);
  expect(state.headerState!.mode, IndicatorMode.processing);
}

Future<void> _startLoad(
  WidgetTester tester,
  _Issue872HarnessState state,
) async {
  state.scrollController.jumpTo(
    state.scrollController.position.maxScrollExtent,
  );
  await tester.pump();
  await tester.drag(find.byKey(const Key('list')), const Offset(0, -200));
  await _pumpUntil(tester, () => state.loadCalls == 1);
  expect(state.footerState!.mode, IndicatorMode.processing);
}

Future<TestGesture> _overscrollBottom(
  WidgetTester tester,
  _Issue872HarnessState state,
) async {
  state.scrollController.jumpTo(
    state.scrollController.position.maxScrollExtent,
  );
  await tester.pump();
  final gesture = await tester.startGesture(
    tester.getCenter(find.byKey(const Key('list'))),
  );
  await gesture.moveBy(const Offset(0, -40));
  await tester.pump();
  await gesture.moveBy(const Offset(0, -100));
  await tester.pump();
  return gesture;
}

Future<TestGesture> _overscrollTop(
  WidgetTester tester,
  _Issue872HarnessState state,
) async {
  state.scrollController.jumpTo(
    state.scrollController.position.minScrollExtent,
  );
  await tester.pump();
  final gesture = await tester.startGesture(
    tester.getCenter(find.byKey(const Key('list'))),
  );
  await gesture.moveBy(const Offset(0, 40));
  await tester.pump();
  await gesture.moveBy(const Offset(0, 100));
  await tester.pump();
  return gesture;
}

Future<void> _disposeAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

void main() {
  for (final clamping in [false, true]) {
    testWidgets(
      'refresh hides Footer while preserving clamping=$clamping scrolling',
      (tester) async {
        final key = GlobalKey<_Issue872HarnessState>();
        await tester.pumpWidget(_Issue872Harness(key: key, clamping: clamping));
        await tester.pumpAndSettle();
        final state = key.currentState!;

        await _startRefresh(tester, state);
        final gesture = await _overscrollBottom(tester, state);

        expect(state.footerState!.mode, IndicatorMode.inactive);
        expect(state.footerState!.offset, 0);
        expect(state.loadCalls, 0);
        if (clamping) {
          expect(
            state.scrollController.position.pixels,
            lessThanOrEqualTo(state.scrollController.position.maxScrollExtent),
          );
        } else {
          expect(
            state.scrollController.position.pixels,
            greaterThan(state.scrollController.position.maxScrollExtent),
          );
        }

        await gesture.up();
        state.finishRefresh();
        await tester.pumpAndSettle();
        await _disposeAndFlush(tester);
      },
    );

    testWidgets(
      'load hides Header while preserving clamping=$clamping scrolling',
      (tester) async {
        final key = GlobalKey<_Issue872HarnessState>();
        await tester.pumpWidget(_Issue872Harness(key: key, clamping: clamping));
        await tester.pumpAndSettle();
        final state = key.currentState!;

        await _startLoad(tester, state);
        final gesture = await _overscrollTop(tester, state);

        expect(state.headerState!.mode, IndicatorMode.inactive);
        expect(state.headerState!.offset, 0);
        expect(state.refreshCalls, 0);
        if (clamping) {
          expect(
            state.scrollController.position.pixels,
            greaterThanOrEqualTo(
              state.scrollController.position.minScrollExtent,
            ),
          );
        } else {
          expect(
            state.scrollController.position.pixels,
            lessThan(state.scrollController.position.minScrollExtent),
          );
        }

        await gesture.up();
        state.finishLoad();
        await tester.pumpAndSettle();
        await _disposeAndFlush(tester);
      },
    );
  }

  testWidgets('simultaneously=true keeps the opposite task available', (
    tester,
  ) async {
    final key = GlobalKey<_Issue872HarnessState>();
    await tester.pumpWidget(
      _Issue872Harness(key: key, clamping: false, simultaneously: true),
    );
    await tester.pumpAndSettle();
    final state = key.currentState!;

    await _startRefresh(tester, state);
    final gesture = await _overscrollBottom(tester, state);
    expect(state.footerState!.offset, greaterThan(0));
    await gesture.up();
    await _pumpUntil(tester, () => state.loadCalls == 1);

    state.finishLoad();
    state.finishRefresh();
    await tester.pumpAndSettle();
    await _disposeAndFlush(tester);
  });
}
