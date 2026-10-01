---
name: easy-refresh-usage
description: >-
  Integrate easy_refresh refresh and load callbacks, controllers, completion,
  pagination results, initial refresh, and scroll physics. Use for basic setup
  or diagnosing stuck indicators and incorrect noMore handling.
---

# EasyRefresh usage

For `easy_refresh` 4.x, Flutter >=3.47 and Dart ^3.13. Use
`package:easy_refresh/easy_refresh.dart`. Material examples require a direct
`material_ui: ^1.2.0` dependency and `package:material_ui/material_ui.dart`.
Apps using the older Flutter Material library should keep a compatible 3.x
release until they migrate; do not apply a framework migration just to add refresh.

## Choose the integration

- Use `EasyRefresh(child: ...)` for one scrollable. It scopes physics to child
  scrollables; an explicit, unrelated child physics can override that scope.
- Use `EasyRefresh.builder` when choosing which scrollable receives refresh
  physics. Assign the supplied `physics` to that scrollable; the builder does
  not scope it automatically. A `Column` alone cannot scroll.
- For Flutter's official `NestedScrollView`, use `EasyRefresh.nested` with
  `headerSliverBuilder` and `body`. It inserts the page Header locator and
  supplies nested physics. A custom nested view needs
  `EasyRefresh.builder(isNested: true)` and explicit physics on the nested view
  and its inner scrollable. Keep page and per-tab refresh ownership distinct.

## Completion and lifecycle

| Mode | Callback contract |
| --- | --- |
| Automatic (default) | Await the actual work and return `IndicatorResult.success`, `fail`, or `noMore`. Returning nothing means success. |
| Manual | Set the corresponding `controlFinishRefresh` / `controlFinishLoad` to `true`, then call `finishRefresh(result)` / `finishLoad(result)` on every completion path. The callback's return value does not finish the task. |

Create one controller per EasyRefresh state, retain it across builds, and dispose
it with its owner. A controller used only for `callRefresh()` or `callLoad()` does
not need manual completion flags. Trigger it after attachment, such as from a
button; use `refreshOnStart: true` for initial loading. Do not use `force: true`
to work around an uncompleted task. `finishLoad(result, true)` is an explicit
result override, not the normal completion contract.

Catch expected request errors in the callback. Automatic mode marks an uncaught
exception as failed but rethrows it; manual mode still needs its finish call.
Check `mounted` after awaiting work before updating widget state or completing
through a controller owned by that state.

Return `noMore` from **load** when the end is known. Returning it from refresh
locks the Header instead. `resetAfterRefresh` defaults to true and resets the
Footer after a normally returning refresh callback, including one that returns
`fail`. To keep end-of-list state on a failed refresh, set it to false and call
`resetFooter()` only after a successful refresh, as below. `canLoadAfterNoMore`
and `canRefreshAfterNoMore` allow tasks despite the corresponding lock; they do
not replace resetting state for a new dataset. Refresh and load are mutually
exclusive by default (`simultaneously: false`).

## Complete automatic/manual example

This in-memory request can be replaced with an awaited repository call. Run with
`manualCompletion: true` to exercise manual completion; keep that configuration
fixed for the lifetime of this example's state.

```dart
import 'package:easy_refresh/easy_refresh.dart';
import 'package:material_ui/material_ui.dart';

void main() => runApp(const MaterialApp(home: RefreshExample()));

class RefreshExample extends StatefulWidget {
  const RefreshExample({super.key, this.manualCompletion = false});

  final bool manualCompletion;

  @override
  State<RefreshExample> createState() => _RefreshExampleState();
}

class _RefreshExampleState extends State<RefreshExample> {
  late final _controller = EasyRefreshController(
    controlFinishRefresh: widget.manualCompletion,
    controlFinishLoad: widget.manualCompletion,
  );
  int _count = 20;

  Future<IndicatorResult> _refresh() async {
    var result = IndicatorResult.fail;
    try {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (!mounted) return result;
      setState(() => _count = 20);
      _controller.resetFooter();
      result = IndicatorResult.success;
    } catch (_) {
      result = IndicatorResult.fail;
    } finally {
      if (mounted && widget.manualCompletion) {
        _controller.finishRefresh(result);
      }
    }
    return result;
  }

  Future<IndicatorResult> _load() async {
    var result = IndicatorResult.fail;
    try {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (!mounted) return result;
      if (_count < 60) setState(() => _count += 20);
      result = _count >= 60 ? IndicatorResult.noMore : IndicatorResult.success;
    } catch (_) {
      result = IndicatorResult.fail;
    } finally {
      if (mounted && widget.manualCompletion) _controller.finishLoad(result);
    }
    return result;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Refresh and load'),
      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: () => _controller.callRefresh(),
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: EasyRefresh(
      controller: _controller,
      refreshOnStart: true,
      resetAfterRefresh: false,
      onRefresh: _refresh,
      onLoad: _load,
      child: ListView.builder(
        itemCount: _count,
        itemBuilder: (_, index) => ListTile(title: Text('Item $index')),
      ),
    ),
  );
}
```

## Explicit physics example

```dart
import 'package:easy_refresh/easy_refresh.dart';
import 'package:material_ui/material_ui.dart';

Widget refreshGrid() => EasyRefresh.builder(
  onRefresh: () async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return IndicatorResult.success;
  },
  childBuilder: (context, physics) => GridView.builder(
    physics: physics,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
    ),
    itemCount: 20,
    itemBuilder: (_, index) => Center(child: Text('Item $index')),
  ),
);
```

Set direction and `reverse` on the scrollable (`EasyRefresh.nested` exposes them
itself). Header and Footer follow the scroll axis/direction, not fixed screen
top/bottom. `triggerAxis` filters the axis allowed to trigger tasks. Use a style
that supports that axis: Classic, Material, Cupertino and Bezier support
horizontal scrolling; BezierCircle, Phoenix, Taurus, Delivery and the six Rive
extension styles require vertical scrolling.

Verify refresh success/failure, repeated loading through noMore, refresh after
noMore, an empty list, and disposal during a pending request in the consumer.
