# flutter_easy_refresh

[![License](https://img.shields.io/badge/license-MIT-green.svg)](/LICENSE)
[![Awesome Flutter](https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true&style=flat-square)](https://stackoverflow.com/questions/tagged/flutter?sort=votes)
[![Pub](https://img.shields.io/pub/v/easy_refresh)](https://pub.dev/packages/easy_refresh)

## English | [中文](/README_CN.md)

Just like the name, EasyRefresh can easily implement pull-down refresh and pull-up load on Flutter applications. It supports almost all Flutter Scrollable widgets. Its function is very similar to Android's SmartRefreshLayout, and it also absorbs the advantages of many third-party libraries. EasyRefresh integrates various styles of Header and Footer, but it has no limitations, you can easily customize it. Using Flutter's powerful animations, even just a simple control can be done. The goal of EasyRefresh is to create a powerful, stable and mature pull-to-refresh framework for Flutter.

### [Online demo](https://xuelongqy.github.io/flutter_easy_refresh/)
### [APK download](https://github.com/xuelongqy/flutter_easy_refresh/releases)

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
  )
```
#### 2. builder constructor
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
#### 3. Indicator locate
```dart
  EasyRefresh.builder(
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
  )
  // Global
  EasyRefresh.defaultHeaderBuilder = () => ClassicHeader();
  EasyRefresh.defaultFooterBuilder = () => ClassicFooter();
```

# Contributions welcome
One's maintenance is lonely. If you have good suggestions and changes, welcome to contribute your code. If you have really cool styles， It's even cooler to share with everyone.

# Donate
If you like my project, please in the upper right corner of the project "Star". Your support is my biggest encouragement! ^_^ You can also use cryptocurrencies, buy me a coffee.

<details>
<summary>Ethereum</summary>
<p>Ethereum series, ETH, BNB, MATIC, USDT and other tokens</p>
<pre>
0x949A007161651015b8A07D0255B75731d60be804
</pre>
<img src="https://raw.githubusercontent.com/xuelongqy/donation/master/ethereum_qr.png?raw=true" alt="Ethereum">
</details>

<details>
<summary>Tron</summary>
<p>Tron chain, TRX, USDT, USDC and other tokens</p>
<pre>
TKqkkyrjeox37cVG8G2HfHZrNMET1YbEfw
</pre>
<img src="https://raw.githubusercontent.com/xuelongqy/donation/master/tron_qr.png?raw=true" alt="Tron">
</details>

<details>
<summary>Bitcoin</summary>
<pre>
bc1qutj3gmn46vwmcsjnc5sjqax7kxx5xm6fvyg5vp
</pre>
<img src="https://raw.githubusercontent.com/xuelongqy/donation/master/bitcoin_qr.png?raw=true" alt="Bitcoin">
</details>

<details>
<summary>Dogecoin</summary>
<pre>
DLs1Btam1M13o9LxiErbe1UXy7iqfZyNRg
</pre>
<img src="https://raw.githubusercontent.com/xuelongqy/donation/master/dogecoin_qr.png?raw=true" alt="Dogecoin">
</details>

### QQ Group - 554981921
#### Into the group of instructions
The group is not only solve the problem of EasyreFresh, any Flutter related issues can be discussed. Just as its name, craigslist, as long as there is time, group of Lord will help you solve problems together.

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
