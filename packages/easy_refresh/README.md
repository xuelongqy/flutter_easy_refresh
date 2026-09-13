# flutter_easy_refresh

[![License](https://img.shields.io/badge/license-MIT-green.svg)](/LICENSE)
[![Platform Flutter](https://img.shields.io/badge/platform-Flutter-blue.svg)](https://flutter.dev)
[![Pub](https://img.shields.io/pub/v/easy_refresh)](https://pub.dev/packages/easy_refresh)

## English | [中文](https://github.com/xuelongqy/flutter_easy_refresh/blob/v4/README_CN.md)

Just like the name, EasyRefresh can easily implement pull-down refresh and pull-up load on Flutter applications. It supports almost all Flutter Scrollable widgets. Its function is very similar to Android's SmartRefreshLayout, and it also absorbs the advantages of many third-party libraries. EasyRefresh integrates various styles of Header and Footer, but it has no limitations, you can easily customize it. Using Flutter's powerful animations, even just a simple control can be done. The goal of EasyRefresh is to create a powerful, stable and mature pull-to-refresh framework for Flutter.

### [Online demo](https://xuelongqy.github.io/flutter_easy_refresh/)

### [APK download](https://github.com/xuelongqy/flutter_easy_refresh/releases)

### [API reference](https://pub.dev/documentation/easy_refresh/latest/)

## Features:

- Supports all scrollable widgets
- Scrolling physics scope, exactly matching scrollable widgets
- Integrate multiple cool Header and Footer
- Support custom styles to achieve various animation effects
- Support pull-down refresh, pull-up load (Can be triggered and finished with a controller)
- Support indicator position setting, combined with listeners can also be placed in any position
- Support refresh when the page starts, and customize the view
- Support safe area, no more occlusion
- Customize scroll parameters to allow lists to have different scrolling feedback and inertia

## Requirements (v4.0+)

EasyRefresh 4.x requires **Flutter >= 3.47** and uses the standalone
[material_ui](https://pub.dev/packages/material_ui) / [cupertino_ui](https://pub.dev/packages/cupertino_ui) packages.

**4.0 is for apps that have already migrated** (`dart fix --apply --code=migrate_design_widgets`).
Apps still on `package:flutter/material.dart` should stay on `easy_refresh: ^3.5.1` (the `v3` branch) until they migrate.

Built-in indicators read `Theme` and localizations from `material_ui`. A typical app looks like this:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:easy_refresh/easy_refresh.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: EasyRefresh(
        onRefresh: () async {},
        onLoad: () async {},
        child: ListView(),
      ),
    );
  }
}
```

## Companion Packages

For pagination helpers, use the standalone `easy_paging` [![Pub](https://img.shields.io/pub/v/easy_paging)](https://pub.dev/packages/easy_paging) package.

```dart
import 'package:easy_paging/easy_paging.dart';
import 'package:easy_refresh/easy_refresh.dart';
```

Sample implementation: `example/lib/page/sample/paging_page.dart`

## Sample

#### 1. Default constructor

- In the child scope, all scrolling components will share one physics. If there is scroll nesting, use EasyRefresh.builder or set the scope with ScrollConfiguration

```dart
  EasyRefresh(
    onRefresh: () async {
      ....
    },
    onLoad: () async {
      ....
    },
    child: ListView(),
  );
```

#### 2. Builder constructor

```dart
  EasyRefresh.builder(
    onRefresh: () async {
      ....
      return IndicatorResult.success;
    },
    onLoad: () async {
      ....
    },
    childBuilder: (context, physics) {
      return ListView(
        physics: physics,
      );
    },
  );
```

#### 3. Indicator locate

```dart
  EasyRefresh(
    header: Header(
      position: IndicatorPosition.locator,
    ),
    footer: Footer(
      position: IndicatorPosition.locator,
    ),
    onRefresh: () async {
      ....
    },
    onLoad: () async {
      ....
      return IndicatorResult.noMore;
    },
    child: CustomScrollView(
      slivers: [
        SliverAppBar(),
        const HeaderLocator.sliver(),
        ...
        const FooterLocator.sliver(),
      ],
    ),
  );
```

#### 4. Use controller

```dart
  EasyRefreshController _controller = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );
  ....
  EasyRefresh(
    controller: _controller,
    onRefresh: () async {
      ....
      _controller.finishRefresh();
      _controller.resetFooter();
    },
    onLoad: () async {
      ....
      _controller.finishLoad(IndicatorResult.noMore);
    },
    ....
  );
  ....
  _controller.callRefresh();
  _controller.callLoad();
```

#### 5. Specify Header and Footer

```dart
  EasyRefresh(
    header: MaterialHeader(),
    footer: MaterialFooter(),
    child: ListView(),
    ....
  );
  // Global
  EasyRefresh.defaultHeaderBuilder = () => ClassicHeader();
  EasyRefresh.defaultFooterBuilder = () => ClassicFooter();
```

#### 6. NestedScrollView

`EasyRefresh.nested` is the first-class wrapper for Flutter's **official** `NestedScrollView`. It creates that view, applies NestedScrollView-safe physics, and (when `onRefresh` is set) inserts `HeaderLocator` as the first outer sliver. You do **not** pass `physics` on `body`. Header must be **clamping** (non-clamping Headers are promoted). Inner bouncing pull-to-refresh and secondary Header + Nested are **not supported**. Nested `onLoad` should keep ClassicFooter's **infinite** load (`clamping: false`); `clamping: true` + `infiniteOffset: null` cannot enter NestedScrollView overscroll.

A Footer on this layer binds the **visible** inner (current `TabBarView` tab). Split `onLoad` by tab yourself. Independent `noMore` / Footer state per tab needs Recipe B.

Do **not** wrap `ExtendedNestedScrollView` (or any custom nested view) with `EasyRefresh.nested` — it can only construct Flutter's `NestedScrollView`. Use `EasyRefresh.builder(isNested: true)` and assign the builder `physics` to that view.

`isNested: true` means NestedScrollView-safe physics, not extra `if`s on the bouncing path.

**Recipe A — page refresh (recommended)**

One EasyRefresh around NestedScrollView. One `onRefresh`. Sample: `example/lib/page/sample/easy_refresh_nested_page.dart`. ExtendedNested uses `builder` (`tab_bar_view_page.dart`).

```dart
EasyRefresh.nested(
  header: MaterialHeader(
    clamping: true,
    position: IndicatorPosition.locator,
  ),
  onRefresh: () async {
    ....
  },
  onLoad: () async {
    ....
  },
  headerSliverBuilder: (context, innerBoxIsScrolled) {
    return [
      const SliverAppBar(pinned: true, expandedHeight: 120),
    ];
  },
  body: ListView(),
);

// ExtendedNestedScrollView or a custom nested view:
EasyRefresh.builder(
  isNested: true,
  header: MaterialHeader(
    clamping: true,
    position: IndicatorPosition.locator,
  ),
  onRefresh: () async {
    ....
  },
  childBuilder: (context, physics) {
    return ExtendedNestedScrollView(
      physics: physics,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          const HeaderLocator.sliver(clearExtent: false),
          ....
        ];
      },
      body: ListView(
        physics: physics,
      ),
    );
  },
);
```

**Recipe B — page Header + per-tab Footer**

Outer `EasyRefresh.nested` (or `builder(isNested: true)`) refreshes only (`onLoad: null`). Each tab has its own `EasyRefresh` with `onRefresh: null` and `NotRefreshHeader()`.

```dart
EasyRefresh.nested(
  header: MaterialHeader(
    clamping: true,
    position: IndicatorPosition.locator,
  ),
  onRefresh: () async {
    ....
  },
  headerSliverBuilder: (context, innerBoxIsScrolled) {
    return [
      const SliverAppBar(pinned: true, expandedHeight: 120),
    ];
  },
  body: TabBarView(
    children: [
      EasyRefresh(
        header: const NotRefreshHeader(),
        onLoad: () async {
          ....
        },
        child: ListView(),
      ),
    ],
  ),
);
```

**Recipe C — per-tab Header (NestedScrollView sample)**

When Header sits in each tab's inner slivers (below the TabBar), the outer layer **must not** set `onRefresh`, or you get a page Header. The NestedScrollView **outer still needs nested-safe physics**, or pushing up collapses the AppBar before the Header retracts.

Use an outer `EasyRefresh.builder(isNested: true)` **without** `onRefresh` / `onLoad`: it only passes `physics` into the nested view. Each tab has a real `EasyRefresh` with its own Header/Footer. Those physics instances are **not** shared — outer freezes the AppBar; inner drives that tab's indicators.

Sample: `example/lib/page/sample/nested_scroll_view.dart`.

```dart
EasyRefresh.builder(
  isNested: true,
  childBuilder: (context, physics) {
    return NestedScrollView(
      physics: physics,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          const SliverAppBar(pinned: true, expandedHeight: 120),
        ];
      },
      body: TabBarView(
        children: [
          EasyRefresh.builder(
            isNested: true,
            header: MaterialHeader(
              clamping: true,
              position: IndicatorPosition.locator,
            ),
            onRefresh: () async {
              ....
            },
            onLoad: () async {
              ....
            },
            childBuilder: (context, innerPhysics) {
              return CustomScrollView(
                physics: innerPhysics,
                slivers: [
                  const HeaderLocator.sliver(clearExtent: false),
                  ....
                  const FooterLocator.sliver(clearExtent: false),
                ],
              );
            },
          ),
        ],
      ),
    );
  },
);
```

## Style Packages

| Package                                                                   | Pub                                                                                                            |
| ------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| [easy_refresh_bubbles](https://pub.dev/packages/easy_refresh_bubbles)     | [![Pub](https://img.shields.io/pub/v/easy_refresh_bubbles)](https://pub.dev/packages/easy_refresh_bubbles)     |
| [easy_refresh_halloween](https://pub.dev/packages/easy_refresh_halloween) | [![Pub](https://img.shields.io/pub/v/easy_refresh_halloween)](https://pub.dev/packages/easy_refresh_halloween) |
| [easy_refresh_skating](https://pub.dev/packages/easy_refresh_skating)     | [![Pub](https://img.shields.io/pub/v/easy_refresh_skating)](https://pub.dev/packages/easy_refresh_skating)     |
| [easy_refresh_space](https://pub.dev/packages/easy_refresh_space)         | [![Pub](https://img.shields.io/pub/v/easy_refresh_space)](https://pub.dev/packages/easy_refresh_space)         |
| [easy_refresh_squats](https://pub.dev/packages/easy_refresh_squats)       | [![Pub](https://img.shields.io/pub/v/easy_refresh_squats)](https://pub.dev/packages/easy_refresh_squats)       |

## Feel free to contribute

One's maintenance is lonely. If you have good suggestions and changes, feel free to contribute your code. If you have really cool styles, It's even cooler to share with everyone.

#### Thanks to all the people who already contributed!

<a href="https://github.com/xuelongqy/flutter_easy_refresh/graphs/contributors">
    <img src="https://contrib.rocks/image?repo=xuelongqy/flutter_easy_refresh" />
</a>

## QQ Group - 554981921

#### Into the group of instructions

The group is not only solve the problem of EasyRefresh, any Flutter related issues can be discussed. Just as its name, craigslist, as long as there is time, group of Lord will help you solve problems together.

## Thanks

[SmartRefreshLayout](https://github.com/scwang90/SmartRefreshLayout)  
[flutter_spinkit](https://github.com/jogboms/flutter_spinkit)

## Licenses

```

MIT License

Copyright (c) 2018 xuelongqy

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


```
