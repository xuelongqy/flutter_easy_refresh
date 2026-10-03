---
name: easy-refresh-bubbles-usage
description: >-
  Add or configure BubblesHeader and BubblesFooter from easy_refresh_bubbles, including
  Rive initialization, bundled assets and vertical refresh/load behavior.
  Use when the Bubbles animation is requested.
---

# Bubbles indicators

For easy_refresh_bubbles 2.x, easy_refresh 4.x, Flutter >=3.47 and Dart ^3.13.
Declare these direct dependencies for the complete example:

```yaml
dependencies:
  flutter:
    sdk: flutter
  easy_refresh: ^4.0.0
  easy_refresh_bubbles: ^2.0.0
  material_ui: ^1.5.0
  rive: ^0.14.11
```

Await RiveNative.init() after WidgetsFlutterBinding.ensureInitialized() and
before runApp(). The package loads
`packages/easy_refresh_bubbles/assets/bubbles.riv` and manages its animation objects.
Do not copy the .riv into the app, register it again in the app's assets,
or create an external Rive controller for these indicators.

## Parameters and limits

Both BubblesHeader and BubblesFooter require vertical scrolling; vertical reverse is
handled by IndicatorState. They default to triggerOffset 180, clamping false,
position above, springRebound false, safeArea false and infiniteOffset null.
The Footer therefore requires an explicit pull by default.

Both expose key, triggerOffset, clamping, position, spring, readySpringBuilder,
springRebound, frictionFactor, infiniteOffset, hitOver, infiniteHitOver and
hapticFeedback. Bubbles fixes triggerWhenRelease true and safeArea false. It exposes
processedDuration (default one second). There is no safeArea or color
constructor parameter.

Infinite loading needs a nonnegative Footer infiniteOffset with clamping false.
Never combine clamping true with infiniteOffset. Apply consumer layout insets
as needed because safeArea defaults to false. A default pull-only Footer cannot
be assumed to load inside NestedScrollView; use the supported infinite pattern.
Do not infer horizontal or secondary support from another indicator package.

## Complete example

The delayed in-memory work below can be replaced with awaited repository calls.
For real failures, catch the error and return IndicatorResult.fail without
mutating the dataset. Null onRefresh/onLoad disables the corresponding indicator.

```dart
import 'package:easy_refresh/easy_refresh.dart';
import 'package:easy_refresh_bubbles/easy_refresh_bubbles.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rive/rive.dart' show RiveNative;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RiveNative.init();
  runApp(const MaterialApp(home: StyleExample()));
}

class StyleExample extends StatefulWidget {
  const StyleExample({super.key});

  @override
  State<StyleExample> createState() => _StyleExampleState();
}

class _StyleExampleState extends State<StyleExample> {
  int _count = 30;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Bubbles indicators')),
    body: EasyRefresh(
      header: const BubblesHeader(),
      footer: const BubblesFooter(),
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
      child: ListView.builder(
        itemCount: _count,
        itemBuilder: (_, index) => ListTile(title: Text('Item $index')),
      ),
    ),
  );
}
```

Automatic completion awaits the callback; return noMore from load when exhausted.
For manual completion, retain one EasyRefreshController per widget, set the
corresponding controlFinish flag true, finishRefresh/finishLoad on every outcome,
and dispose the controller with its owner. A controller used only for
callRefresh/callLoad should keep the flags false.

resetAfterRefresh defaults to true and resets the Footer after a normally
returning refresh callback, including one returning fail. To retain noMore on
failure, set it false and resetFooter explicitly on successful refresh only.
The completed animation duration is separate from request duration.

Verify asset loading and visible refresh/load animation on the target platform,
then success, failure, noMore, repeated refresh and disposal during a request.
