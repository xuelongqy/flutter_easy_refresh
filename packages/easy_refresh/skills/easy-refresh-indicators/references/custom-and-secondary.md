# Custom indicators, placement and secondary panels

These examples target easy_refresh 4.x. Declare `easy_refresh: ^4.0.0` and
`material_ui: ^1.2.0`. Each code block is an independent Dart library; put a
returned widget under the consumer's MaterialApp/Scaffold.

## Builder and subclass

BuilderHeader and BuilderFooter require `triggerOffset`, `clamping`, `position`
and `builder`. Their builders receive `(BuildContext, IndicatorState)`.
Header/Footer are abstract; subclass them only when a reusable public type is
useful. `state.mode` is progress, `state.result` is outcome, and `state.offset`
is the current revealed extent. Builders can run many times per gesture.

```dart
import 'package:easy_refresh/easy_refresh.dart';
import 'package:material_ui/material_ui.dart';

class LabelHeader extends Header {
  const LabelHeader()
    : super(triggerOffset: 70, clamping: false, safeArea: false);

  @override
  Widget build(BuildContext context, IndicatorState state) => SizedBox(
    height: state.offset,
    child: Center(child: Text('${state.mode.name}: ${state.result.name}')),
  );
}

Widget customIndicatorExample() => EasyRefresh(
  header: const LabelHeader(),
  footer: BuilderFooter(
    triggerOffset: 70,
    clamping: false,
    position: IndicatorPosition.above,
    infiniteOffset: null,
    safeArea: false,
    builder: (context, state) => SizedBox(
      height: state.offset,
      child: Center(child: Text('Load: ${state.mode.name}')),
    ),
  ),
  onRefresh: () async => IndicatorResult.success,
  onLoad: () async => IndicatorResult.noMore,
  child: ListView.builder(
    itemCount: 30,
    itemBuilder: (_, index) => ListTile(title: Text('Item $index')),
  ),
);
```

For a one-off Header, use `BuilderHeader` with the same explicit configuration
and move the subclass's build body into its builder. For horizontal rendering,
use `state.axis` to size width instead of height and `state.reverse` to orient
the visual. The example above intentionally renders a vertical list.

## Locator

`above` and `behind` use EasyRefresh's Stack. `locator` renders in the scroll
content at HeaderLocator/FooterLocator. Use `.sliver()` in a sliver list, and
the non-sliver constructor in box content. A custom position renders no
indicator automatically. Do not add a second page HeaderLocator when
`EasyRefresh.nested` already inserts one.

```dart
import 'package:easy_refresh/easy_refresh.dart';
import 'package:material_ui/material_ui.dart';

Widget locatorExample() => EasyRefresh(
  header: const ClassicHeader(position: IndicatorPosition.locator),
  footer: const ClassicFooter(position: IndicatorPosition.locator),
  onRefresh: () async => IndicatorResult.success,
  onLoad: () async => IndicatorResult.noMore,
  child: CustomScrollView(
    slivers: [
      const HeaderLocator.sliver(),
      SliverList.builder(
        itemCount: 30,
        itemBuilder: (_, index) => ListTile(title: Text('Item $index')),
      ),
      const FooterLocator.sliver(),
    ],
  ),
);
```

## Listener

Keep an `IndicatorStateListenable` stable across builds and render its nullable
value with `ValueListenableBuilder`. ListenerHeader/ListenerFooter already use
`IndicatorPosition.custom`. This listenable has no public `dispose()` method;
ValueListenableBuilder removes its own listener. Remove any listeners you add
manually when their owner is disposed. Do not dispose package-owned notifiers.

```dart
import 'package:easy_refresh/easy_refresh.dart';
import 'package:material_ui/material_ui.dart';

class ListenerExample extends StatefulWidget {
  const ListenerExample({super.key});

  @override
  State<ListenerExample> createState() => _ListenerExampleState();
}

class _ListenerExampleState extends State<ListenerExample> {
  final _headerState = IndicatorStateListenable();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      ValueListenableBuilder<IndicatorState?>(
        valueListenable: _headerState,
        builder: (_, state, _) => Text(state?.mode.name ?? 'inactive'),
      ),
      Expanded(
        child: EasyRefresh(
          header: ListenerHeader(listenable: _headerState, triggerOffset: 70),
          onRefresh: () async {
            await Future<void>.delayed(const Duration(milliseconds: 600));
            return IndicatorResult.success;
          },
          child: ListView.builder(
            itemCount: 30,
            itemBuilder: (_, index) => ListTile(title: Text('Item $index')),
          ),
        ),
      ),
    ],
  );
}
```

## Secondary (second-floor) panel

Wrap the base style with SecondaryBuilderHeader or SecondaryBuilderFooter. The
builder receives `(context, state, indicator)`; call
`indicator.build(context, state)` to retain the original visual before opening.
Configure `secondaryTriggerOffset > triggerOffset` and, when specified,
`secondaryDimension > secondaryTriggerOffset`. Secondary and infinite loading
are mutually exclusive: a wrapped ClassicFooter needs `infiniteOffset: null`.

Render the panel through `secondaryReady`, `secondaryOpen` and
`secondaryClosing`, so it remains visible through opening/closing animations.
The package owns its drag gestures; a vertical drag that retracts at least
`secondaryCloseTriggerOffset` (70 by default) closes it on release. Smaller
drags spring back open, and taps do not close it. Use the controller's explicit
open/close methods for buttons or navigation actions, not finishRefresh.

```dart
import 'package:easy_refresh/easy_refresh.dart';
import 'package:material_ui/material_ui.dart';

class SecondaryExample extends StatefulWidget {
  const SecondaryExample({super.key});

  @override
  State<SecondaryExample> createState() => _SecondaryExampleState();
}

class _SecondaryExampleState extends State<SecondaryExample> {
  final _controller = EasyRefreshController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => EasyRefresh(
    controller: _controller,
    header: SecondaryBuilderHeader(
      header: const ClassicHeader(clamping: true, safeArea: false),
      secondaryTriggerOffset: 120,
      secondaryDimension: 360,
      builder: (context, state, indicator) {
        final visible = state.mode == IndicatorMode.secondaryReady ||
            state.mode == IndicatorMode.secondaryOpen ||
            state.mode == IndicatorMode.secondaryClosing;
        if (!visible) return indicator.build(context, state);
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) _controller.closeHeaderSecondary();
          },
          child: SizedBox(
            height: state.offset,
            child: ColoredBox(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: SafeArea(
                child: Center(
                  child: TextButton(
                    onPressed: () => _controller.closeHeaderSecondary(),
                    child: const Text('Close second floor'),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
    onRefresh: () async => IndicatorResult.success,
    child: ListView.builder(
      itemCount: 30,
      itemBuilder: (_, index) => ListTile(title: Text('Item $index')),
    ),
  );
}
```

`openHeaderSecondary()` / `closeHeaderSecondary()` control the Header;
`openFooterSecondary()` / `closeFooterSecondary()` control a configured Footer.
Keep the corresponding onRefresh/onLoad callback enabled. For the official
NestedScrollView, use a clamping Header with `EasyRefresh.nested`, or explicitly
`isNested: true` in a builder integration when opening programmatically. The
official nested Header supports secondary panels; support does not extend to
ExtendedNestedScrollView. In nested layouts handle SliverAppBar overlap using
SliverOverlapAbsorber/Injector, and use the panel's SafeArea for system insets.

Verify both gesture and controller opening/closing, interrupted closing, back
navigation, and a normal refresh after closing. Do not add competing gesture
detectors that consume the package's close drag.
