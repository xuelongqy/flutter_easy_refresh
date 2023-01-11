# flutter_easy_refresh

[![License](https://img.shields.io/badge/license-MIT-green.svg)](/LICENSE)
[![Platform Flutter](https://img.shields.io/badge/platform-Flutter-blue.svg)](https://flutter.dev)
[![Pub](https://img.shields.io/pub/v/easy_refresh)](https://pub.dev/packages/easy_refresh)

## English | [中文](https://github.com/xuelongqy/flutter_easy_refresh/blob/v3/README_CN.md)

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
```dart
  EasyRefresh.builder(
    header: MaterialHeader(
      clamping: true,
    ),
    onRefresh: () async {
      ....
    },
    onLoad: () async {
      ....
    },
    childBuilder: (context, physics) {
      return NestedScrollView(
        physics: physics,
        body: ListView(
          physics: physics,
        );
      );
    },
  );
  // or
  EasyRefresh.builder(
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
    childBuilder: (context, physics) {
      return NestedScrollView(
        physics: physics,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            const HeaderLocator.sliver(clearExtent: false),
            ....
          ];
        },
        body: ListView(
          physics: physics,
        );
      );
    },
  );
```

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
