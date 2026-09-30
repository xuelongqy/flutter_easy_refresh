import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class _Issue831Harness extends StatefulWidget {
  const _Issue831Harness({super.key, required this.appendCount});

  final int appendCount;

  @override
  State<_Issue831Harness> createState() => _Issue831HarnessState();
}

class _Issue831HarnessState extends State<_Issue831Harness> {
  final scrollController = ScrollController();
  final footerListenable = IndicatorStateListenable();

  int itemCount = 20;
  int loadCalls = 0;

  IndicatorState? get footerState => footerListenable.value;

  Future<void> _onLoad() async {
    loadCalls++;
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() => itemCount += widget.appendCount);
    }
  }

  void appendItems(int count) {
    setState(() => itemCount += count);
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
          footer: BuilderFooter(
            listenable: footerListenable,
            triggerOffset: 70,
            clamping: false,
            infiniteOffset: 70,
            position: IndicatorPosition.above,
            hitOver: true,
            infiniteHitOver: true,
            processedDuration: Duration.zero,
            builder: (context, state) => SizedBox(height: state.offset),
          ),
          onLoad: _onLoad,
          child: ListView.builder(
            key: const Key('list'),
            controller: scrollController,
            itemExtent: 50,
            itemCount: itemCount,
            itemBuilder: (context, index) => Text('item $index'),
          ),
        ),
      ),
    );
  }
}

Future<void> _pumpUntil(
  WidgetTester tester,
  bool Function() condition, {
  int frames = 80,
  Duration step = const Duration(milliseconds: 10),
}) async {
  for (var i = 0; i < frames && !condition(); i++) {
    await tester.pump(step);
  }
  expect(condition(), isTrue);
}

Future<_Issue831HarnessState> _mountHarness(
  WidgetTester tester, {
  required int appendCount,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(400, 600);
  addTearDown(tester.view.reset);

  final key = GlobalKey<_Issue831HarnessState>();
  await tester.pumpWidget(_Issue831Harness(key: key, appendCount: appendCount));
  await tester.pump();
  return key.currentState!;
}

Future<void> _startFooterLoad(
  WidgetTester tester,
  _Issue831HarnessState state,
) async {
  state.scrollController.jumpTo(
    state.scrollController.position.maxScrollExtent,
  );
  await tester.pump();
  await tester.fling(
    find.byKey(const Key('list')),
    const Offset(0, -240),
    2400,
  );
  await _pumpUntil(tester, () => state.loadCalls == 1);
}

Future<void> _disposeHarness(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

void main() {
  testWidgets('content growth consumes the old Footer rebound velocity', (
    tester,
  ) async {
    final state = await _mountHarness(tester, appendCount: 10);
    final oldMax = state.scrollController.position.maxScrollExtent;

    await _startFooterLoad(tester, state);
    await _pumpUntil(tester, () => state.itemCount == 30, frames: 40);
    await tester.pump();

    final position = state.scrollController.position;
    final pixelsAfterGrowth = position.pixels;
    expect(pixelsAfterGrowth, greaterThan(oldMax));
    expect(pixelsAfterGrowth, lessThanOrEqualTo(position.maxScrollExtent));

    await tester.pump(const Duration(milliseconds: 100));

    expect(position.pixels, closeTo(pixelsAfterGrowth, 1));
    await _pumpUntil(
      tester,
      () => state.footerState?.mode == IndicatorMode.inactive,
    );
    expect(state.footerState?.offset ?? double.infinity, lessThan(1));
    expect(state.loadCalls, 1);
    expect(tester.takeException(), isNull);
    await _disposeHarness(tester);
  });

  testWidgets('Footer keeps rebounding when growth is not enough', (
    tester,
  ) async {
    final state = await _mountHarness(tester, appendCount: 1);
    final oldMax = state.scrollController.position.maxScrollExtent;

    await _startFooterLoad(tester, state);
    await _pumpUntil(tester, () => state.itemCount == 21, frames: 40);
    await tester.pump();

    final position = state.scrollController.position;
    final pixelsAfterGrowth = position.pixels;
    expect(position.maxScrollExtent, greaterThan(oldMax));
    expect(pixelsAfterGrowth, greaterThan(position.maxScrollExtent));

    await tester.pump(const Duration(milliseconds: 100));

    expect(position.pixels, lessThan(pixelsAfterGrowth - 1));
    expect(state.loadCalls, 1);
    expect(tester.takeException(), isNull);
    await _disposeHarness(tester);
  });

  testWidgets('normal ballistic scrolling keeps velocity when content grows', (
    tester,
  ) async {
    final state = await _mountHarness(tester, appendCount: 10);
    final position = state.scrollController.position;

    state.scrollController.jumpTo(100);
    await tester.pump();
    await tester.fling(
      find.byKey(const Key('list')),
      const Offset(0, -200),
      1800,
    );
    await tester.pump(const Duration(milliseconds: 32));
    final oldMax = position.maxScrollExtent;
    final beforeGrowth = position.pixels;
    expect(beforeGrowth, lessThan(oldMax));

    state.appendItems(10);
    await tester.pump();
    expect(position.maxScrollExtent, greaterThan(oldMax));
    final afterGrowth = position.pixels;

    await tester.pump(const Duration(milliseconds: 100));

    expect(position.pixels, greaterThan(afterGrowth + 1));
    expect(state.loadCalls, 0);
    expect(tester.takeException(), isNull);
    await _disposeHarness(tester);
  });
}
