# flutter_easy_refresh

[![License](https://img.shields.io/badge/license-MIT-green.svg)](/LICENSE)
[![Platform Flutter](https://img.shields.io/badge/platform-Flutter-blue.svg)](https://flutter.dev)
[![Pub](https://img.shields.io/pub/v/easy_refresh)](https://pub.dev/packages/easy_refresh)

## [English](https://github.com/xuelongqy/flutter_easy_refresh/blob/v3/README.md) | 中文

正如名字一样，EasyRefresh很容易就能在Flutter应用上实现下拉刷新以及上拉加载操作，它支持几乎所有的Flutter滚动组件。它的功能与Android的SmartRefreshLayout很相似，同样也吸取了很多三方库的优点。EasyRefresh中集成了多种风格的Header和Footer，但是它并没有局限性，你可以很轻松的自定义。使用Flutter强大的动画，甚至随便一个简单的控件也可以完成。EasyRefresh的目标是为Flutter打造一个强大，稳定，成熟的下拉刷新框架。

### [在线演示](https://xuelongqy.github.io/flutter_easy_refresh/)
### [APK下载](https://github.com/xuelongqy/flutter_easy_refresh/releases)
### [API文档](https://pub.dev/documentation/easy_refresh/latest/)

## 特点功能:
 - 支持所有的滚动组件
 - 滚动物理作用域，精确匹配滚动组件
 - 集成多个炫酷的 Header 和 Footer
 - 支持自定义样式，实现各种动画效果
 - 支持下拉刷新、上拉加载(可使用控制器触发和结束)
 - 支持指示器位置设定，结合监听器也放置在任何位置
 - 支持页面启动时刷新，并自定义视图
 - 支持安全区域，不再有遮挡
 - 自定义滚动参数，让列表具有不同的滚动反馈和惯性

## 简单用例
#### 1.默认构造器
 - child作用域内，所有滚动组件会公用一个physics。如果有滚动嵌套，请使用EasyRefresh.builder或用ScrollConfiguration设置作用域
```dart
  EasyRefresh(
    onRefresh: () async {
      ....
    },
    onLoad: () async {
      ....
    },
    child: ListView(),
  )
```
#### 2.builder构造器
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
  )
```
#### 3.指示器定位
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
  )
```
#### 4.控制器使用
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
#### 5.使用指定的 Header 和 Footer
```dart
  EasyRefresh(
    header: MaterialHeader(),
    footer: MaterialFooter(),
    child: ListView(),
    ....
  )
  // 全局设置
  EasyRefresh.defaultHeaderBuilder = () => ClassicHeader();
  EasyRefresh.defaultFooterBuilder = () => ClassicFooter();
```

## 欢迎贡献
一个人的维护是孤独的。如果你有好的建议和改动，欢迎贡献你的代码。如果你有非常酷的样式，能够分享给大家那就更酷了。

__感谢所有的贡献者!__

<a href="https://github.com/xuelongqy/flutter_easy_refresh/graphs/contributors">
    <img src="https://contrib.rocks/image?repo=xuelongqy/flutter_easy_refresh" />
</a>

## QQ讨论群 - 554981921
#### 进群须知
这个群不仅仅是解决EasyRefresh的问题，任何Flutter相关的问题都可以进行讨论。正如它的名字一样，有问必答，只要群主有时间，都会帮大家一起解决问题。

## 感谢
[SmartRefreshLayout](https://github.com/scwang90/SmartRefreshLayout)  
[flutter_spinkit](https://github.com/jogboms/flutter_spinkit)  

## 开源协议

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
