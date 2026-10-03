---
name: easy-refresh-indicators
description: >-
  Select and customize easy_refresh built-in Header and Footer styles, text,
  icons, colors, indicator placement, listeners, custom builders, and secondary
  (second-floor) panels. Use when changing refresh visuals or indicator behavior.
---

# EasyRefresh indicators

For `easy_refresh` 4.x (Flutter >=3.47, Dart ^3.13). Import
`package:easy_refresh/easy_refresh.dart`; Material UI examples also require a
direct `material_ui: ^1.5.0` dependency.

## Choose the smallest customization

1. Select a built-in style or set its existing text, color and icon parameters.
   Read [built-in styles](references/built-in-styles.md) for all supported
   Header/Footer pairs, defaults, direction limits and extension-package choices.
2. Use `BuilderHeader` / `BuilderFooter` for a new visual; use
   `ListenerHeader` / `ListenerFooter` when rendering outside EasyRefresh.
3. Use `SecondaryBuilderHeader` / `SecondaryBuilderFooter` to wrap an existing
   style with a second-floor panel. Read
   [custom indicators and secondary panels](references/custom-and-secondary.md)
   for standalone Builder, Locator, Listener and secondary examples.

`Header` and `Footer` are abstract configurations, not widgets to instantiate
directly. Supply them to EasyRefresh's `header` and `footer`. They render only
when the corresponding callback is present. `NotRefreshHeader` and
`NotLoadFooter` configure overscroll without rendering an indicator.

`IndicatorMode` describes gesture/task progress; `IndicatorResult` describes the
outcome. A widget builder must render from `IndicatorState`, not start network
requests during build. Keep refresh/load work in the EasyRefresh callbacks.

`position: locator` needs a matching Header/Foot­er locator in the scroll view;
`above` and `behind` use EasyRefresh's stack. `custom` leaves placement to you.
In official `EasyRefresh.nested`, the page Header locator is inserted for you.

Set `EasyRefresh.defaultHeaderBuilder` / `defaultFooterBuilder` once during app
setup for app-wide defaults. Explicit per-widget indicators take precedence.
Use localized strings from the consumer app; Classic text parameters also
accept custom text/message builders, and `messageText` supports `%T` for time.

## Complete text, icon, color and global-default example

```dart
import 'package:easy_refresh/easy_refresh.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  EasyRefresh.defaultFooterBuilder = () => const ClassicFooter(
    noMoreText: 'All items loaded',
    showMessage: false,
  );
  runApp(MaterialApp(
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
    home: Scaffold(
      appBar: AppBar(title: const Text('Custom refresh style')),
      body: EasyRefresh(
        header: const ClassicHeader(
          dragText: 'Pull down',
          armedText: 'Release to refresh',
          processingText: 'Refreshing',
          processedText: 'Updated',
          failedText: 'Try again',
          showMessage: false,
          succeededIcon: Icon(Icons.check_circle_outline),
          textStyle: TextStyle(color: Colors.teal),
        ),
        onRefresh: () async {
          await Future<void>.delayed(const Duration(milliseconds: 600));
          return IndicatorResult.success;
        },
        onLoad: () async => IndicatorResult.noMore,
        child: ListView.builder(
          itemCount: 30,
          itemBuilder: (_, index) => ListTile(title: Text('Item $index')),
        ),
      ),
    ),
  ));
}
```

For a clamping Footer that normally enables infinite loading (Classic or
Cupertino), also set `infiniteOffset: null`. Infinite loading requires
`clamping: false`; secondary panels also require `infiniteOffset: null`.
Validate the chosen style in both success and failure states and at noMore.
