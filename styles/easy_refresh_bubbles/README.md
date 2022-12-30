# Bubbles Indicator on EasyRefresh.

[![License](https://img.shields.io/badge/license-MIT-green.svg)](/LICENSE)
[![Pub](https://img.shields.io/pub/v/easy_refresh_bubbles)](https://pub.flutter-io.cn/packages/easy_refresh_bubbles)

### [Online demo](https://xuelongqy.github.io/flutter_easy_refresh/#/style/bubbles)
Animation from [Pull to Refresh](https://rive.app/community/3146-6725-pull-to-refresh/)

## Features

BubblesHeader and BubblesFooter.

## Getting started

```
dependencies:
  flutter_easyre_fresh: version
  easy_refresh_bubbles: version
```

## Usage

```dart
EasyRefresh(
  header: BubblesHeader(),
  footer: BubblesFooter(),
  onRefresh: () async {},
  onLoad: () async {},
  child: ListView(),
)
```
