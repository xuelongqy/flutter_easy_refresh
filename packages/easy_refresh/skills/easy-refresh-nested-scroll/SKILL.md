---
name: easy-refresh-nested-scroll
description: >-
  Integrate easy_refresh with NestedScrollView, SliverAppBar and TabBarView.
  Use for page versus per-tab refresh/load ownership, nested physics and locators,
  or a secondary Header in the official Flutter NestedScrollView.
---

# Nested scrolling with EasyRefresh

For easy_refresh 4.x, Flutter >=3.47 and Dart ^3.13. Examples use the standalone
`material_ui` package (^1.2.0); declare it directly in the consumer app.

## Choose refresh ownership

| Requirement | Layout |
| --- | --- |
| One page Header and one active-inner Footer | `EasyRefresh.nested(onRefresh: ..., onLoad: ..., headerSliverBuilder: ..., body: ...)`. Route load to the active tab yourself when using tabs. |
| Page Header, independent per-tab Footer/noMore | Outer nested refresh only (`onLoad: null`); each tab owns an EasyRefresh with `onRefresh: null`, `NotRefreshHeader()`, its own load callback and controller. |
| Each tab owns its Header and Footer | Keep the outer nested integration for physics, with `onRefresh: null` and `onLoad: null`. Each tab owns its indicators; put locator Headers in that tab's inner slivers. |

Retain tab state (for example with AutomaticKeepAliveClientMixin) when noMore
must survive switching tabs. Use unique PageStorageKeys for scroll positions;
those keys alone do not preserve indicator state. On page refresh, update the
appropriate tab data and reset each affected tab's Footer through its own
controller. Do not attach one EasyRefreshController to multiple EasyRefresh
instances. Page-level resetAfterRefresh does not reset separate child instances.

## Physics and positioning

`EasyRefresh.nested` constructs Flutter's official NestedScrollView; it does not
accept an existing nested widget as a wrapper. It sets nested physics, inserts
HeaderLocator before outer slivers when onRefresh exists, and promotes a
non-clamping Header to clamping/locator as needed. Its body inherits physics;
do not insert another page HeaderLocator. It does not support bouncing refresh
inside the nested body.

For ExtendedNestedScrollView or another custom nested view, use
`EasyRefresh.builder(isNested: true)`, assign the supplied physics to the nested
view and its inner scrollable, and insert a page
`HeaderLocator.sliver(clearExtent: false)` in the outer slivers when using a
locator Header. Optional `nestedOuterController` and `nestedInnerController`
must identify that host's outer and active inner controllers, not new unrelated
ones. Secondary Header support here is limited to Flutter's official host.

For a page-level Footer prefer ClassicFooter's default infinite load
(`clamping: false`, `infiniteOffset: 70`). Clamping plus
`infiniteOffset: null` cannot enter the nested overscroll needed to load.
Clamping plus non-null infiniteOffset is invalid even outside a nested layout.

## Complete official nested example

```dart
import 'package:easy_refresh/easy_refresh.dart';
import 'package:material_ui/material_ui.dart';

void main() => runApp(const MaterialApp(home: NestedRefreshExample()));

class NestedRefreshExample extends StatefulWidget {
  const NestedRefreshExample({super.key});

  @override
  State<NestedRefreshExample> createState() => _NestedRefreshExampleState();
}

class _NestedRefreshExampleState extends State<NestedRefreshExample> {
  int _count = 30;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: EasyRefresh.nested(
      header: const ClassicHeader(
        clamping: true,
        position: IndicatorPosition.locator,
      ),
      footer: const ClassicFooter(),
      onRefresh: () async {
        await Future<void>.delayed(const Duration(milliseconds: 600));
        if (!mounted) return IndicatorResult.fail;
        setState(() => _count = 30);
        return IndicatorResult.success;
      },
      onLoad: () async {
        await Future<void>.delayed(const Duration(milliseconds: 600));
        if (!mounted) return IndicatorResult.fail;
        if (_count < 90) setState(() => _count += 30);
        return _count >= 90 ? IndicatorResult.noMore : IndicatorResult.success;
      },
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverOverlapAbsorber(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          sliver: SliverAppBar(
            pinned: true,
            expandedHeight: 180,
            forceElevated: innerBoxIsScrolled,
            title: const Text('Nested refresh'),
          ),
        ),
      ],
      body: Builder(
        builder: (context) => CustomScrollView(
          key: const PageStorageKey('nested-list'),
          slivers: [
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            SliverList.builder(
              itemCount: _count,
              itemBuilder: (_, index) => ListTile(title: Text('Item $index')),
            ),
          ],
        ),
      ),
    ),
  );
}
```

The inner Builder supplies a context below the nested host for the overlap
handle. Preserve this relationship when moving the body into a tab. If an
awaited repository call replaces the delay, catch expected failures and return
`IndicatorResult.fail`; use resetAfterRefresh false with an explicit successful
Footer reset if a failed refresh must retain the end-of-list state.

## Official nested secondary Header

The owner creates/disposes the controller passed to this standalone widget
factory. The constructor inserts the Header locator. This example has no pinned
app bar; when adding one, retain the overlap pattern above. Set an explicit
dimension larger than the secondary trigger; for a full panel derive it from
bounded layout constraints, not an unbounded scroll child.

```dart
import 'package:easy_refresh/easy_refresh.dart';
import 'package:material_ui/material_ui.dart';

Widget nestedSecondFloor(EasyRefreshController controller) => EasyRefresh.nested(
  controller: controller,
  header: SecondaryBuilderHeader(
    header: const ClassicHeader(
      clamping: true,
      position: IndicatorPosition.locator,
      safeArea: false,
    ),
    secondaryTriggerOffset: 120,
    secondaryDimension: 360,
    builder: (context, state, indicator) {
      final visible = state.mode == IndicatorMode.secondaryReady ||
          state.mode == IndicatorMode.secondaryOpen ||
          state.mode == IndicatorMode.secondaryClosing;
      if (!visible) return indicator.build(context, state);
      return SizedBox(
        height: state.offset,
        child: ColoredBox(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: SafeArea(
            child: Center(
              child: TextButton(
                onPressed: () => controller.closeHeaderSecondary(),
                child: const Text('Close second floor'),
              ),
            ),
          ),
        ),
      );
    },
  ),
  onRefresh: () async => IndicatorResult.success,
  headerSliverBuilder: (context, innerBoxIsScrolled) => [],
  body: ListView.builder(
    itemCount: 30,
    itemBuilder: (_, index) => ListTile(title: Text('Item $index')),
  ),
);
```

Secondary needs a clamping Header, a non-null refresh callback, and no infinite
offset. Its trigger must exceed the base trigger and its dimension must exceed
the secondary trigger. Use openHeaderSecondary/closeHeaderSecondary for
programmatic actions; with the builder constructor explicitly set isNested true
before opening. While open, the Header owns vertical drag gestures. Retracting
70 logical pixels (default secondaryCloseTriggerOffset) closes on release;
shorter drags spring back, and taps keep it open. Handle navigation/back using
the controller and a PopScope appropriate to the consumer route.

Verify collapsed/expanded app bar, refresh at the global top, load at the active
inner bottom, retained tab switching, independent noMore, and secondary
open/close followed by a normal refresh. Do not claim ExtendedNestedScrollView
secondary support from a passing official NestedScrollView test.
