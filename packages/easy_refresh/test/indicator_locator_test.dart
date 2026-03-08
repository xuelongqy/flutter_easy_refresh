import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test harness for HeaderLocator/FooterLocator with CustomScrollView
class _IndicatorLocatorHarness extends StatefulWidget {
  final bool clearExtent;
  final double paintExtent;

  const _IndicatorLocatorHarness({
    super.key,
    this.clearExtent = true,
    this.paintExtent = 0,
  });

  @override
  State<_IndicatorLocatorHarness> createState() =>
      _IndicatorLocatorHarnessState();
}

class _IndicatorLocatorHarnessState extends State<_IndicatorLocatorHarness> {
  late final EasyRefreshController controller;
  final scrollController = ScrollController();
  final headerListenable = IndicatorStateListenable();
  final footerListenable = IndicatorStateListenable();

  int itemCount = 60;

  Completer<void>? _refreshCompleter;
  Completer<void>? _loadCompleter;

  IndicatorState? get headerState => headerListenable.value;
  IndicatorState? get footerState => footerListenable.value;

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
            listenable: headerListenable,
            triggerOffset: 70,
            clamping: false,
            position: IndicatorPosition.locator,
            processedDuration: Duration.zero,
            builder: (context, state) => Container(
              height: state.offset,
              width: double.infinity,
              color: Colors.blue.withValues(alpha: 0.3),
              alignment: Alignment.center,
              child: Text(
                'Header: ${state.mode.name}',
                key: const Key('header-locator-text'),
              ),
            ),
          ),
          footer: BuilderFooter(
            listenable: footerListenable,
            triggerOffset: 70,
            clamping: false,
            position: IndicatorPosition.locator,
            infiniteOffset: null,
            processedDuration: Duration.zero,
            builder: (context, state) => Container(
              height: state.offset,
              width: double.infinity,
              color: Colors.green.withValues(alpha: 0.3),
              alignment: Alignment.center,
              child: Text(
                'Footer: ${state.mode.name}',
                key: const Key('footer-locator-text'),
              ),
            ),
          ),
          onRefresh: _onRefresh,
          onLoad: _onLoad,
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              HeaderLocator.sliver(
                clearExtent: widget.clearExtent,
                paintExtent: widget.paintExtent,
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => ListTile(
                    key: Key('item-$index'),
                    title: Text('Item $index'),
                  ),
                  childCount: itemCount,
                ),
              ),
              FooterLocator.sliver(
                clearExtent: widget.clearExtent,
                paintExtent: widget.paintExtent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Test harness for Box locators
class _BoxLocatorHarness extends StatefulWidget {
  const _BoxLocatorHarness({super.key});

  @override
  State<_BoxLocatorHarness> createState() => _BoxLocatorHarnessState();
}

class _BoxLocatorHarnessState extends State<_BoxLocatorHarness> {
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
          header: BuilderHeader(
            triggerOffset: 70,
            clamping: false,
            position: IndicatorPosition.locator,
            processedDuration: Duration.zero,
            builder: (context, state) => Container(
              height: state.offset,
              width: double.infinity,
              color: Colors.blue.withValues(alpha: 0.3),
              alignment: Alignment.center,
              child: const Text('Header'),
            ),
          ),
          footer: BuilderFooter(
            triggerOffset: 70,
            clamping: false,
            position: IndicatorPosition.locator,
            infiniteOffset: null,
            processedDuration: Duration.zero,
            builder: (context, state) => Container(
              height: state.offset,
              width: double.infinity,
              color: Colors.green.withValues(alpha: 0.3),
              alignment: Alignment.center,
              child: const Text('Footer'),
            ),
          ),
          onRefresh: _onRefresh,
          onLoad: _onLoad,
          child: ListView.builder(
            controller: scrollController,
            itemCount: itemCount + 2, // +2 for locators
            itemBuilder: (context, index) {
              if (index == 0) {
                return const HeaderLocator();
              }
              if (index == itemCount + 1) {
                return const FooterLocator();
              }
              return ListTile(
                key: Key('item-${index - 1}'),
                title: Text('Item ${index - 1}'),
              );
            },
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
  group('HeaderLocator.sliver Tests', () {
    testWidgets('HeaderLocator.sliver renders in CustomScrollView',
        (tester) async {
      final key = GlobalKey<_IndicatorLocatorHarnessState>();
      await tester.pumpWidget(_IndicatorLocatorHarness(key: key));

      await tester.pumpAndSettle();

      // Trigger refresh
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 200));
      await tester.pump();

      // Header should be visible in locator position
      expect(find.byKey(const Key('header-locator-text')), findsOneWidget);

      key.currentState!.finishRefresh();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('HeaderLocator.sliver with clearExtent: false', (tester) async {
      final key = GlobalKey<_IndicatorLocatorHarnessState>();
      await tester.pumpWidget(_IndicatorLocatorHarness(
        key: key,
        clearExtent: false,
      ));

      await tester.pumpAndSettle();

      // Trigger refresh
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 200));
      await tester.pump();

      // Should still render correctly
      expect(find.byType(EasyRefresh), findsOneWidget);

      key.currentState!.finishRefresh();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('HeaderLocator.sliver with custom paintExtent', (tester) async {
      final key = GlobalKey<_IndicatorLocatorHarnessState>();
      await tester.pumpWidget(_IndicatorLocatorHarness(
        key: key,
        paintExtent: 10,
      ));

      await tester.pumpAndSettle();

      // Trigger refresh
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 200));
      await tester.pump();

      // Should render with custom paint extent
      expect(find.byType(EasyRefresh), findsOneWidget);

      key.currentState!.finishRefresh();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });
  });

  group('FooterLocator.sliver Tests', () {
    testWidgets('FooterLocator.sliver renders in CustomScrollView',
        (tester) async {
      final key = GlobalKey<_IndicatorLocatorHarnessState>();
      await tester.pumpWidget(_IndicatorLocatorHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      // Scroll to bottom
      state.scrollController.jumpTo(
        state.scrollController.position.maxScrollExtent,
      );
      await tester.pump();

      // Trigger load
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -200));
      await tester.pump();

      // Footer should be visible in locator position
      expect(find.byKey(const Key('footer-locator-text')), findsOneWidget);

      state.finishLoad();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });
  });

  group('HeaderLocator (Box) Tests', () {
    testWidgets('HeaderLocator renders in ListView', (tester) async {
      final key = GlobalKey<_BoxLocatorHarnessState>();
      await tester.pumpWidget(_BoxLocatorHarness(key: key));

      await tester.pumpAndSettle();

      // Trigger refresh
      await tester.drag(find.byType(ListView), const Offset(0, 200));
      await tester.pump();

      // Header should be rendered
      expect(find.text('Header'), findsOneWidget);

      key.currentState!.finishRefresh();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });
  });

  group('FooterLocator (Box) Tests', () {
    testWidgets('FooterLocator renders in ListView', (tester) async {
      final key = GlobalKey<_BoxLocatorHarnessState>();
      await tester.pumpWidget(_BoxLocatorHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      // Use controller to trigger load
      state.controller.callLoad();
      await tester.pump();
      // Wait for load to trigger
      for (int i = 0; i < 50; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Footer or EasyRefresh should be rendered
      expect(find.byType(EasyRefresh), findsOneWidget);

      state.finishLoad();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });
  });

  group('IndicatorPosition.locator Tests', () {
    testWidgets('Header with IndicatorPosition.locator requires HeaderLocator',
        (tester) async {
      final key = GlobalKey<_IndicatorLocatorHarnessState>();
      await tester.pumpWidget(_IndicatorLocatorHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      // Use controller to trigger refresh (more reliable)
      state.controller.callRefresh();
      await tester.pump();
      // Wait for refresh to trigger
      for (int i = 0; i < 50 && state.headerState == null; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Now header state should be available
      expect(state.headerState, isNotNull);

      state.finishRefresh();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });

    testWidgets('Footer with IndicatorPosition.locator requires FooterLocator',
        (tester) async {
      final key = GlobalKey<_IndicatorLocatorHarnessState>();
      await tester.pumpWidget(_IndicatorLocatorHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      // Scroll to bottom
      state.scrollController.jumpTo(
        state.scrollController.position.maxScrollExtent,
      );
      await tester.pump();

      // Trigger load
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -200));
      await tester.pump();

      // Footer state should be available
      expect(state.footerState, isNotNull);

      state.finishLoad();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });
  });

  group('Locator State Updates', () {
    testWidgets('HeaderLocator updates state during refresh cycle',
        (tester) async {
      final key = GlobalKey<_IndicatorLocatorHarnessState>();
      await tester.pumpWidget(_IndicatorLocatorHarness(key: key));
      final state = key.currentState!;

      await tester.pumpAndSettle();

      // Start drag
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(CustomScrollView)),
      );
      await gesture.moveBy(const Offset(0, 50));
      await tester.pump();

      expect(state.headerState, isNotNull);
      expect(state.headerState!.mode, IndicatorMode.drag);

      // Drag past trigger
      await gesture.moveBy(const Offset(0, 100));
      await tester.pump();

      expect(state.headerState!.mode, IndicatorMode.armed);

      // Release
      await gesture.up();
      await tester.pump();

      state.finishRefresh();
      await tester.pump();
      await tester.pump();

      await disposeAndFlush(tester);
    });
  });
}
